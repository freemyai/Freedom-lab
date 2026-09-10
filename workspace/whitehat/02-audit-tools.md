# 智能合约审计工具链调研（02-audit-tools）

> 白帽方向学习笔记 · 覆盖五大主流工具的定位/用法/命令，以及四类高频漏洞的原理、最小示例与检测手段。
> 说明：命令与代码均对照官方文档/GitHub README 核对，关键结论标注来源 URL。

---

## 一、工具定位与用法

智能合约安全测试一般遵循「静态分析 → 模糊测试 → 单元测试/不变量 → 符号执行」的分层组合。没有任何单一工具能覆盖所有问题，实战中通常串联使用：先用 **Slither** 做全量静态扫描快速拉清单，再用 **Foundry** 写单测与不变量、**Echidna** 跑状态机 fuzzing，必要时用 **Mythril / Halmos** 做符号执行以穷举可达路径。

### 1. Slither（静态分析）

- **定位**：Crytic/Trail of Bits 出品，Python3 编写的 Solidity & Vyper 静态分析框架。把源码转成中间表示 **SlithIR**（SSA 形式），在上面跑一组漏洞检测器（detector），并暴露 Python API 供写自定义分析。号称能正确解析 99.9% 的公开 Solidity 代码，单合约平均执行时间不到 1 秒。来源：https://github.com/crytic/slither
- **强项**：速度快、误报低、检测器覆盖面广（未初始化状态、`tx.origin`、`unchecked send`、重入、未保护 upgrade、低级别调用未检查返回值等）；能精确定位源码行号；无缝接入 GitHub Actions / pre-commit / CI；附带 `human-summary`、`inheritance-graph` 等 printer 帮人读合约。
- **盲区**：纯静态、基于污点/数据流与固定规则，**不理解跨函数复杂业务语义、无法覆盖依赖运行时状态的路径**；对需要"跑起来才知道"的数值/时序漏洞（如复杂闪电贷组合、依赖 `block.timestamp` 的攻击）基本无能为力；对 `assembly`、跨合约调用、动态分发调用会退化为低精度。它给的是"候选问题"，必须人工 triage。
- **上手示例**（来自官方 Usage/Wiki）：
  ```bash
  # 安装（推荐 uv）
  uv tool install slither-analyzer
  # 或对无依赖的单文件
  uvx --from slither-analyzer slither file.sol

  # 对 Hardhat / Foundry / Brownie / Truffle 工程（依赖底层框架编译）
  slither .

  # 对 Etherscan 上的已部署合约
  slither 0x7F37f78cBD74481E593F9C737776F7113d76B315

  # 只跑指定检测器
  slither . --detect reentrancy,uninitialized-state,arbitrary-send

  # 导出 JSON / Markdown 报告（审计留档）
  slither . --json out.json
  slither . --checklist                      # Markdown 报告
  slither . --checklist --markdown-root https://github.com/ORG/REPO/blob/COMMIT/

  # 交互式 triage：逐条决定"保留/忽略"，结果存 slither.db.json
  slither . --triage-mode
  ```
- **输出解读**：每条 finding 含 **Detector 名、Impact（High/Medium/Low）、Confidence（High/Medium/Low）、合约名、函数名、行号** 与解释文字。读报告时要看 Impact × Confidence 两个维度——"High 置信度"直接处理，"Low 置信度/Informational"多为提示（如 `assembly`、`timestamp`、`low-level-calls`），需要人工判断。可在源码里加 `// slither-disable-next-line reentrancy` 或 `// slither-disable-start [detector] ... end` 抑制误报。
  来源：https://github.com/crytic/slither/wiki/Usage

### 2. Echidna（Fuzzing / 不变量测试）

- **定位**：Crytic 出品，Haskell 编写的"快速智能合约模糊测试器"。基于合约 **ABI** 做语法感知（grammar-based）fuzzing，针对**用户定义的不变量（invariant / property）**或 Solidity `assert` 做反证。核心思路：对每个不变量生成随机调用序列，若找到能使其变假的序列就打印出来；找不到则给出一定程度的安全信心。来源：https://github.com/crytic/echidna
- **强项**：专为"状态机 + 随机调用序列"设计，擅长挖**需要多步操作才能触发的时序/状态类 bug**（如先 A 再 B 才触发的逻辑漏洞），这是静态分析抓不到的；支持 `property`（默认，跑 `echidna_` 前缀返回 `bool` 的函数）、`assertion`（检测 `assert()`/Foundry `assertX`）、`foundry`（跑 Foundry 风格 `invariant_` 不变量）、`optimization`（最大化 `int256` 返回）、`overflow`、`exploration`（只收集覆盖）等模式；能跑 Foundry/Hardhat/Truffle 工程；2.3 版本还引入了符号执行/验证模式并可生成 Foundry 复现用例。
- **盲区**：本质是"随机 + 覆盖引导"，**不保证穷举**——跑不到覆盖不到的路径就没法下结论；需要你先"猜对"要测什么不变量（写不出好 property 就测不出对应 bug）；对纯算术边界、需精确构造的输入不如符号执行可靠。
- **上手示例**（官方 README）：
  ```solidity
  // 不变量 = 以 echidna_ 开头、无参、返回 bool 的函数
  function echidna_check_balance() public view returns (bool) {
      return (balance >= 20);   // 断言：余额永不 < 20
  }
  ```
  ```bash
  echidna myContract.sol          # 跑单文件
  echidna .                       # 用当前编译框架（Foundry/Hardhat/Truffle）
  # 常用：跑 Foundry invariant
  echidna . --test-mode foundry
  # 限制步数/时间/seed（示意，详见 --help 与 docs）
  echidna myContract.sol -t 1000 --seed 1
  ```
  来源：https://github.com/crytic/echidna 、https://blog.trailofbits.com/2023/07/21/fuzzing-on-chain-contracts-with-echidna/

### 3. Foundry（forge test：单测 + 不变量 + cheatcodes）

- **定位**：Foundry 套件里的 `forge` 是 Rust 编写的测试/开发框架，提供**确定性单元测试**、**property/fuzz 测试**（`testFuzz`/`invariant`）与**fork 测试**。是当下最主流的开发-测试一体化工具。来源：https://book.getfoundry.sh/ 、https://getfoundry.sh/forge/tests/cheatcodes
- **强项**：极快（Rust + 原生 EVM）、开发体验好；`invariant_` 测试可对合约做随机调用序列并**每次调用后断言**，配合 Handler + ghost variable 能把复杂协议（如 ERC-4626 Vault）测得很扎实；cheatcodes 极其强大，能改 EVM 状态（时间、块号、`msg.sender`、余额、storage）、mock 外部调用、fork 主网回放；还能对主网合约做 fork 测试复现真实场景。
- **盲区**：本质仍是（有限步数的）fuzzing + 确定性用例，**不穷举**，找不到的路径不等于不存在；`fail_on_revert=false` 时若 handler 反复 revert，测试会"假通过"；需要作者写对测试与不变量。
- **不变量测试要点**（官方 Invariant Testing 文档）：
  - 写 `invariant_` 前缀的 view 函数，例如守恒/偿付能力：
    ```solidity
    function invariant_SolvencyCheck() public view {
        assertGe(address(vault).balance, vault.totalDeposits());
    }
    function invariant_ConservationOfDeposits() public view {
        assertEq(address(vault).balance,
                 handler.depositSum() - handler.withdrawSum());
    }
    ```
  - 用 `targetContract(address(handler))` 把随机调用导向 **Handler**（而非直接打合约），用 `bound()` 约束输入、`excludeSelector`/`excludeContract` 排除无关函数；
  - `foundry.toml` 的 `[invariant]` 段控制 `runs`、`depth`、`fail_on_revert`、`max_time_delay` 等；
  - 失败时 `forge test -vvvv` 会打印触发失败的**调用序列**，便于复现与修复。来源：https://www.getfoundry.sh/guides/invariant-testing
- **上手示例**：
  ```bash
  forge init myproj && cd myproj
  forge build
  forge test                       # 跑全部
  forge test --match-test testWithdraw -vvvv
  forge test --match-contract VaultInvariantTest   # 只跑某个不变量合约
  forge test --fork-url $RPC_URL   # fork 主网回放
  ```
- **常用 cheatcode**（来自 Cheatcodes Reference，通过 `vm` 对象调用）：
  ```solidity
  vm.warp(1700000000);                       // 设 block.timestamp
  vm.roll(18000000);                          // 设 block.number
  vm.prank(alice); contract.doSomething();   // 伪造 msg.sender
  vm.deal(alice, 100 ether);                 // 直接发 ETH
  vm.store(address(token), bytes32(0), bytes32(1000)); // 改 storage
  vm.expectRevert("Insufficient");           // 断言 revert
  vm.expectCall(target, calldata);           // 断言外部调用
  vm.mockCall(...)                            // mock 外部合约返回
  vm.assume(cond);                            // fuzz 约束输入
  ```
  来源：https://getfoundry.sh/forge/cheatcodes 、https://www.getfoundry.sh/forge/testing

### 4. Mythril（符号执行）

- **定位**：ConsenSys Diligence 出品，基于**符号执行**的 EVM **字节码**安全分析工具。通过对输入符号化并系统遍历执行路径，寻找触发漏洞的具体路径。来源：https://github.com/ConsensysDiligence/mythril
- **强项**：**穷举可达路径**，能给出**具体的反例事务序列**（谁调了什么、calldata 是什么、状态如何演变），适合验证"某状态到底能不能被触发"；检测整数溢出/下溢、非常规 gas 消耗、自毁 `SELFDESTRUCT`、受控 `delegatecall` 等；支持直接分析已部署合约地址。
- **盲区**：**对复杂合约易状态爆炸、超时/路径爆炸**（`-t`/`--execution-timeout` 用来限制）；分析的是字节码，报出的位置是 **PC 地址**，回溯到 Solidity 源码行有时不直观；对需要长事务/跨合约复杂编排的场景覆盖有限；历史上维护活跃度不及 Crytic/Foundry 生态，需以官方 docs 为准。
- **上手示例**（官方 README）：
  ```bash
  docker pull mythril/myth
  pip3 install mythril

  myth analyze <solidity-file>        # 分析源码
  myth analyze -a <contract-address>  # 分析链上已部署合约

  myth analyze killbilly.sol -t 3 --execution-timeout 30
  # 输出示例（节选）：
  #   ==== Unprotected Selfdestruct ====
  #   SWC ID: 106  Severity: High
  #   Function: commencekilling()
  #   附"Initial State + Transaction Sequence"具体反例调用序列
  ```
  每条结果带 **SWC ID**（对应 https://swcregistry.io/ 的漏洞分类与修复指引）、Severity、PC、gas 估算、状态与事务序列。来源：https://github.com/ConsenSysDiligence/mythril

### 5. Halmos（现代符号执行 / 符号测试，补充）

- **定位**：a16z 出品的 **EVM 符号测试**工具，前端是 Solidity/Foundry 风格。核心理念：**复用已有的单元/模糊测试当作形式化规格**——把普通测试喂给 Halmos 后，它对**所有可能输入**做符号执行，验证断言"永不被违反"，否则给出反例。相当于"用现有测试做轻量级形式验证"，是从测试走向形式验证的低成本入口。来源：https://github.com/a16z/halmos 、https://a16zcrypto.com/posts/article/symbolic-testing-with-halmos-leveraging-existing-tests-for-formal-verification/
- **强项**：**穷举式**（在深度/路径限制内），比纯 fuzzing 更能命中需要精确构造输入的边界 bug；与 Foundry 生态无缝（用 `forge` 工程、`svm.createUint256` 等 Halmos cheatcodes 造符号量）；对无界循环/变长数组做**有界符号推理**，牺牲少量完备性换取无需写循环不变量的便利性。
- **盲区**：符号执行固有的**路径/状态爆炸**，需设 `--loop-bounds`、`--array-bounds` 等；只报告**断言违反（Panic(1)）**，其它错误（如溢出）默认忽略——你得把想验证的性质写成断言；beta 阶段，能力与文档仍在演进。
- **上手示例**（结合 Getting-started 与 cheatcodes）：
  ```solidity
  import {SymTest} from "halmos-cheatcodes/SymTest.sol";
  contract TokenTest is SymTest {
      Token token;
      function setUp() public { token = new Token(); /* ... */ }

      function checkBalanceUpdate() public {
          address caller = svm.createAddress('caller');
          address others = svm.createAddress('others');
          vm.assume(others != caller);
          uint256 oldCaller = token.balanceOf(caller);
          uint256 oldOthers = token.balanceOf(others);
          vm.prank(caller);
          (, bytes memory data) = caller.code ? (token, ""); // 任意调用示意
          token.balanceOf(caller); // 通过 svm.createBytes 构造任意 calldata 后 .call
          // 断言：调用者不能凭空多拿、不能减少他人余额
          assert(token.balanceOf(caller) <= oldCaller, "no free money");
          assert(token.balanceOf(others) >= oldOthers, "no drain");
      }
  }
  ```
  ```bash
  halmos test/ --function checkBalanceUpdate
  halmos test/ --loop-bounds 2 --array-bounds 2   # 控制有界性
  ```
  来源：https://github.com/a16z/halmos 、https://github.com/a16z/halmos-cheatcodes

> **现代工具/生态补充**：Trail of Bits 的 **`properties`/secure-contracts** 工具链与 **property-based testing** 方法论（把"不变量怎么写好"系统化）是 fuzzing 的配套能力（https://blog.trailofbits.com/categories/fuzzing/ ）；**0xPolygon/zkSync** 等团队在 L2 上普遍采用"Foundry 单测 + Echidna/不变量 + fork 测试"的组合，并对**低流动性池的 oracle/清算逻辑**做重点 fuzzing。这些实践的共同点是：**用不变量刻画"业务守恒/偿付/单调/边界"四类性质**，再交给 fuzzer 去破坏它。

### 工具选型速查

| 工具 | 方法 | 穷举性 | 擅长 | 主要盲区 |
|---|---|---|---|---|
| Slither | 静态分析 | 否 | 快速拉清单、定位行号、CI 集成 | 不懂运行时状态/业务语义 |
| Echidna | 状态机 fuzzing | 否 | 多步时序/状态 bug | 覆盖不到=测不出，依赖好 property |
| Foundry | 单测+不变量+fork | 否（有限步） | 开发体验、fork 复现、Handler 建模 | 仍非穷举，可能假通过 |
| Mythril | 符号执行(字节码) | 有限（受 -t/timeout 限） | 给出具体反例事务序列 | 路径爆炸、PC 定位不直观 |
| Halmos | 符号测试(Foundry 前端) | 有限（受 bounds 限） | 复用现有测试做形式验证 | 只报断言违反、状态爆炸 |

---

## 二、四类高频漏洞原理与检测

### 1. 重入（Reentrancy）

**原理**：合约 `A` 在**还没更新完自身状态**时，先向外部合约 `B` 发起调用（发 ETH / ERC20 transfer / 低级别 `call`）。若 `B`（或其 `fallback`）在 A 的调用栈尚未返回时就**再次回调** A 的同一函数，A 会基于"旧状态"重复执行，从而被反复提取资金或篡改状态。

- **单函数重入**：一次 `withdraw()` 内先 `msg.sender.payable.call{value}("")` 再 `balances[msg.sender]=0`，回调可在余额清零前再次 withdraw。
- **跨函数重入**：外部调用触发的回调落在**另一个函数**（如 `approve` 里 transferFrom 触发 `tokenFallback` 又调 `approve`），更隐蔽，静态"同函数读写"检测器易漏。
- **读-写顺序规则（CEI 规则，Checks-Effects-Interactions）**：**先做所有检查（Checks）→ 再改所有状态（Effects）→ 最后才对外交互（Interactions）**。只要"写状态"发生在"外部调用"之前，重入窗口就被关闭。

最小示例（伪代码）：
```solidity
// 漏洞版：Interactions 在 Effects 之前
function withdraw() public {
    uint256 amt = balances[msg.sender];
    payable(msg.sender).transfer(amt); // 先外部调用（触发回调）
    balances[msg.sender] = 0;          // 后改状态 → 可被重入
}
// 修复版：CEI
function withdraw() public nonReentrant {
    uint256 amt = balances[msg.sender]; // Checks
    balances[msg.sender] = 0;           // Effects（先清零）
    payable(msg.sender).transfer(amt);  // Interactions（后调用）
}
```
**防御**：CEI 顺序、`ReentrancyGuard` 互斥锁（`nonReentrant`）、`pull-payment`（记录待付、由用户领取）而非 `push`、只读外部合约返回的 `block`/只读状态避免副作用。
**检测手段**：Slither 的 `reentrancy` / `reentrancy-no-eth` / `reentrancy-events` / `reentrancy-benign` 检测器（来源：Slither detectors 列表，https://github.com/crytic/slither ）；Mythril 通过构造"同一合约在外部调用后再次进入同一状态写"的路径给出反例；Echidna/Foundry 用不变量（如"总余额守恒""单用户余额非负"）+ 带回调的 handler 触发。

### 2. 预言机操纵（Oracle Manipulation）

**原理**：合约用**链上单点价格**（DEX 现货、`slot0`/`getReserves`、`livePrice`）做关键决策（计价、清算、铸造/销毁、抵押估值）。攻击者用**闪电贷**在**同一区块内**瞬间砸穿低流动性池的价格，让合约读到被扭曲的价格并据此执行危险操作。

- **价格操纵（现货）**：直接读 `getReserves()` 或 Uniswap V3 `slot0()`，一次 flash swap 即可在单块内扭曲。
- **TWAP**：时间加权平均**能抵御单块闪电贷**，但**并非免疫**——若观察窗口短（<30min）且池子流动性低，攻击者可用**多块持续压价**把 TWAP 也拉偏（如 Deus Finance 2022 被 Solidly 短窗口 TWAP 操纵，https://nomoslabs.io/archive/deus-finance-2022 ）。
- **链下/push 预言机风险**：Chainlink 等 push 模型有 **Heartbeat + Deviation Threshold**；若偏离阈值过宽、心跳过长，存在"**staleness window**"——真实价格已崩而喂价未更新，合约仍按旧高价估值。

最小示例（伪代码，来自公开漏洞索引/SCFG）：
```solidity
// 漏洞：单块可操纵的现货价
function getPrice() public view returns (uint256) {
    (uint112 r0, uint112 r1,) = pair.getReserves(); // flash swap 可瞬间拉偏
    return uint256(r1) * 1e18 / uint256(r0);
}
// 修复：用 TWAP（≥30min）+ 偏差熔断
function getSafePrice() public view returns (uint256) {
    uint256 spot = _getSpot();
    uint256 twap = _getTWAP(30 minutes);
    require(deviation(spot, twap) <= MAX_DEV, "oracle manipulation");
    return twap;
}
```
**检测手段**：Slither 的 `arbitrary-send`/低级别调用/`timestamp` 等提示需人工结合"价格来源→下游动作"审查；审计 checklist 明确检查：`slot0()`/`getReserves()` 是否直接喂给清算/铸造/抵押估值？是否用 `observe()`/`consult()` TWAP？push 预言机是否校验 `updatedAt`/`answeredInRound`（staleness）？是否有 >X% 偏差熔断与跨源交叉验证？（来源：https://github.com/kadenzipfel/protocol-vulnerabilities-index/ 、https://www.cyfrin.io/blog/price-oracle-manipulation-attacks-with-examples 、https://scsfg.io/hackers/oracle-manipulation ）

### 3. 权限控制（Access Control）

**原理与常见子类**：
- **访问控制缺失**：危险函数（mint、withdraw、upgrade、setX、pause、selfdestruct）没有 `onlyOwner`/`onlyRole`，任何人可调用。
- **owner 逻辑错误**：`msg.sender` vs `owner` 判断写反、`tx.origin` 误用、`renounceOwnership` 后功能被"锁死"或可被任何人接管。
- **多签与 timelock**：高权限操作应走 **Gnosis Safe 多签 + Timelock**（如 Uniswap/Compound 模式），给链上留出预警与撤回窗口；缺失 timelock 意味着 owner 单点可即时作恶。
- **初始化函数未锁（upgradeable 场景）**：代理模式把 `constructor` 换成普通 `initialize()`，但**普通函数可被反复调用**；若无 `initializer` 守卫，攻击者可经代理调用 `initialize()` 把 owner 设成自己，接管整个协议。来源：https://owasp.org/www-project-smart-contract-top-10/2026/en/src/SC10-proxy-and-upgradeability-vulnerabilities.html 、https://docs.openzeppelin.com/upgrades-plugins/writing-upgradeable

最小示例（伪代码）：
```solidity
// 漏洞：无访问控制 + 未锁初始化
contract Vuln is Initializable {
    address public owner;
    function initialize(address o) external { owner = o; } // 无 initializer → 可重入调用
    function setOwner(address n) external { owner = n; }   // 无 onlyOwner
    function drain() external { (bool ok,) = owner.call{value:address(this).balance}(""); }
}
// 修复：OpenZeppelin Ownable + Initializable
contract Safe is OwnableUpgradeable, Initializable {
    function initialize(address o) external initializer { __Ownable_init(o); }
    function setOwner(address n) external onlyOwner { _transferOwnership(n); }
}
```
**防御**：统一用 OZ `Ownable`/`AccessControl` + `onlyOwner`/`onlyRole`；upgrade 路径加访问控制与非空/接口校验；`initialize` 加 `initializer` 守卫并在实现合约构造里 `_disableInitializers()`；高权限走多签+timelock。来源：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
**检测手段**：Slither 的 ` unprotected-upgrade`、`uninitialized-state`、`function-init-state`、`tx-origin`、`suicidal` 等检测器；Mythril 能证明"任意 sender 可触达 selfdestruct / 写 owner"的路径（如 Unprotected Selfdestruct 反例）；审计 checklist 逐项核对每个 state-changing 函数的 caller 限制。

### 4. 闪电贷攻击（Flash Loan）

**原理**：闪电贷允许你在**同一笔交易/同一区块内**无抵押借入巨额资金，只要块末归还本金+手续费即可。它本身中性，但给了攻击者"**瞬间无限购买力**"，用来在低流动性池里砸穿价格、伪造抵押估值，再借走真实资产，块末还掉闪电贷，净赚。

**常见组合模式**：
- **闪电贷 + DEX 现货操纵**：借巨量 USDC 砸 TOKEN/DAI 池 → TOKEN 现货暴涨 15–20x → 用被吹大的 TOKEN 作抵押在借贷协议借走 USDC/ETH → 还闪电贷离场。
- **闪电贷 + 预言机 staleness/push 延迟**：借量砸池，但目标协议读的是尚未更新的 push 喂价（Heartbeat/Deviation 未触发），按旧高价放款。
- **闪电贷 + 治理攻击**：借巨量 token 在治理快照/投票窗口内获得临时多数，通过恶意提案抽走金库（如 Beanstalk $182M 案例，https://unified-labs.ghost.io/ 、https://nomoslabs.io/archive/deus-finance-2022 ）。

最小伪代码（Aave 风格回调结构）：
```solidity
function attack() external {
    assets[0] = DAI; amounts[0] = 50_000_000 ether;
    lender.flashLoan(address(this), assets, amounts, modes, params, 0);
}
function executeOperation(...) external returns (bool) {
    // 1) 砸池吹高 TOKEN 现货
    router.swapExact(amountBorrowed, minSwapOut, [DAI, TOKEN], address(this), block.timestamp);
    // 2) 用吹大的 TOKEN 作抵押借走真实资产
    lending.deposit(TOKEN, pumped);
    lending.borrow(DAI, borrowable, 2, 0, address(this));
    // 3) 归还闪电贷（本金+费），净赚 borrowable - 成本
    require(bal(DAI) >= amountToRepay, "cannot repay");
    IERC20(DAI).approve(lender, amountToRepay);
    return true;
}
```
**防御**：
- **用存储值替代即时查询**——不要每次 `getReserves()`/`slot0()` 现读，改为**链上累积的 TWAP/EMA**（≥30min 窗口），使单块操纵不经济；
- **staleness 校验**：push 预言机必须检查 `updatedAt` 是否在最大延迟内、`answeredInRound >= roundId`；
- **熔断（circuit breaker）**：单块/单次估值变动 >X%（如 3–5%）立即冻结该市场；
- **两步/跨块**：抵押存入与 `borrow()` 分块执行（block N 存、N+1 才可借），天然屏蔽单块闪电贷；
- 多源交叉验证 + 最低流动性门槛。
（来源：https://unified-labs.ghost.io/ 、https://academy.exmon.pro/flash-loan-oracle-attacks-exploiting-price-delays-in-defi 、https://chain.link/education-hub/market-manipulation-vs-oracle-exploits ）
**检测手段**：审计重点看"价格来源→决策动作"是否同一事务内闭环可操纵；用 **fork 测试 + Echidna/Foundry 不变量**模拟"注入巨额闪电贷 swap 后不变量是否被破坏"（守恒/偿付性）；检查是否存在即时现货查询、缺失 staleness 校验、缺失熔断与跨块隔离。

---

## 参考来源（高质量）
1. Slither — https://github.com/crytic/slither （及 Usage/SlithIR wiki：https://github.com/crytic/slither/wiki/Usage ）
2. Echidna — https://github.com/crytic/echidna ；Trail of Bits 博客：https://blog.trailofbits.com/2023/07/21/fuzzing-on-chain-contracts-with-echidna/
3. Foundry 测试/Cheatcodes — https://getfoundry.sh/forge/cheatcodes 、https://www.getfoundry.sh/forge/testing ；不变量：https://www.getfoundry.sh/guides/invariant-testing
4. Mythril — https://github.com/ConsenSysDiligence/mythril （SWC 分类：https://swcregistry.io/ ）
5. Halmos — https://github.com/a16z/halmos 、https://github.com/a16z/halmos-cheatcodes 、https://a16zcrypto.com/posts/article/symbolic-testing-with-halmos-leveraging-existing-tests-for-formal-verification/
6. OpenZeppelin Ownable / 可升级合约 — https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol 、https://docs.openzeppelin.com/upgrades-plugins/writing-upgradeable
7. OWASP 智能合约 Top10（SC10 代理与可升级性）— https://owasp.org/www-project-smart-contract-top-10/2026/en/src/SC10-proxy-and-upgradeability-vulnerabilities.html
8. 预言机操纵 / 闪电贷（Cyfrin、SCFG、Deus/Beanstalk 案例、ExMon）— https://www.cyfrin.io/blog/price-oracle-manipulation-attacks-with-examples 、https://scsfg.io/hackers/oracle-manipulation 、https://nomoslabs.io/archive/deus-finance-2022 、https://unified-labs.ghost.io/ 、https://chain.link/education-hub/market-manipulation-vs-oracle-exploits

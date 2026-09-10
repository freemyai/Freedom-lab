# 白帽（Whitehat）成长路径调研

> 本文面向个人加密安全学习路线，聚焦「智能合约白帽」方向。内容基于公开资料整理，合规部分仅陈述事实性通行做法与平台公开政策，**不构成法律建议，具体以当地法律及项目官方披露政策为准**。

---

## 一、学习资源：智能合约安全系统学习路径

建议按「入门 → 进阶」分档，避免一开始就啃 DeFi 组合攻击而地基不稳。整体主线是：**语言/VM 基础 → 单合约漏洞 → DeFi 组合攻击 → 真实审计/赏金实战**。

### 入门档（0–3 个月：打地基）
- **Solidity 语言与 EVM 基础**：先能读懂合约、理解 gas、存储布局、回调/委托调用语义。推荐 Foundry（forge + anvil + cast）作为开发与本地分叉工具链，白帽 PoC 基本都靠它。
- **Secureum — Smart Contract 101**：面向零基础的免费结构化课程，从区块链、Solidity 到常见漏洞（重入、访问控制、整数、事件/日志）系统入门，是公认的入门起点。来源：https://www.secureum.xyz/
- **Ethernaut（OpenZeppelin）**：关卡制入门 wargame，逐关解锁，覆盖 storage/委派调用/签名/重入/flashloan 等，适合把概念落到可运行代码上。来源：https://ethernaut.openzeppelin.com/ ；仓库 https://github.com/OpenZeppelin/ethernaut
- **Damn Vulnerable DeFi**：DeFi 漏洞「训练场」，18 关从闪贷、预言机到治理/NFT/升级性，是入门→进阶的桥梁（详见第二节）。来源：https://damnvulnerabledefi.xyz/
- **播客/YouTube（建立语感与案例库）**：
  - **Off by a Byte**：智能合约安全访谈播客，嘉宾多为一线审计/白帽，帮助理解行业与漏洞生态。
  - **Epicenter（Dan Guido / Trail of Bits）**：智能合约安全演化、Slither 静态分析等，适合了解工具与攻防史。来源（示例集）：https://podcasts.apple.com/us/podcast/dan-guido-trail-of-bits-the-evolution-of/id792338939?i=1000480333604
  - **Bankless / The Web3 Security Podcast**：偏行业与安全工程视角，跟进攻防趋势与 AI 审计现状。

### 进阶档（3–12 个月：真实攻防）
- **Trail of Bits 资源**：官方安全测试手册（Testing Handbook，覆盖静态/动态工具配置与自动化）、Slither（Solidity 静态分析器）、以及大量公开审计报告与白皮书，是进阶方法论的核心来源。来源：https://www.trailofbits.com/resources
- **Paradigm CTF**：偏研究性质的高质量合约安全竞赛（如 CTF-1/CTF-2），题目贴近真实协议设计，适合进阶者挑战组合攻击与新颖漏洞。
- **Immunefi 安全指南系列**：包括如何用 Foundry 写 PoC、如何优化攻击参数、真实 Hack 案例分析，直接对接赏金实战。来源：https://immunefi.com/blog/security-guides/how-to-submit-bug-reports-that-get-paid/ 与 https://immunefi.com/blog/security-guides/immunefi-poc-templates
- **真实案例复盘**：定期读 Immunefi 的 Hack Analyses 与各项目事后复盘（postmortem），把历史漏洞当作教材——理解攻击者视角与项目的修复取舍。

> 学习心法：**以练习场为主线，以真实案例为对照**。每学一类漏洞，就去 Damn Vulnerable DeFi / Ethernaut 找对应关卡验证，再读一份同类真实事故复盘，形成「概念 → 可复现 PoC → 真实影响」的闭环。

---

## 二、CTF 与练习场

### Damn Vulnerable DeFi（DvD）
- **定位**：安全研究员/开发/教育者的 DeFi 安全训练场，关卡设计思路是「还原真实 DeFi 组合攻击」——每一关都是一个最小可复现的攻击场景，而非孤立合约 bug。来源：https://damnvulnerabledefi.xyz/
- **关卡覆盖**（共 18 关）：Unstoppable、Naive receiver、Truster、Side Entrance、The Rewarder、Selfie、Compromised、Puppet、Puppet V2、Free Rider、Backdoor、Climber、Wallet Mining、Puppet V3、ABI Smuggling、Shards、Curvy Puppet、Withdrawal。涉及闪贷、价格/预言机操纵、治理、NFT、DEX、借贷池、智能合约钱包、timelock、vault、meta-transactions、代币分发、升级性。
- **怎么练（建议流程）**：
  1. 用官方 Foundry 模板本地起 mainnet 分叉（anvil fork），**不要**在真实主网操作。
  2. 每关先读题目描述 + 目标合约源码，画出「攻击者能调用什么、依赖什么状态」。
  3. 优先寻找「闪贷获取初始本金 → 操纵价格/状态 → 获利并回还闪贷」的骨架。
  4. 卡关时再看提示（hint）与官方 solution，但要**自己先把 PoC 跑通**再对照，避免「看懂了 ≠ 会做了」。
  5. 把每关抽象成「一类漏洞 + 一个攻击模式」，积累自己的攻击模式库。

### Ethernaut（OpenZeppelin）
- **定位**：Web3/Solidity wargame，灵感来自 overthewire.org，**100% 开源、关卡全部由社区贡献**，每关是一个需被「攻破」的合约。来源：https://ethernaut.openzeppelin.com/
- **用法**：连接 MetaMask，游戏直接在链上与 Ethernaut 合约交互，操作被记录在链上；支持网络含 Sepolia、Optimism/Arbitrum Sepolia、Holesky、Amoy（注意：主网不可用，游戏跑在测试网/本地区块链）。
- **进阶**：仓库提供本地部署方式（`yarn network` 起确定性 RPC → 导入私钥 → `yarn compile:contracts` → `yarn deploy:contracts` → `yarn start:ethernaut`），可完全离线/本地复现，适合深入调试与自定义关卡。来源：https://github.com/OpenZeppelin/ethernaut
- **与 DvD 的分工**：Ethernaut 偏「单合约 + 基础原语」，DvD 偏「多合约 DeFi 组合攻击」——建议先 Ethernaut 打基础，再 DvD 上强度。

### 其他练习场与赛事
- **Damn Vulnerable ERC-20 / 各类单合约靶场**：聚焦代币标准与基础逻辑漏洞，适合入门期反复打磨。
- **Capstone（Capstone 合约安全平台 / 审计竞赛）**：以真实合约做审计式练习，贴近商业审计工作流，进阶者用它练「读陌生代码 + 系统找漏洞 + 写发现」。
- **CTFtime 相关赛**：关注 CTFtime 上的 Web3 / 智能合约 / EVM 专题赛（如各类 EVM CTF、合约安全专题），是进阶者检验与社区交流的场所；参赛前务必确认赛事是否明确允许本地分叉、是否禁止真实资金操作。
- **通用原则**：任何练习只在**本地分叉或官方测试网**进行；真实资金/主网操作不在练习范围内。

---

## 三、第一份漏洞报告怎么写

高质量报告是白帽的「职业名片」。Immunefi 的口号是「excellent bug reports lead to excellent payouts」——报告质量直接决定受理率与赏金。来源：https://immunefi.com/blog/security-guides/how-to-submit-bug-reports-that-get-paid/

### 报告结构模板
1. **标题（Title）**：应包含漏洞分类 + 影响。示例：`Reentrancy in withdraw() leads to total loss of funds`、`Lack of access control in update() leads to griefing`、`Arithmetic error in calculateTotalRewards() can freeze unclaimed yield`。项目先读标题，要让人一眼看懂「什么漏洞 + 什么后果」。
2. **摘要 / Brief（Intro）**：一段话，说明问题是什么、若被在野利用后果如何。
3. **漏洞详情（Details）**：清晰、准确、不臆测；必要时附代码片段（别堆砌无关代码）。目标是让项目团队确信漏洞真实存在，且你完全理解它。
4. **严重性 / Severity**：按项目分级标准自评（Critical/High/Medium/Low）。参考分级（以 Stake DAO 为例）：Critical＝直接用户资金损失/未授权提现/资金永久冻结；High＝未结算收益被盗、治理/奖励操纵、特权函数访问控制绕过；Medium＝需大量资金才能达成的 griefing、错误奖励计算；Low＝无直接资金风险但应修复。来源：https://docs.stakedao.org/bug-bounty
5. **受影响资产 / Scope**：明确列出在 scope 内的合约地址、函数、链/网络；确认不在 out-of-scope（前端、第三方合约、测试网、已知已审计问题、需私钥泄露、社工等）。
6. **PoC 复现步骤**：提供**完整可运行**的 PoC（Foundry 测试或交易模拟），在**本地主网分叉**上验证；给出一键复现命令与预期输出。**绝不在主网/公共测试网真实执行利用**（否则视为恶意攻击）。来源：https://immunefi.com/blog/security-guides/immunefi-poc-templates
7. **根本原因（Root Cause）**：解释漏洞为何产生（设计/实现缺陷），而非只描述表象。
8. **修复建议（Suggested Fix）**：可选但强烈建议给出，体现专业度。
9. **影响量化（Impact / Economic damage）**：**明确写出可造成的最大经济损失**（优化攻击参数后的上界）。Immunefi 强调：不量化经济影响会拖慢流程并可能导致降级或不支付。

### 提交前自查清单
- [ ] 标题含漏洞分类与影响；项目读完标题即懂主题。
- [ ] 摘要、详情、影响三部分逻辑闭环，无「我自己都没想清楚」的臆测。
- [ ] PoC 完整可运行，本地分叉一键复现，附命令与输出。
- [ ] 已优化攻击参数，给出最大经济影响上界（量化金额）。
- [ ] 确认漏洞在 scope 内、未被审计已知覆盖、非重复报告。
- [ ] 严重性自评合理，不与事实夸大/不符。
- [ ] 无敏感主网真实操作；无私钥/助记词/他人数据泄露。
- [ ] 语言清晰、结构完整，**绝不是一行/三行的敷衍报告**（低质量报告会被直接关闭甚至封号）。

### 如何与项目 Triage 沟通
- 提交后**耐心等待**（Stake DAO 示例：首次响应最长 72 小时）；配合 triage 复现，及时补充信息、修正细节。
- 就修复时间线与项目团队协同；若项目对严重性/影响有分歧，可走 Immunefi 等平台的**中立调解（mediation）**流程，由第三方从技术角度评估双方主张并出具 Mediation Summary。来源：https://immunefi.com/blog/security-guides/how-to-submit-bug-reports-that-get-paid/
- 沟通基调：专业、克制、就事论事；不施压、不威胁、不公开施压。

### 提高被受理率的技巧
1. **Scope 内**：只报明确在 scope 的资产；越界报告直接无效。
2. **影响真实**：量化、可验证的经济/安全影响，拒绝「理论性」空谈（Stake DAO 明确：无 PoC 的理论漏洞 out-of-scope）。
3. **PoC 可复现**：本地分叉、一键复现、附输出；这是「de facto 标准」。
4. **第一有效报告**：多数项目仅奖励首个有效报告，且「同一根因一个赏金」。
5. **遵守负责任披露**：不公开披露前提交，公开披露将失去赏金资格。来源：https://docs.stakedao.org/bug-bounty

---

## 四、合规注意事项

> 本节仅为事实性通行做法与公开政策概述，**不构成法律建议；法律边界因司法辖区与具体项目政策而异，务必以当地法律与项目官方披露政策为准**。

### 负责任披露（Responsible Disclosure）
- 核心：发现漏洞后**先私下报告、给予项目合理修复时间，期间不公开**。多个平台（如 Immunefi）明确「公开披露 = 失去赏金资格」，甚至可能触发封禁。
- 平台通常提供**调解机制**处理白帽与项目的争议，鼓励通过正式渠道而非舆论施压。来源：https://immunefi.com/blog/security-guides/how-to-submit-bug-reports-that-get-paid/

### 白帽法律边界（PoC 边界 / 资金边界）
- **不实际提取/转移真实资金**：PoC 只应在**本地主网分叉或测试网**演示，主网真实执行利用通常被平台定性为「恶意攻击」，会导致永久封禁（Immunefi 明文规定在 mainnet/public testnet 测试利用＝恶意攻击＋永久 ban）。来源：https://immunefi.com/blog/security-guides/how-to-submit-bug-reports-that-get-paid/
- **PoC 边界**：以「可复现漏洞存在」为限，不过度利用、不扩大破坏、不触碰与漏洞无关的资产。
- **多签/资产证明要求**：部分平台/项目要求提交者证明攻击所用账户/资金的来源与归属（例如用自有账户、可控本金），以区分白帽验证与真实攻击行为；具体以各平台政策为准。
- 通行做法：保留完整复现记录、账户与交易时间线，作为「善意验证」的证据。

### 赏金平台政策 vs 私有 Bug Bounty 的差异
- **平台化项目（如 Immunefi）**：统一政策、公开 scope 与分级、平台担保与调解、按 severity × 实际影响定赏金（金额区间在页面公示，如 Stake DAO：Critical 最高 $100k / High $25k / Medium $5k）。
- **私有/项目自建 Bug Bounty**：政策更个性化，scope 与奖励标准需逐项目阅读；有的项目（如 Stake DAO）直接邮件提交、明确 72 小时响应、列明 in/out-of-scope 与规则（含「服务方与近期贡献者无资格」「同一根因一个赏金」等）。来源：https://docs.stakedao.org/bug-bounty
- 关键区别：私有项目的「法律豁免/授权范围」是否明确、是否含 safe-harbor 条款、争议如何处理，往往不如平台化项目规范——**提交前务必逐条读清该项目的披露政策**。

### 不同司法辖区法律风险（简述）
- 各法域对「未授权访问/操作智能合约」的定性不同：有的按计算机未授权访问类法律（如美国 CFAA 相关判例倾向），有的更依赖项目披露政策中的**授权/豁免（safe harbor）**来界定白帽合法性。
- 现实做法：白帽通常依赖「项目明确授权范围内、负责任披露、仅本地/测试网 PoC、不提取资金」这一组合来降低法律风险；**具体以当地法律与项目政策为准**。
- 建议：跨法域活动前，先确认所在法域与目标项目法域的规则，必要时咨询专业法律意见。

### 与黑灰产的法律区分
- **意图与授权**：白帽＝在授权/scope 内、负责任披露、不窃取真实资金；黑灰产＝无授权、以窃取/转移真实资产或破坏为目的、不披露。
- **行为边界**：是否在主网真实提取/转移他人资金、是否公开勒索/威胁、是否造成实际损失，是区分白帽验证与攻击的关键事实要素。
- **证据留存**：白帽保留本地分叉 PoC、复现记录与善意沟通记录，是证明自身为「验证者而非攻击者」的核心依据。

---

## 参考来源
1. Immunefi — How to Submit Bug Reports That Get Paid：https://immunefi.com/blog/security-guides/how-to-submit-bug-reports-that-get-paid/
2. Immunefi — PoC Templates（含 forge-poc-templates、Foundry PoC 教程链接）：https://immunefi.com/blog/security-guides/immunefi-poc-templates
3. Stake DAO — Bug Bounty Program（scope / severity / 提交流程 / 规则）：https://docs.stakedao.org/bug-bounty
4. Ethernaut（OpenZeppelin）：https://ethernaut.openzeppelin.com/ ；仓库与本地部署：https://github.com/OpenZeppelin/ethernaut
5. Damn Vulnerable DeFi（18 关清单与训练场定位）：https://damnvulnerabledefi.xyz/
6. Trail of Bits — Resources（Testing Handbook、Slither、审计/白皮书）：https://www.trailofbits.com/resources
7. 播客：Epicenter「Dan Guido: The Evolution of Smart Contract Security」：https://podcasts.apple.com/us/podcast/dan-guido-trail-of-bits-the-evolution-of/id792338939?i=1000480333604 ；Bankless / The Web3 Security Podcast（AI 与合约安全趋势）。

> 注：Secureum（Smart Contract 101）、Off by a Byte、Paradigm CTF、Legal Bug Bounty 等为本领域公认资源；本次网络环境下部分站点抓取受限，其要点为行业通行认知，建议自行访问官方页面核对最新版本。

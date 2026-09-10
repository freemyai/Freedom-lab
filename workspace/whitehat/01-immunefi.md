# Immunefi 漏洞赏金平台 · 白帽方向调研报告

> 调研目的：为个人加密（Web3）安全白帽学习路线做背景研究。
> 说明：文中关键事实均标注来源 URL；查不到或不确定的数字已明确标注"未查到/不确定"。所有数字以来源发布时点为准，平台数据随时间增长。

---

## 1. 平台市场概况

### 1.1 是什么
Immunefi 是 Web3（区块链 / 智能合约 / DeFi）领域的**赏金（bug bounty）与安全服务平台**，本质上是把"项目方"和"安全研究员（白帽）"撮合到一起：研究员负责任责披露（responsible disclosure）漏洞，项目方按漏洞严重性支付奖励，平台提供安全的报告看板（dashboard）、分诊（triage）与托管服务。它**与链无关（chain-agnostic）**，覆盖所有公链与网络上的项目。（来源：https://immunefi.com/projects ）

### 1.2 成立背景
- 平台**上线于 2020 年 12 月（2020-12-09 上线）**，创始团队 / CEO 为 **Mitchell Amador**。（来源：https://immunefi.com/press ；https://immunefi.com/about ）
- 成立动因：Web3 每年因黑客 / 骗局损失数十亿美元（Immunefi 称 2022 年单年损失约 40 亿美元），安全性被视为 Web3 普及的最大障碍之一，因此通过"事前披露"的方式防止黑客。（来源：https://immunefi.com/press ）
- 行业背景：传统 bug bounty 概念最早可追溯到 1983 年 Hunter & Ready、1995 年 Netscape 工程师 Jarrett Ridlinghafer 首次使用"Bug Bounty"一词；Web3 因"漏洞直接对应资金损失"，赏金量级远高于 Web2。（来源：https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ ）

### 1.3 行业地位
- 官方定位：**Web3 赏金平台的市场领导者 / 行业第一**，"世界最大的赏金"都集中在这里。官网宣称 **"92% 的 Web3 关键漏洞在此被报告"**（注意：这是平台的**营销口径**，非独立审计数据）。(来源：https://immunefi.com/bug-bounty-program ；https://immunefi.com )
- 第三方（The Block）也确认其为 Web3 赏金平台龙头。（来源：https://www.theblock.co/news/regulation/2024-06-20-web3-immunefi-ethical-hacker-payouts-301025 ）

### 1.4 可查证的规模数字（随时间演进，均标注来源与口径）
| 指标 | 数字 | 时点 | 来源 |
|---|---|---|---|
| 累计已支付赏金 | 突破 **$100.21M**，来自 **3000+ 份已付费报告** | 2024-06 | https://www.theblock.co/news/regulation/2024-06-20-web3-immunefi-ethical-hacker-payouts-301025 |
| 累计已支付赏金 | "已支付 **$110,000,000+**" | 官网黑客页 | https://immunefi.com/hackers |
| 累计已支付赏金 | **$116M+** | 官网 About | https://immunefi.com/about |
| 累计已支付赏金 | **$125M+** | 官网 Bug Bounty 页 | https://immunefi.com/bug-bounty-program |
| 历史分年度支付 | 总计 **$65.9M**：2021 年 **$13.4M** + 2022 年 **$52.5M** | 2022 年度报告 | https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ |
| 保护资产（assets under protection） | **$190B+** | 官网 | https://immunefi.com/press |
| 避免的链上损失（hacks prevented） | **$25B+** | 官网 | https://immunefi.com/about |
| 白帽 / 安全研究员数量 | **60,000+** whitehats；另一页称 **83,000+ 注册研究员**（口径不同） | 官网 | https://immunefi.com/about ；https://immunefi.com/bug-bounty-program |
| 上项目 / 协议数量 | **500+ protocols**（早期口径 330+ projects、650+ customers，口径不一致） | 官网 | https://immunefi.com/about ；https://immunefi.com/press |

> 注意：不同页面数字不一致（$100M/$110M/$116M/$125M；60k/83k 研究员；330/500/650 项目），原因是页面更新时间与统计口径（"protocols" vs "customers" vs "projects"）不同。上文按来源分别标注，**不做合并**。

### 1.5 产品线扩展
除基础 bug bounty 外，Immunefi 自 2024 年起扩展了：审计竞赛（Audit Competitions）、Attackathons、邀请制项目（Invite-Only Programs）、审计（Audits）、PR 审查（PR Reviews），并于 2025 年推出统一 SecOps 平台 **Magnus**。（来源：https://immunefi.com/about ）

---

## 2. 上项目的类别分布（附代表性项目）

Immunefi 是链无关平台，覆盖 DeFi、L1/L2 公链、跨链桥 / 基础设施、NFT / 游戏、服务等。可从两类数据观察其分布：

### 2.1 按"已付费报告类型"分布（官方报告，可查证）
（来源：https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ ）
- **智能合约（Smart Contracts）**：报告数占比 **58.3%**（728 份），**金额占比 89.6%**（$59.1M）——是绝对主力。
- **网站与应用（Websites/Apps）**：报告数 **39.1%**（488 份），金额仅 **2.9%**（$1.9M）。
- **区块链 / DLT**：报告数 **2.6%**（32 份），金额 **7.4%**（$4.9M）。

结论：**资金风险高度集中在智能合约**（DeFi/协议合约），这也是大额赏金的来源。

### 2.2 按业务类别的常见上项目（来自官网客户名与具体项目页）
- **DeFi（去中心化金融）**：SushiSwap、MakerDAO/Sky、Alchemix、GMX、Balancer、Pendle、Morpho、Ethena、Badger DAO、Puffer 等（官网客户墙）。(来源：https://immunefi.com ；https://immunefi.com/projects )
- **L1 / L2（公链与扩容）**：Polygon、Optimism、Berachain、Sei、Scroll、Stacks、Babylon、Arbitrum 等。(来源：https://immunefi.com 客户名 )
- **跨链桥 / 基础设施**：Wormhole（跨链消息协议）、LayerZero（跨链消息）、The Graph（索引）、Chainlink（预言机）、Hyperlane、OpenZeppelin（合约库，分类 DeFi/Exchange/NFT/Services）。(来源：https://immunefi.com/bug-bounty/wormhole/resources ；https://immunefi.com/bug-bounty/openzeppelin ；https://techcrunch.com/2023/05/17/layerzero-and-immunefi-launch-largest-crypto-bug-bounty-program-with-up-to-15m-in-rewards/ )
- **NFT / 游戏**：Immutable（游戏，最大赏金 $1,000,000）。(来源：https://immunefi.com/bug-bounty/immutable )
- **交易所 / 钱包**：具体代表性项目**未查到**官网明确单列（OpenZeppelin 项目页分类含"Exchange"，但代表性交易所项目名不确定）。

---

## 3. 历史最高 payout 案例（3–5 个，具体项目 / 年份 / 金额 / 漏洞类型）

| # | 项目 | 年份 | 金额 | 白帽 | 漏洞类型 | 来源 |
|---|---|---|---|---|---|---|
| 1 | **Wormhole**（跨链桥） | 2022（2 月报告，5 月公布） | **$10,000,000** | satya0x | 核心桥合约"可升级代理自毁（uninitialized / upgradeable proxy self-destruct）"漏洞，可致合约被接管；当日验证并修复，0 损失 | https://www.theblock.co/news/regulation/2022-05-20-wormhole-announces-10-million-bug-bounty-payout-148085 ；https://www.gate.com/blog/Wormhole-has-announced-a--10-million-bug-bounty-payout |
| 2 | **Aurora**（Ethereum 桥/扩容，Rainbow Bridge） | 2022 | **$6,000,000** | pwning.eth | 桥合约"通胀/提币逻辑错误（inflation / withdrawal logic error）"，涉及桥资产增发 | https://immunefi.com/blog/bug-fix-reviews/aurora-inflation-spend-bugfix-review-6m-payout/ ；https://cryptobriefing.com/biggest-bounty-in-history-paid-to-whitehat-hacker/ |
| 3 | **Polygon**（L2/扩容） | 2022 | **$2,200,000** | Leon Spacewalker | 关键漏洞（官方 bugfix review 归类为"缺少余额检查"类） | https://immunefi.com/hackers ；https://immunefi.com/blog/bug-fix-reviews/polygon-lack-of-balance-check-bugfix-review-2-2m-bounty/ |
| 4 | **Optimism**（L2） | 2022 | **$2,000,000** | Saurik | 关键漏洞 | https://immunefi.com/hackers |
| 5 | **Belt Finance**（BSC 稳定币 AMM） | 2021 | **$1,050,000** | 未注明化名 | 关键漏洞，曾使 $10M+ 资金面临风险 | https://www.bnbchain.org/en/blog/belt-finance-pays-the-biggest-bug-bounty-1million-under-immunefi-and-bscs-priority-one |

补充（官方 Top 5 汇总）：另有 **Armor**（DeFi 资产保险）$1.5M；以上 Top 5 合计约 $21.7M，其中仅 Wormhole 一笔就超过 Google 2021 年全部漏洞奖励计划的总和（$8.7M）。（来源：https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ ）

> 关于"最大赏金计划"（区别于"最大单笔 payout"）：**LayerZero** 于 2023 年 5 月推出最高 **$15M** 的赏金计划，为当时加密圈最大（超过 MakerDAO 的 $10M 计划）；The Graph 2021 年曾推出最高 $2.5M 的"史上最大"计划（早期）。（来源：https://techcrunch.com/2023/05/17/layerzero-and-immunefi-launch-largest-crypto-bug-bounty-program-with-up-to-15m-in-rewards/ ；https://immunefi.com/blog/customers/the-graph-joins-immunefi-with-the-worlds-largest-bug-bounty-in-history-2-5-million-immunefi-immunefi ）

---

## 4. Scope（范围）规则要点

### 4.1 in-scope / out-of-scope 如何定义
- **In-scope 由"每个项目各自的 Assets in Scope 表"定义**，不是平台统一表。例如 Wormhole 明确："在 Assets in Scope 表中的资产才在范围内；in-scope 项必须是**已上线主网，或处于准备部署的活跃 GitHub release** 中的代码。"(来源：https://immunefi.com/bug-bounty/wormhole/resources )
- 每个项目页都有独立的 Scope 页面（如 `/scope`），列出各严重等级对应的 impact 列表与 out-of-scope 项（如 NUVA 项目页）。(来源：https://immunefi.com/bug-bounty/nuva/scope )
- **Out-of-scope 采用平台"默认排除清单" + 项目自定义追加**的方式。平台有一份"Common Vulnerability Exclusion List"作为默认推荐排除项，实际清单因项目而异。(来源：https://immunefi.com/common-vulnerabilities-to-exclude )

### 4.2 资产证明 / 影响门槛（PoC 与 impact）
- **PoC（概念证明）通常必填**：许多项目页标注 "PoC Required"，若项目要求 PoC 而报告无 PoC 或不完整，属违规、可导致 0 奖励。(来源：https://immunefi.com/rules ；各项目页如 https://immunefi.com/bug-bounty/immutable )
- **PoC 必须在本地 fork 上复现**，禁止直接在 mainnet / 公共 testnet 上测试（默认禁止项）。(来源：https://immunefi.com/common-vulnerabilities-to-exclude )
- **影响门槛按"受直接影响资金"计算**：Critical 智能合约漏洞奖励 = **受影响资金（funds directly affected）的 10%**，封顶到该项目最高奖励；并设"最低奖励"以防研究者扣报。以提交报告时间点的在险资金计算。(来源：https://immunefi.com/bug-bounty/immunefi ；https://immunefi.com/bug-bounty/immutable )
- 报告需包含复现所需的日志/代码与修复建议（以 The Graph 计划为例）。(来源：https://immunefi.com/blog/customers/the-graph-joins-immunefi-with-the-worlds-largest-bug-bounty-in-history-2-5-million-immunefi-immunefi )

### 4.3 严重性分级与奖励表
- 采用**简化 5 级：Critical / High / Medium / Low / Informational**，跨 Smart Contracts、Blockchain/DLT、Websites & Apps 三大类各自定义 impact。(来源：https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-3 ；https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ )
- 各档**奖励表由项目自定义**（平台提供"impact 表"模板），示例（项目自定，非统一）：
  - Immunefi 自身项目：Smart Contract Critical 最高 $50,000（=10% 受影响资金，最低 $10,000）。(来源：https://immunefi.com/bug-bounty/immunefi )
  - Wormhole：Critical 最高 $1,000,000，分 Tier（提取全链 TVL $1M / 单链 $500k / 永久锁死 $250k），且部分受 Governor 机制 24h 可提取值的 10% 封顶。(来源：https://immunefi.com/bug-bounty/wormhole/information )
  - OpenZeppelin：Critical 最高 $25,000。(来源：https://immunefi.com/bug-bounty/openzeppelin )
- **金额向 Critical 极端集中**（官方报告）：Critical 占支付总额 **92.7%**，High 4.3%，Medium 1.7%，Low 0.7%，Informational 0.3%。(来源：https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ )
- 注：早期（v2.1/v2.2）分级表已逐步淘汰，现行以 **v2.3** 为主。(来源：https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-1 ；https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-3 )

### 4.4 重复报告 / 已修复问题政策
- 若报告覆盖**已知问题（known issue）**，可被拒绝（项目需给出已知证据）。(来源：https://immunefi.com/bug-bounty/immunefi )
- **报告已被公开披露过的 bug** 属白帽违规（见 4.5）。(来源：https://immunefi.com/rules )
- 联合提交（co-submitting）需对方同意；报告须"实质上是自己的"，否则违规。(来源：https://immunefi.com/rules )
- 平台对"no fix, no pay"有反向约束：禁止项目方**偷改（stealth fix）**漏洞后不付全款。(来源：https://immunefi.com/rules )

### 4.5 白帽 vs 黑帽披露政策
- **白帽必须获得项目方在 Immunefi Dashboard 中的明确书面同意，才能进行"以保全用户/协议资金为目的"的白帽利用（whitehacking）**；未经授权的攻击 / 威胁攻击一律禁止。(来源：https://immunefi.com/rules )
- **禁止任何对 Immunefi 或项目的钓鱼 / 社工**。(来源：https://immunefi.com/rules ；https://immunefi.com/common-vulnerabilities-to-exclude )
- **禁止对 embargoed（保密）赏金的未修复漏洞公开披露**——这是默认禁止项之一。(来源：https://immunefi.com/common-vulnerabilities-to-exclude ；https://immunefi.com/bug-bounty/immunefi )
- **必须走 Immunefi 看板沟通**；绕过平台直接联系项目方 / 白帽进行谈判属无效且违规。(来源：https://immunefi.com/rules )
- 平台提供 "Responsible Publication / Responsible Disclosure" 机制（官网导航含 Responsible Publication 入口）。(来源：https://immunefi.com )

### 4.6 对 false positive 与 malicious activity 的限制
**白帽禁止行为（节选，来源：https://immunefi.com/rules ）：**
- **误报 / 占位报告**：提交"标题含糊、细节极少、无可复现步骤"的占位报告（placeholder bug）属违规。
- **夸大影响（misrepresenting impacts）**：选择不适用的 impact。
- **无 PoC 或 PoC 不完整**（项目要求时）。
- 自动生成大量流量的自动化测试、对项目的 DoS 攻击。
- 威胁发布 / 发布他人隐私信息、勒索 / 恐吓、骚扰、"beg bounty"（讨赏）、向 Immunefi/项目索取 gas 费。
- 创建多个账号、发布非法内容、提交非本人成果。
- 违规后果：临时封禁 / 永久封禁，且对**白帽可能导致"没收并失去访问 bug 报告 + 0 奖励"**。

**默认禁止的测试行为（来源：https://immunefi.com/common-vulnerabilities-to-exclude ）：**
- 在 mainnet / 公共 testnet 已部署代码上测试（应本地 fork）。
- 测试价格预言机或第三方合约、第三方系统/应用（浏览器扩展、SSO 等）。
- 对 project assets 发起 DoS。
- 对保密赏金未修复漏洞公开披露。

**默认 out-of-scope（默认推荐排除，来源：https://immunefi.com/common-vulnerabilities-to-exclude ）：**
- 最佳实践建议、功能请求、仅影响测试文件/配置文件的影响（除非项目另说明）。
- 仅缺 HTTP 安全头 / cookie 标志且无实际影响演示、服务端非机密信息泄露（IP/服务名/栈追踪）、纯 UI/UX、浏览器/插件自身缺陷、非敏感 API key 泄露、SPF/DMARC 等（见 v2.3 分类页）。

### 4.7 KYC 与付款
- 许多项目 **KYC required**，需在合理时间内提交 KYC，否则可没收付款；提供虚假 KYC 属违规。付款常以 USDC（USD 计价）支付，由项目或 Immunefi 团队直接处理。(来源：各项目页，如 https://immunefi.com/bug-bounty/immutable ；https://immunefi.com/bug-bounty/immunefi ；https://immunefi.com/rules )

---

## 5. 对白帽学习路线的启示（小结）
1. **资金风险 = 高价值**：智能合约 Critical 是赏金主体（金额占比 ~90%），学习重点应放在 DeFi/智能合约（Solidity/Rust）的资损类漏洞（重入、代理升级、桥提币逻辑、余额检查、治理操纵）。
2. **PoC 是硬门槛**：几乎所有高价值项目都要求"本地 fork 可复现 PoC"，本地链复现能力是基本功。
3. **读懂每个项目的 Scope 表与 Assets in Scope**：范围因项目而异，in-scope 资产必须"已上线或活跃 release"。
4. **合规红线清晰**：不要 mainnet 测试、不要未授权 whitehack、不要公开未修复 embargo 漏洞、不要占位/夸大报告——违规直接 0 奖励甚至封号。
5. **历史案例是最好的教材**：Wormhole（代理升级自毁）、Aurora（桥通胀/提币逻辑）、Polygon（缺余额检查）等官方 bugfix review 都附详细拆解，是免费的高质量学习材料。

---

## 来源清单（8 个主要来源）
1. https://immunefi.com/press — 平台概况、上线时间、规模
2. https://immunefi.com/about — 成立背景、CEO、产品线、规模
3. https://immunefi.com/hackers — 白帽奖励、Top 单笔 payout
4. https://www.theblock.co/news/regulation/2024-06-20-web3-immunefi-ethical-hacker-payouts-301025 — $100M 里程碑、报告数
5. https://immunefi.com/blog/research/top-crypto-bounty-and-ransom-payments-report/ — 历史 Top 5、类型/严重性分布、年度金额
6. https://immunefi.com/rules — 白帽/项目禁止行为、披露政策
7. https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-3 与 https://immunefi.com/common-vulnerabilities-to-exclude — 严重性分级、out-of-scope
8. 案例新闻：https://www.theblock.co/news/regulation/2022-05-20-wormhole-announces-10-million-bug-bounty-payout-148085 、https://techcrunch.com/2023/05/17/layerzero-and-immunefi-launch-largest-crypto-bug-bounty-program-with-up-to-15m-in-rewards/ 、https://www.bnbchain.org/en/blog/belt-finance-pays-the-biggest-bug-bounty-1million-under-immunefi-and-bscs-priority-one 、https://immunefi.com/blog/bug-fix-reviews/aurora-inflation-spend-bugfix-review-6m-payout/

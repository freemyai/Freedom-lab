# 2026 年重大加密安全/黑客事件复盘（截至 2026-09-10）

> 说明：本报告仅采用公开报道，时间、金额与技术根因均来自来源方公开披露；凡未查到公开数字处均明确标注"未查到"。面向开发者与白帽研究者，每起事件附可操作防御启示，末尾做高频根因横向总结。
> 总量背景：据 CertiK Hack3d 2026 上半年报告、Forbes 及 TRM Labs 统计，2026 年前 8 个月加密领域被黑/被利用损失合计约 13 亿美元；TRM 对 H1 的口径为 207 起、约 9.72 亿美元（较 2025 年同期约 23 亿美元明显下降）。**结构性变化：被盗密钥/基础设施/凭证类攻击（约 15% 的事件数量）贡献了约 76% 的损失金额，智能合约漏洞（约 60% 的事件数量）只占约 17% 的损失**（来源：TRM Labs、CertiK、Coinliva、DEXTools News）。

---

## 事件一：Drift Protocol 被社工夺取管理员密钥后抽干（Solana）

- **时间**：2026-04-01（攻击前社工渗透自 2025 年末持续数月）
- **涉及项目**：Drift Protocol（Solana 上最大的永续交易所）
- **损失金额**：约 2.85 亿美元（USDC、SOL、ETH 等），TVL 从约 13 亿美元跌至约 4 亿美元
- **攻击手法概述**：攻击者长期伪装成量化交易公司，参加行业会议、在多国与 Drift 贡献者线下接触，建立信任后获取了 Drift 安全委员会的预签名授权（利用 Solana durable nonce 这一合法特性）。4 月 1 日借"常规预言机适配器升级"维护窗口，将攻击者控制的虚假代币 CVT 白名单注册为现货市场，以 CVT 作抵押、配合其已控制约三周的假预言机，并调用预签名授权将 USDC 等 5 个市场的提款上限改到 500 万亿（实质废除内部风控），随后在约 128 秒 / 约 12–22 分钟内通过 31 笔交易从近 20 个金库提走全部资产。
- **公开报道指出的技术根因**：并非智能合约逻辑漏洞，而是**被社工获取的管理员密钥 + 预签名授权（长期有效的 nonce）+ 预言机适配器可被单点变更 + 提款上限可被一次性拉满**。Solana 基金会主席 Lily Liu 与 CPO Vibhu Norby 均确认根因是"社会工程与运营安全失败，而非代码级漏洞"。
- **防御教训**：
  1. **任何预言机适配器/价格源变更必须走带时间锁的多方授权**，禁止单一管理员即时生效；新代币（尤其来自零历史地址）注册要挂起人工复核。
  2. **对金库提款设置"窗口内最大占比"阈值，超过即触发多签升级/熔断**；不要把"提款上限"做成可由单一密钥即时调大的参数。
  3. **预签名/持久 nonce 授权必须短生命周期、可吊销**，并纳入密钥轮换与最小权限；对核心贡献者做反社工培训与"敏感授权双人到场"流程。
- **来源**：
  - https://crypto.news/defi-hacks-2026-billion-lost-same-attack-keeps-working
  - https://coinhubtoday.com/drift
  - https://mexc.fm/tr-CT/news/1000307
  - https://coingabbar.com/en/crypto-currency-news/top-crypto-hacks-2026-largest-crypto-security-incidents

---

## 事件二：KelpDAO 跨链桥单验证者被攻陷（LayerZero）

- **时间**：2026-04-18（前置渗透：2026-03-06 社工一名 LayerZero Labs 开发者）
- **涉及项目**：KelpDAO / LayerZero 跨链桥
- **损失金额**：约 2.90–2.92 亿美元（约 116,500 枚 rsETH，无抵押铸造）
- **攻击手法概述**：3 月 6 日，攻击者通过社会工程获取一名 LayerZero Labs 开发者的会话密钥（session key），随后污染了为 LayerZero 验证者网络供数的 RPC 基础设施，并用 DDoS 使外部验证节点"静默"。4 月 18 日，被攻陷的单个验证者签发了伪造的跨链消息，桥据此铸造了 116,500 枚无抵押 rsETH。攻击者随即把 rsETH 存入 Aave 作抵押、借出真实 WETH 后转移，Aave TVL 在 48 小时内骤降 62.8 亿美元，9 个协议冻结市场。Arbitrum 安全委员会动用紧急权力链上冻结了攻击者钱包中 30,766 枚 WETH。
- **公开报道指出的技术根因**：**单一验证者（single verifier）架构**——KelpDAO 桥只用了 1 个验证者而非多个交叉校验；一旦攻击者拿到该验证者后端服务器的访问权限，就能推送链上看起来完全合法的伪造确认。基础设施方事后承认其允许了"不适合承载此规模资产的配置"。
- **防御教训**：
  1. **跨链消息必须多验证者（≥N 个独立节点）联合签名/阈值校验**，拒绝单点验证者承载大额资产；验证者节点与供数 RPC 要做隔离与抗 DDoS 冗余。
  2. **桥的铸造逻辑要与真实存款实时对账**，出现"铸造无抵押"或跨链消息速率/金额异常时自动暂停铸造（pause-on-anomaly）。
  3. **开发者会话密钥必须短生命周期 + MFA + 异常登录告警**，对能触达验证者/RPC 基础设施的人员权限做最小化与审计日志。
- **来源**：
  - https://crypto.news/defi-hacks-2026-billion-lost-same-attack-keeps-working
  - https://coingabbar.com/en/crypto-currency-news/top-crypto-hacks-2026-largest-crypto-security-incidents
  - https://mexc.fm/en-GB/news/1068425

---

## 事件三：Coldcard 硬件钱包固件熵缺陷被盗（用户重点询问项）

- **时间**：2026-07-30 起（漏洞可追溯至 2021 年 3 月发布的 4.0.1 固件）
- **涉及项目**：Coinkite Coldcard（Mk2/Mk3/Mk4/Mk5/Q 各系列硬件钱包）
- **损失金额**：约 1,816 BTC，价值约 1.16 亿美元（Galaxy Research 滚动统计；另有 CoinDesk 报道早期 8 月初估算最高约 1.14 亿美元；数字为初步值，仍在变动）
- **攻击手法概述**：攻击者利用 Coldcard 受影响固件生成私钥时**熵（随机性）被削弱**这一事实，离线暴力枚举出对应私钥，无需物理接触设备即可转走比特币。自 7 月 30 日起出现至少 4 波盗窃，波及 5,200+ 个地址。Coinkite 已于 8 月敦促受影响客户转移比特币。
- **公开报道指出的技术根因**：**2021 年 3 月 4.0.1 固件的一个构建配置错误**，导致部分设备在生成钱包种子时**回退到弱软件随机数生成器（RNG），而非设备硬件熵源**，使有效密钥强度从设计的 128 位降到最低约 40 位，可被现代算力暴力破解。更新固件只能修复"未来"的种子生成，**不能修复已在受影响固件下生成的既有种子**——这些种子应视为已泄露，必须换种迁移。
- **查证结论（回应用户）**：✅ **Coldcard 在 2026 年确有公开报道的安全事件**，且为本年度最大硬件钱包被盗事件之一，根因为固件熵/随机数缺陷（属"供应链/固件"类），而非私钥被单独窃取或供应链投毒。Coinkite 已发布安全公告与修复固件，但截至 2026-08-13 正式技术 postmortem 仍在进行中。
- **防御教训**：
  1. **对固件/设备做熵源审计**：验证种子/密钥生成确实落在硬件 RNG 路径上，而非静默回退到软件 RNG；CI 中加"熵源路径"回归测试与可复现构建。
  2. **固件更新 ≠ 密钥安全**：凡在受影响版本下生成的密钥，升级后仍须换种迁移；建立"受影响版本清单 + 迁移指南 + 指纹/接收地址校验"的标准流程，迁移先小额测试转账。
  3. **纵深防御**：大额钱包组合"独立设计设备 + 独立生成熵 + 多签"，降低对单一实现/单一厂商 RNG 的依赖；为重要钱包加 BIP-39 口令（passphrase）作为额外屏障。
- **来源**：
  - https://www.trmlabs.com/resources/blog/the-largest-hardware-wallet-exploit-of-2026-inside-the-usd-116-million-coldcard-hack
  - https://www.halborn.com/blog/post/explained-the-coldcard-hack-july-2026
  - https://coldcard.com/security/status
  - https://ibtimes.com/bitcoin-network-lost-320-million-hack-attackers-say-theyre-good-guys-3807199

---

## 事件四：Liquid Network 联邦钱包被盗（"自称白帽"）

- **时间**：2026-09-06 / 09-07 公开
- **涉及项目**：Liquid Network（Blockstream 开发的比特币侧链，80+ 交易所/机构联邦）
- **损失金额**：约 4,000 BTC，价值约 3.2 亿美元（联邦钱包原持有约 4,200 BTC，被盗约 95%）
- **攻击手法概述**：攻击者以"purported white-hat hackers"（自称白帽）身份从 Liquid 联邦钱包转走约 4,000 BTC，迫使该侧链暂停全部新交易。资金经由**正常且已获批的交易平台 SideSwap** 流出，使用的是 Peg-out Authorization Key（PAK）机制。攻击者通过链上比特币交易与网络维护方通信，承诺"先修好漏洞、确认全部节点打补丁后"再归还"大部分"资金。
- **公开报道指出的技术根因**：**并非私钥或硬件模块泄露**（与今年多数黑客事件不同）。Blockstream 指出是 **Elements 中的一个软件 bug 凭空"产生"了部分比特币**；SideSwap 无法区分哪些币来自 bug、哪些是真实币，于是对其一视同仁，导致攻击者借此近乎掏空联邦钱包。漏洞位于 Liquid 交易软件的**节点/共识层**，而非密钥层。
- **防御教训**：
  1. **侧链/联邦钱包要防"凭空铸造/超额出金"共识漏洞**：出金总额与真实锁仓储备之间要有链上硬对账与上限，任何"多出来的币"应立即使交易失效而非放行。
  2. **PAK/联邦函数权限要与实际出金路径绑定并限流**，单一授权通道不应能在无异常告警下抽走 95% 储备。
  3. **"加比特币 ≠ 获得比特币安全模型"**：联邦侧链的安全取决于节点/共识实现与成员管理，须按 L1 级标准做形式化/审计与紧急暂停机制。
- **来源**：
  - https://www.reuters.com/technology/bitcoin-based-liquid-network-says-320-million-withdrawn-hack-2026-09-07/
  - https://www.coindesk.com/markets/2026/09/07/bitcoin-network-used-by-exchanges-hit-by-usd320-million-exploit-hackers-claim-they-re-the-good-guys
  - https://www.theregister.com/security/2026/09/07/hackers-drain-320m-in-bitcoin-from-liquid-network-claim-theyre-the-good-guys/5294770

---

## 事件五：Ostium 预言机签名密钥被夺（RWA 永续）

- **时间**：2026-07-15
- **涉及项目**：Ostium（股票、外汇等真实世界资产 RWA 永续合约）
- **损失金额**：约 1,800 万–2,400 万美元（不同安全公司链上追踪口径不同）
- **攻击手法概述**：攻击者获取了 Ostium 价格喂送（price-feed）系统关联的一个签名密钥，用该密钥提交了**带未来时间戳的伪造价格报告**，把亏损交易伪装成盈利，随后直接提现"虚增"的利润，整个过程约 5 分钟。
- **公开报道指出的技术根因**：**预言机喂送签名密钥泄露 + 对价格报告缺乏时间戳/合理性校验**，攻击者可注入伪造、未来时间的价格。
- **防御教训**：
  1. **预言机喂送密钥独立、最小权限、短生命周期**，与协议主管理密钥隔离，并做泄露监控（异常喂送频率/幅度告警）。
  2. **价格报告加时间戳校验、带宽/跳变限制与多源交叉验证**，拒绝未来时间戳与超阈值跳价。
  3. **RWA 类"真实世界资产定价"要有链下可信源 + 链上校验**，避免单一喂送者可控。
- **来源**：
  - https://coingabbar.com/en/crypto-currency-news/top-crypto-hacks-2026-largest-crypto-security-incidents

---

## 事件六：Cosmos EVM 共享模块无符号整数下溢漏洞（多条链被波及）

- **时间**：2026-08-19 补丁发布；2026-08-20 至 08-25 被利用（MANTRA 链 8/20–8/21 受害最重）
- **涉及项目**：Cosmos EVM（cosmos/evm 共享模块，GHSA-7g4w-cg88-2cq2），波及 6 条 Cosmos EVM 链，含 MANTRA Chain
- **损失金额**：Cosmos Labs 口径为多链合计约 2,100 万美元量级（不同报道）；MANTRA 单链被转走约 7.209 亿枚 MANTRA，约 360 万美元（按事发前价格，项目自身估值）
- **攻击手法概述**：攻击者利用 cosmos/evm 共享模块中**无符号整数下溢**——在批准与某次调用关联的扣款前，未校验账户余额是否足够。由于使用无符号整数，余额不会降到 0 以下，而是回绕成一个极大数，使超额扣款/转账得以进行。资金来自 burn 地址与一个遗留休眠多签，而非用户账户、交易所余额或应用合约。攻击者跑了 2 笔交易后把大部分转到链下；验证者于 8/20 23:13 UTC（第二次抽取后 14 分钟）停机，MANTRA 主网离线 30 小时 13 分钟，后用修复版 v8.4.0 重启。
- **公开报道指出的技术根因**：**共享基础设施（upstream 依赖）的余额处理缺陷 + 无符号整数下溢回绕 + 缺乏对"视为不可动"的 burn/遗留多签地址的持续监控**。Cosmos Labs 在 11 条部署中事后发现有的从未在其安全渠道登记；补丁已公开于 main 分支（5/15 合并 PR #1176、8/13 回移），但安全公告遗漏了另两处余额修复。
- **防御教训**：
  1. **对上游/共享依赖做"下溢/回绕"专项审查**，扣款前强制余额充足性校验，优先用有符号/带边界检查的余额记账；警惕 cherry-pick 只修导出副本、留下重复未导出副本导致"测试全过仍漏洞"。
  2. **为 burn 地址、遗留多签等"应不可动"地址加持续监控与告警**，不要假设其静态安全。
  3. **建立上游安全渠道登记与补丁订阅**：运行共享模块的每条链都应在上游登记安全联系人，跟踪 silent-patch 流程，避免"补丁已公开但自己没装"。
- **来源**：
  - https://www.cryptopolitan.com/mantra-releases-exploit-post-mortem/
  - https://thecryptonewsfeed.com/news/mantra-post-mortem-says-cosmos-evm-bug-released-7209-million-tokens-in-august-exploit-26813
  - https://securitydone.com/cosmos-evm-flaw-exploited-after-cosmos-labs-knew-every-blockchain-running-it-was-vulnerable

---

## 其他 2026 年值得关注的公开事件（简列）

- **THORChain 金库失衡**：约 1,070 万美元从单一金库被抽出，THORChain 自动化监控数分钟内捕获失衡并触发全网交易/签名暂停，网络暂停约 5 周。来源：https://coingabbar.com/en/crypto-currency-news/top-crypto-hacks-2026-largest-crypto-security-incidents
- **单一受害者被"假钱包客服"社工**：约 2.82 亿美元——不是协议漏洞，而是个人被伪装钱包支持人员骗走（DEXTools News 追踪表）。来源：https://news.dextools.io/article/crypto-hacks-2026-tracker-biggest-exploits-onchain-data
- **CertiK 4 月统计**：2026 年 4 月加密利用/事件总损失超 6.5 亿美元；DeFi 项目损失最高（6.093 亿美元），另含 Rhea Finance 1,840 万、Grinex 1,620 万等。来源：https://mexc.fm/en-GB/news/1068425

---

## 横向总结：2026 年事件的高频根因分类

| 根因类别 | 代表事件 | 关键特征 |
|---|---|---|
| **密钥/凭证被盗 + 社会工程** | Drift（2.85 亿）、KelpDAO（2.9 亿）、Ostium（1,800–2,400 万）、Coldcard（1.16 亿） | 初始突破来自"信任"而非代码；长期身份伪装、开发者会话密钥、预言机签名密钥 |
| **预言机/价格喂送被操纵** | Drift（假预言机+CVT）、Ostium（伪造未来价格） | 价格源可被单点控制/伪造，缺乏时间戳与合理性校验 |
| **跨链桥单点验证** | KelpDAO（单验证者 LayerZero） | 验证者单点 + 供数 RPC 可被投毒，伪造跨链消息即铸造无抵押资产 |
| **供应链/固件/熵缺陷** | Coldcard（2021 固件 RNG 回退）、Cosmos EVM（上游共享模块） | 漏洞潜伏数年，藏在共享依赖/固件构建配置，影响面远超单一项目 |
| **共识/侧链"凭空铸造"漏洞** | Liquid（Elements bug 产出 BTC） | 节点/共识层 bug 凭空产生币，出金通道被合法授权路径利用 |
| **内部权限/运营安全** | Drift（提款上限被拉满）、Ostium（签名密钥权限过大） | 参数可被单密钥即时改大，权限未最小化 |
| **整数/边界缺陷（代码层）** | Cosmos EVM（无符号下溢回绕） | 经典但高发，共享模块放大影响，监控缺失放大损失 |

**三条贯穿性结论（对开发者/白帽的元启示）**：
1. **2026 年的最大损失几乎全部来自"密钥与信任层"，而非智能合约逻辑**——TRM 数据显示约 15% 的事件（密钥/基础设施）造成约 76% 的损失；审计"代码"已不足以保护资金，必须审计"人、凭证、签名流程与基础设施"。
2. **共享依赖/固件的"静默回退"与上游下溢是新的放大器**——单一上游 bug（Coldcard RNG、Cosmos EVM 余额）能同时击穿数百个下游，白帽应把"上游熵源/余额/铸造边界"作为高优先级审计面。
3. **监控缺失显著放大损失**——Ostium 4 小时、MANTRA 4 小时、KelpDAO 单验证者无交叉校验，均因"无实时对账/无告警/无暂停"而把小口变成大洞。"pause-on-anomaly + 多源交叉验证 + 实时储备对账"是 2026 年最划算的防御投资。

---

## 来源清单（主引用 8 个）

1. https://crypto.news/defi-hacks-2026-billion-lost-same-attack-keeps-working
2. https://www.trmlabs.com/resources/blog/the-largest-hardware-wallet-exploit-of-2026-inside-the-usd-116-million-coldcard-hack
3. https://coldcard.com/security/status
4. https://www.halborn.com/blog/post/explained-the-coldcard-hack-july-2026
5. https://www.reuters.com/technology/bitcoin-based-liquid-network-says-320-million-withdrawn-hack-2026-09-07/
6. https://www.theregister.com/security/2026/09/07/hackers-drain-320m-in-bitcoin-from-liquid-network-claim-theyre-the-good-guys/5294770
7. https://coingabbar.com/en/crypto-currency-news/top-crypto-hacks-2026-largest-crypto-security-incidents
8. https://thecryptonewsfeed.com/news/mantra-post-mortem-says-cosmos-evm-bug-released-7209-million-tokens-in-august-exploit-26813

*注：正文中另内联引用了若干补充来源（CoinDesk、The Register、MEXC、DEXTools News、Coinliva、CoinHub、SecurityDone 等）用于交叉印证，均已随正文标注 URL。以上金额/时间均来自来源方公开报道；部分为初步/滚动统计（如 Coldcard、Liquid），后续可能修正。*

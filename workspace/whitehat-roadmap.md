# 白帽（Web3 安全）方向总索引报告

> 生成日期：2026-09-10。本报告是 /workspace/whitehat/ 下四份中文调研报告的总索引与行动入口，各章要点基于各文件前 60 行提取，完整细节请点链接进入原文。

## 执行摘要（约 300 字）

本报告整合了四份调研：Immunefi 赏金平台、审计工具链、2026 年重大安全事件、白帽职业路径，目标是回答"个人如何进入 Web3 白帽方向、从哪切入、90 天怎么走"。核心结论：Web3 赏金市场由 Immunefi 主导（累计已付 $100M–$125M、保护资产 $190B+），但资金风险高度集中在智能合约（占已付费报告金额 89.6%），白帽的核心能力必须落在合约审计上。2026 事件复盘显示损失仍巨大且手法持续演进，既是风险信号也是赏金机会。工具链（静态分析、fuzz、符号执行）是放大器，但不能替代对业务逻辑的理解。现实路线：先系统补基础（EVM/常见漏洞原语），再用公开审计竞赛练手，从低危/中危报告建立首个 credit，逐步向高危和私有项目迁移。90 天计划以"工具上手 → 竞赛实战 → 首份报告"为主线，详见下文。各章数字口径不一致处已分别注明，未查证数字均已明示"未查到"。

---

## 章节一：Immunefi 赏金平台
摘要（详见 [01-immunefi.md](whitehat/01-immunefi.md)）

Immunefi 是 Web3 链无关（chain-agnostic）赏金平台龙头，2020-12 上线；累计已付赏金 $100M–$125M 量级，保护资产 $190B+，白帽 60,000+，项目 500+（各页口径不一，未合并）。关键数据：已付费报告中智能合约占数量 58.3%、占金额 89.6%（$59.1M）——资金风险与大额赏金高度集中于合约层。上项目覆盖 DeFi（SushiSwap、MakerDAO、GMX）、L1/L2（Optimism、Polygon）、跨链桥/基础设施（Wormhole、LayerZero、OpenZeppelin）、NFT/游戏（Immutable 最高 $1M）。2024 起扩展审计竞赛、Attackathons、邀请制项目，2025 推 SecOps 平台 Magnus。启示：合约层是主战场，平台是主要变现出口。

## 章节二：智能合约审计工具链
摘要（详见 [02-audit-tools.md](whitehat/02-audit-tools.md)）

工具链分层组合：Slither 静态扫描拉清单 → Foundry 单测/不变量 → Echidna 状态机 fuzzing → Mythril/Halmos 符号执行穷举路径，无单一工具能全覆盖。Slither（Trail of Bits，Python）：SlithIR 中间表示，速度快、误报低，检测器覆盖重入、未初始化状态、未保护升级等，号称解析 99.9% 公开 Solidity；盲区是不懂跨函数业务语义与运行时依赖路径，对 assembly/跨合约调用退化为低精度，findings 必须人工 triage（看 Impact×Confidence）。Echidna（Crytic，Haskell）：语法感知、基于不变量反证，擅长多步状态/时序 bug；盲区是不保证穷举、依赖预先写对 property、精确算术边界不如符号执行。原文还含四类高频漏洞的原理、最小示例与检测手段。

## 章节三：2026 年重大安全事件复盘
摘要（详见 [03-incidents-2026.md](whitehat/03-incidents-2026.md)）

总量背景：2026 前 8 个月损失约 13 亿美元（TRM H1 口径 207 起/$9.72 亿，较 2025 明显下降）。结构性变化：密钥/凭证/基础设施类攻击仅占约 15% 事件数却贡献约 76% 损失，合约漏洞约占 60% 事件数但仅占约 17% 损失。三大事件：Drift Protocol（04-01，~$2.85 亿）——长期社工骗取管理员密钥+持久 nonce 预签名，借维护窗口改假预言机并拉满提款上限抽干，根因是运营安全而非代码；KelpDAO/LayerZero 桥（04-18，~$2.9 亿）——社工开发者会话密钥后攻陷单一验证者签发伪造跨链消息，无抵押铸造 116,500 枚 rsETH，根因是单验证者架构；Coldcard（07-30 起，~1,816 BTC/$1.16 亿）——2021 年 4.0.1 固件构建错误致种子回退弱软件 RNG（有效强度 128→约 40 位），离线暴破，须换种迁移。

## 章节四：白帽成长路径
摘要（详见 [04-career-path.md](whitehat/04-career-path.md)）

主线：语言/VM 基础 → 单合约漏洞 → DeFi 组合攻击 → 真实审计/赏金实战。入门档（0–3 月）：Foundry 工具链 + Secureum Smart Contract 101 + Ethernaut（OpenZeppelin 关卡制 wargame，偏单合约/基础原语）+ Damn Vulnerable DeFi（18 关还原真实 DeFi 组合攻击，偏多合约）+ Off by a Byte / Epicenter 播客建案例语感；练习一律在本地分叉/测试网。进阶档（3–12 月）：Trail of Bits Testing Handbook 与公开审计报告、Paradigm CTF、Immunefi 安全指南（Foundry 写 PoC、报告模板）、定期读 Hack Analyses/postmortem。心法：以练习场为主线、真实案例为对照，形成"概念 → 可复现 PoC → 真实影响"闭环。报告是职业名片，质量直接决定受理率与赏金。

---

## 90 天白帽行动计划（500 字内）

**第 1–30 天：地基与工具。** 每天 3–4 小时。Week 1–2 过 Secureum Smart Contract 101，同步装好 Foundry（forge/anvil/cast）+ Slither，对任意开源合约跑 `slither .` 并学会按 Impact×Confidence triage。Week 3–4 通刷 Ethernaut 前 15 关，每关先自己写 PoC 再对照答案；每周用 Slither 扫一个 Etherscan 已部署合约，读 findings 并判断真伪。里程碑：Ethernaut 15 关全过，Slither triage 熟练。

**第 31–60 天：DeFi 组合攻击。** Week 5–6 用 anvil fork 通刷 Damn Vulnerable DeFi 前 9 关，重点打磨"闪贷→操纵→回还"骨架；每关抽象成"一类漏洞+一个攻击模式"记入自己的模式库。Week 7 起用 Echidna 给 2–3 个 DeFi 合约写不变量跑 fuzz，体会"猜对 property 才测得出 bug"；每周读 2 份 Immunefi Hack Analyses/postmortem（对照 03 章三大事件），用 Foundry fork 复现一个历史攻击。里程碑：DvD 9 关全过 + 1 个历史攻击复现 PoC。

**第 61–90 天：实战与首份报告。** Week 9 报 1–2 个审计竞赛（Immunefi Audit Competition 或 Capstone），按商业审计节奏"读陌生代码→系统找漏洞→写发现"。Week 10 完成 DvD 剩余关卡，选定 1 个有赏金的项目，用 Slither+Echidna+人工审组合做首次"生产级"审计，目标是产出 1 份合格报告（哪怕 Medium/Low，先拿到 credit）。Week 11–12 复盘全部笔记，整理攻击模式库与报告模板，注册 Immunefi 并在 1–2 个项目上持续挖掘。里程碑：至少 1 份已提交报告 + 竞赛成绩记录。

纪律：只在本地分叉/测试网操作；每天固定时间、每周写复盘；不跳级——地基不牢不啃 DeFi 组合攻击。

# Sub2API Frontend UI Customization Plan

本文档用于指导 `sub2api-standalone-frontend` 的整体 UI 自定义。范围覆盖公开首页、登录注册、用户页面、管理员页面、支付页面、设置页面、运维监控与通用组件。

## 参考来源

- 官方项目仓库: https://github.com/Wei-Shaw/sub2api
- 官方演示与官方域名说明: https://demo.sub2api.org/、https://v2.pincc.ai/、https://www.sub2api.org/
- 本地官方 API 契约: `E:\vibecoding\json_convert\sub2api\FRONTEND_BACKEND_API_CONTRACT.md`
- 本地官方支付文档: `E:\vibecoding\json_convert\sub2api\docs\PAYMENT_CN.md`
- 本地官方前端源码: `E:\vibecoding\json_convert\sub2api\frontend\src`
- 当前 standalone 前端源码: `E:\vibecoding\json_convert\sub2api-standalone-frontend\src`

官方前端首页当前核心表达为:

- `Sub2API`
- `Subscription to API Conversion Platform`
- 终端调用示例: `curl -X POST /v1/messages`
- 三个卖点: Subscription to API, Session Persistence, Pay As You Go
- 支持模型: Claude, GPT, Gemini, Antigravity

官方仓库与 API 契约确认的产品定位为: AI API Gateway, subscription quota distribution, multi-account management, API key distribution, token-level billing, smart scheduling, concurrency and rate limits, built-in payment, admin dashboard.

## 设计方向

方案名称: **Quiet Gateway**

目标不是做营销感强的 SaaS 首页，而是做一个清晰、可信、可长时间使用的 API 网关控制台。视觉关键词:

- 简约大气
- 线条细腻
- 背景干净
- 数据密集但不压迫
- 操作路径直观
- 管理台优先
- 明暗主题一致

当前需要降低的视觉特征:

- 大面积渐变背景
- 装饰性光球和模糊背景
- 过多 `rounded-2xl`
- 重玻璃拟态
- 卡片过多导致信息分散
- 彩色图标块过多导致页面不够专业

最终应呈现为: 轻边线、低阴影、稳定表格、克制强调色、清楚的状态系统。

## 全局设计系统

### 色彩

Light:

| Token | Value | 用途 |
|---|---:|---|
| `--surface-page` | `#F7F9FB` | 页面背景 |
| `--surface-base` | `#FFFFFF` | 主要面板 |
| `--surface-muted` | `#F1F5F9` | 次级面板、表头 |
| `--line-subtle` | `#D8E0E8` | 默认边线 |
| `--line-strong` | `#B8C4D1` | 强边线、活动态 |
| `--text-main` | `#0B1220` | 主文字 |
| `--text-muted` | `#5E6B7A` | 次级文字 |
| `--brand` | `#0D9488` | 主操作、活动态 |
| `--brand-soft` | `#E6F7F5` | 主色浅底 |
| `--info` | `#2563EB` | 信息、链路 |
| `--success` | `#16A34A` | 正常、成功 |
| `--warning` | `#D97706` | 临界、等待 |
| `--danger` | `#DC2626` | 错误、危险操作 |

Dark:

| Token | Value | 用途 |
|---|---:|---|
| `--surface-page` | `#080B10` | 页面背景 |
| `--surface-base` | `#0E141B` | 主要面板 |
| `--surface-muted` | `#141C25` | 次级面板、表头 |
| `--line-subtle` | `#263241` | 默认边线 |
| `--line-strong` | `#3A4858` | 强边线、活动态 |
| `--text-main` | `#F4F7FA` | 主文字 |
| `--text-muted` | `#9AA7B5` | 次级文字 |
| `--brand` | `#2DD4BF` | 主操作、活动态 |
| `--brand-soft` | `#0B2F2B` | 主色浅底 |

规则:

- 页面背景只允许干净浅灰或深黑蓝，不使用装饰性光球。
- 业务状态只使用 success, warning, danger, info，不使用随机紫色、粉色、彩虹色。
- 表格行 hover 使用浅背景，不增加阴影。
- 主色用于主按钮、活动导航、焦点环、关键进度，不用于大面积背景。

### 字体

- UI 正文: `Fira Sans`, `PingFang SC`, `Microsoft YaHei`, sans-serif
- 代码、密钥、数字、终端: `Fira Code`, `ui-monospace`, monospace
- 默认正文 14px 到 16px，表格内容 13px 到 14px。
- 数字列使用 `tabular-nums`。
- 不使用负字距，不用 viewport width 缩放字体。

### 圆角、边线、阴影

- 面板: 8px
- 输入框、按钮、标签: 8px
- 弹窗: 10px
- 头像或 Logo 容器: 8px
- 避免默认 `rounded-2xl` 和更大的圆角，除非是二维码或品牌资产容器。
- 默认边线 1px。
- 默认阴影极轻: `0 1px 2px rgba(15, 23, 42, 0.04)`。
- 悬浮不使用大阴影，使用边线变强和背景微变。

### 布局

- 控制台采用固定侧栏 + 顶栏 + 内容区。
- 桌面内容区最大信息密度优先，默认 gap 使用 16px 或 20px。
- 表格页顶部顺序固定: 页面标题、主要动作、筛选、表格、分页。
- 管理员页面允许更高密度，用户页面保留更多引导和解释。
- 移动端顺序以主任务优先，筛选项可折叠，表格允许卡片化或横向滚动。

### 动效

- 动效时长 150ms 到 220ms。
- 只动画 `opacity` 与 `transform`。
- 终端首页动效可保留，但必须支持 `prefers-reduced-motion`。
- 业务页面不做循环装饰动画。
- 加载超过 300ms 时显示 skeleton 或 spinner。

### 可访问性

- 所有图标按钮必须有 `title` 或 `aria-label`。
- 可点击区域不小于 44px。
- 表单必须保留可见 label。
- 错误信息紧贴字段，不能只用 toast。
- 焦点环保持可见。
- 状态不能只靠颜色表达，要配合文本或图标。

## API 到页面的信息架构

### Runtime, Setup, Gateway

来自 API 契约:

- `/setup/status`
- `/setup/test-db`
- `/setup/test-redis`
- `/setup/install`
- `/health`
- `/v1/*`
- `/v1/usage`

对应页面:

- `src/views/setup/SetupWizardView.vue`
- `src/views/KeyUsageView.vue`
- `src/components/common/VersionBadge.vue`
- 首页终端演示和 endpoint 说明

设计重点:

- 安装向导必须是步骤式流程，不做营销式大卡片。
- DB/Redis 测试状态要可恢复、可重试、可定位错误。
- `/v1/*` 网关能力应在首页和 API Key 使用弹窗里被清楚表达。

### Auth and Public Settings

来自 API 契约:

- `/api/v1/auth/login`
- `/api/v1/auth/login/2fa`
- `/api/v1/auth/register`
- `/api/v1/auth/me`
- `/api/v1/auth/refresh`
- `/api/v1/auth/logout`
- `/api/v1/auth/send-verify-code`
- OAuth start/callback/complete-registration/bind routes
- `/api/v1/settings/public`

对应页面:

- `src/views/auth/LoginView.vue`
- `src/views/auth/RegisterView.vue`
- `src/views/auth/ForgotPasswordView.vue`
- `src/views/auth/ResetPasswordView.vue`
- `src/views/auth/*CallbackView.vue`
- `src/components/layout/AuthLayout.vue`
- `src/components/auth/*`

设计重点:

- 登录页使用左右分区或居中窄面板均可，但必须保留清晰品牌与登录任务。
- OAuth 区域要作为次级路径，不抢主登录按钮。
- 2FA 弹窗和验证码流程必须有明确等待、错误和重试状态。
- 登录协议确认要使用轻量底部区域或紧凑 modal，不破坏登录节奏。

### User

来自 API 契约:

- `/api/v1/keys`
- `/api/v1/usage`
- `/api/v1/usage/dashboard/*`
- `/api/v1/user/profile`
- `/api/v1/user/password`
- `/api/v1/user/totp/*`
- `/api/v1/subscriptions/*`
- `/api/v1/groups/*`
- `/api/v1/channels/available`
- `/api/v1/channel-monitors/*`
- `/api/v1/redeem`
- `/api/v1/user/aff`
- `/api/v1/announcements`

对应页面:

- `src/views/user/DashboardView.vue`
- `src/views/user/KeysView.vue`
- `src/views/user/UsageView.vue`
- `src/views/user/AvailableChannelsView.vue`
- `src/views/user/ChannelStatusView.vue`
- `src/views/user/SubscriptionsView.vue`
- `src/views/user/PaymentView.vue`
- `src/views/user/UserOrdersView.vue`
- `src/views/user/RedeemView.vue`
- `src/views/user/AffiliateView.vue`
- `src/views/user/ProfileView.vue`

设计重点:

- 用户页面围绕“可用额度、可用模型、API Key、近期用量、充值/订阅”组织。
- API Key 页面是核心页面，密钥、分组、额度、限速、状态、复制、端点说明必须优先级清晰。
- 用量页面必须适合查询、筛选、导出，表格密度高于营销风格。

### Payment

来自 API 契约与支付文档:

- `/api/v1/payment/config`
- `/api/v1/payment/plans`
- `/api/v1/payment/channels`
- `/api/v1/payment/checkout-info`
- `/api/v1/payment/limits`
- `/api/v1/payment/orders`
- `/api/v1/payment/orders/my`
- `/api/v1/payment/orders/{id}`
- `/api/v1/payment/orders/{id}/cancel`
- `/api/v1/payment/orders/{id}/refund-request`
- `/api/v1/payment/public/orders/resolve`
- `/api/v1/payment/public/orders/verify`
- `/api/v1/payment/webhook/*`

对应页面:

- `src/views/user/PaymentView.vue`
- `src/views/user/PaymentQRCodeView.vue`
- `src/views/user/PaymentResultView.vue`
- `src/views/user/StripePaymentView.vue`
- `src/views/user/AirwallexPaymentView.vue`
- `src/views/user/UserOrdersView.vue`
- `src/views/admin/orders/*`
- `src/components/payment/*`
- `src/components/admin/payment/*`

设计重点:

- 用户购买页按“选择计划/金额 -> 选择支付方式 -> 确认 -> 支付状态”组织。
- 支付方式按钮统一展示为支付宝、微信、Stripe、Airwallex 等可见方式，不暴露后台路由来源细节。
- 管理员支付页面强调订单状态、服务商实例、限额、退款、负载均衡策略。
- 付款二维码页面必须清楚显示订单号、金额、倒计时、取消和刷新。

### Custom Pages

来自 API 契约:

- `/api/v1/pages/{slug}`
- `/api/v1/pages/{slug}/images/{filename}`

对应页面:

- `src/views/user/CustomPageView.vue`
- `src/components/layout/AppSidebar.vue`
- `src/views/admin/SettingsView.vue`

设计重点:

- 自定义页面应遵循同一版心、标题、内容排版规则。
- Markdown 内容不要被卡片再包卡片。
- iframe 页面必须有加载态、错误态和外链打开入口。

### Admin

来自 API 契约:

- `/api/v1/admin/dashboard`
- `/api/v1/admin/users/*`
- `/api/v1/admin/groups/*`
- `/api/v1/admin/accounts/*`
- `/api/v1/admin/channels/*`
- `/api/v1/admin/channel-monitors/*`
- `/api/v1/admin/usage/*`
- `/api/v1/admin/settings/*`
- `/api/v1/admin/payment/*`
- `/api/v1/admin/orders/*`
- `/api/v1/admin/redeem-codes/*`
- `/api/v1/admin/promo-codes/*`
- `/api/v1/admin/affiliates/*`
- `/api/v1/admin/proxies/*`
- `/api/v1/admin/risk-control/*`
- `/api/v1/admin/ops/*`
- `/api/v1/admin/announcements/*`

对应页面:

- `src/views/admin/DashboardView.vue`
- `src/views/admin/UsersView.vue`
- `src/views/admin/GroupsView.vue`
- `src/views/admin/ChannelsView.vue`
- `src/views/admin/ChannelMonitorView.vue`
- `src/views/admin/AccountsView.vue`
- `src/views/admin/SubscriptionsView.vue`
- `src/views/admin/UsageView.vue`
- `src/views/admin/SettingsView.vue`
- `src/views/admin/RiskControlView.vue`
- `src/views/admin/ProxiesView.vue`
- `src/views/admin/RedeemView.vue`
- `src/views/admin/PromoCodesView.vue`
- `src/views/admin/AnnouncementsView.vue`
- `src/views/admin/ops/OpsDashboard.vue`
- `src/views/admin/orders/*`
- `src/views/admin/affiliates/*`

设计重点:

- 管理员页面以“运营效率”和“异常发现”为优先级。
- 高危操作必须视觉隔离，并使用确认弹窗。
- 大表格页需要统一筛选条、批量操作条、列密度和分页。
- 运维监控页面可以更数据密集，但图表必须清晰，不做装饰性填充。

## 页面级改造规范

### 1. 首页 `HomeView.vue`

目标:

- 保留官方首页的终端演示和模型支持信息。
- 减少装饰背景，强化 API Gateway 产品感。

结构:

- 顶部导航: Logo, 文档, GitHub, 语言, 主题, 登录/控制台。
- Hero: 左侧品牌与一句话定位，右侧终端面板。
- 网关链路: API Key -> Scheduler -> Upstream Account -> 200 OK。
- 三个能力块: Unified API, Sticky Session, Usage Billing。
- 支持模型: Claude, GPT, Gemini, Antigravity。

改造点:

- 删除光球背景与 mesh gradient。
- 终端面板改为细边线面板，不做 3D 倾斜。
- 模型块使用一致图标与小标签，不使用随机渐变字母块。

### 2. 认证页面 `AuthLayout.vue`, `LoginView.vue`, `RegisterView.vue`

目标:

- 登录注册变成干净、专业的入口。
- 明确主路径: 邮箱/密码登录。
- OAuth、2FA、协议、验证码是辅助路径。

结构:

- 背景使用纯净浅灰或暗色。
- 登录卡片宽度 400px 到 440px。
- Logo 区域 48px，不用大阴影。
- 表单字段高度 44px 到 48px。
- OAuth 按钮统一高度 44px，图标左对齐，文字居中。

改造点:

- 取消背景光球。
- `card-glass` 改为标准 surface panel。
- 密码可见按钮补充 `aria-label`。
- 登录错误显示在字段下或表单顶部 alert，不只 toast。

### 3. 安装向导 `SetupWizardView.vue`

目标:

- 更像系统初始化向导。
- 明确 DB/Redis 测试状态和安装结果。

结构:

- 左侧步骤导航，右侧配置表单。
- 每个测试结果使用状态行: idle, testing, success, failed。
- 安装按钮始终在底部操作栏。

改造点:

- 输入项分组: Database, Redis, Admin, Runtime。
- 测试失败展示原因和重试按钮。

### 4. 应用壳 `AppLayout.vue`, `AppSidebar.vue`, `AppHeader.vue`

目标:

- 统一所有内部页面的框架质感。
- 让用户与管理员页面有一致体验，但导航优先级不同。

结构:

- 侧栏宽度保持 256px，折叠 72px。
- 顶栏高度 64px。
- 内容区背景统一。
- 页面标题和描述由 route meta 驱动。

改造点:

- `AppLayout` 移除 `bg-mesh-gradient`。
- 侧栏使用纯面板 + 1px 右边线。
- 活动导航使用左侧 2px 指示线 + 浅底。
- 折叠菜单 tooltip 保留。
- 顶栏动作区用 icon button，保持 44px 命中区域。

### 5. 用户仪表盘 `views/user/DashboardView.vue`

目标:

- 用户打开后立即知道余额、今日用量、活跃 key、趋势和下一步操作。

布局:

- 第一行: Balance, Today Cost, Requests, Active Keys。
- 第二行: Usage Trend 宽图 + Model Distribution。
- 第三行: Recent Usage + Quick Actions。

改造点:

- `UserDashboardStats` 使用统一 stat panel。
- `UserDashboardQuickActions` 不做大卡片堆叠，改成紧凑动作列表。
- 图表容器要有固定高度，防止布局跳动。

### 6. API Keys `views/user/KeysView.vue`

目标:

- 这是用户侧核心任务页，要最优先改。

布局:

- 顶部: 创建 Key 主按钮、刷新、端点说明。
- 筛选: 搜索、分组、状态、更多筛选。
- 表格: 名称、Key、分组、今日/总用量、额度、限速、状态、操作。

改造点:

- Key copy 按钮使用 32px 图标按钮，但命中区扩展到 44px。
- 额度和限速进度条高度 4px，颜色状态统一。
- `EndpointPopover` 改为更像开发者参考面板，包含 Base URL、兼容端点、curl 示例。
- 创建/编辑 Key 弹窗按“基础信息、访问控制、额度限制、速率限制”分组。

### 7. 用户用量 `views/user/UsageView.vue`

目标:

- 适合排查费用和请求来源。

布局:

- 顶部统计: 总成本、请求数、Token、平均耗时。
- 筛选条: 日期、API Key、模型、状态。
- 表格: 时间、Key、模型、输入/输出 Token、成本、状态、耗时、请求 ID。

改造点:

- 数字列使用等宽数字。
- 错误请求行使用左侧红色细线，而不是整行红底。
- 详情弹窗展示请求摘要和计费拆分。

### 8. 订阅、购买、订单、支付结果

目标:

- 用户支付链路必须清楚，减少不确定性。

页面:

- `SubscriptionsView.vue`
- `PaymentView.vue`
- `PaymentQRCodeView.vue`
- `PaymentResultView.vue`
- `UserOrdersView.vue`
- `StripePaymentView.vue`
- `AirwallexPaymentView.vue`

布局:

- 购买页: 计划/金额选择、支付方式、订单确认、帮助信息。
- 二维码页: 金额、支付方式、二维码、倒计时、订单号。
- 结果页: 成功/处理中/失败状态 + 下一步。
- 订单页: 状态筛选 + 订单列表。

改造点:

- 支付 provider card 不使用重阴影。
- 支付状态只用 success/warning/danger/info 四类。
- 取消订单和退款请求是危险/审慎动作，必须二次确认。

### 9. 可用渠道与渠道状态

目标:

- 让用户知道“我能用什么模型”和“当前是否可用”。

页面:

- `AvailableChannelsView.vue`
- `ChannelStatusView.vue`
- `components/user/monitor/*`

布局:

- 可用渠道用紧凑表格或分组列表。
- 状态页用 Provider -> Availability -> Latency -> Last Check。

改造点:

- 平台图标统一尺寸。
- 支持模型 chip 使用低饱和度边线标签。
- 不用大面积彩色卡片表达状态。

### 10. 用户个人中心 `ProfileView.vue`

目标:

- 账户安全、绑定、通知和密码/TOTP 设置清晰分区。

布局:

- Profile summary
- Security
- Bindings
- Notification
- Danger zone

改造点:

- 安全状态使用 checklist 风格。
- TOTP setup modal 清楚展示步骤和恢复路径。
- Danger zone 和普通设置视觉隔离。

### 11. 管理员仪表盘 `views/admin/DashboardView.vue`

目标:

- 第一屏看到系统健康和运营关键指标。

布局:

- 核心指标: API Keys, Accounts, Requests, Users。
- 成本指标: Today Tokens, Total Tokens, RPM/TPM, Avg Response。
- 图表: 趋势、模型分布、分组分布、端点分布。
- 异常摘要: 错误账户、失败请求、额度临界。

改造点:

- 当前多色图标块要收敛为统一线性图标 + 状态点。
- 大量 stat card 使用一致高度和固定数字区。
- 管理员页面允许更紧凑 padding。

### 12. 运维监控 `views/admin/ops/OpsDashboard.vue`

目标:

- 面向排障，优先展示错误、延迟、吞吐、并发、切换率。

布局:

- Header: 时间范围、自动刷新、设置。
- Top metrics: Throughput, Error Rate, Latency, Concurrency。
- Charts: Error trend, latency, switch rate, throughput。
- Tables: error logs, system logs。

改造点:

- 图表用低对比网格线。
- 错误详情 modal 使用分栏: summary, request, response, stack/context。
- 自动刷新状态要明确。

### 13. 用户、分组、订阅管理

页面:

- `UsersView.vue`
- `GroupsView.vue`
- `SubscriptionsView.vue`

目标:

- 强化批量操作与筛选效率。

改造点:

- 使用统一 `TablePageLayout`。
- 批量操作条固定在表格上方，显示选中数量。
- 用户余额调整、API Key 查看、允许分组编辑使用一致 modal。
- 分组表单拆分为 Basic, Limits, Model Scope, Pricing。

### 14. 账号与渠道管理

页面:

- `AccountsView.vue`
- `ChannelsView.vue`
- `ChannelMonitorView.vue`
- `components/account/*`
- `components/admin/account/*`
- `components/admin/channel/*`

目标:

- 上游账号是管理员最复杂页面，优先保证可扫读和状态清楚。

改造点:

- 账号表格增加状态列视觉权重: schedulable, error, quota, temp unschedulable。
- 批量编辑 modal 使用分组和确认摘要。
- OAuth 授权流程用步骤条。
- Pricing row 保持紧凑，模型标签可换行但不撑破行高。
- 监控模板与运行结果弹窗统一标题区、内容区、底部操作区。

### 15. 管理员用量与日志

页面:

- `views/admin/UsageView.vue`
- `components/admin/usage/*`

目标:

- 支持查询、导出、清理、审计。

改造点:

- 筛选区可折叠。
- 导出进度使用 `ExportProgressDialog` 统一样式。
- 清理用量是危险动作，使用 danger dialog。

### 16. 管理员支付

页面:

- `views/admin/orders/AdminPaymentDashboardView.vue`
- `views/admin/orders/AdminOrdersView.vue`
- `views/admin/orders/AdminPaymentPlansView.vue`
- `components/admin/payment/*`
- `components/payment/providerConfig.ts`

目标:

- 管理员能快速判断订单收入、渠道状态、退款风险。

布局:

- 支付看板: Revenue, Orders, Success Rate, Pending。
- 订单表: 状态、用户、金额、渠道、服务商实例、创建时间、操作。
- 计划管理: 计划名称、价格、额度、有效期、状态。

改造点:

- Provider 配置展示 webhook URL 时使用 code block + copy。
- 退款操作与普通查看操作分离。
- 服务商实例用可排序列表，限额状态直接展示。

### 17. 系统设置、风控、公告、代理、兑换、推广、返利

页面:

- `SettingsView.vue`
- `RiskControlView.vue`
- `AnnouncementsView.vue`
- `ProxiesView.vue`
- `RedeemView.vue`
- `PromoCodesView.vue`
- `views/admin/affiliates/*`

目标:

- 设置页要清楚，复杂配置不能堆成一页噪音。

改造点:

- 设置页按 tabs 分区: Basic, Auth, Payment, Custom Pages, Security, Advanced。
- 风控页使用规则列表 + 规则编辑抽屉。
- 公告编辑区 preview 与表单分栏。
- 兑换码/优惠码页面强化批量生成和状态筛选。
- 返利记录页面三类记录保持同一表格密度和筛选模式。

## 通用组件改造清单

优先改这些组件，而不是逐页复制样式:

- `src/style.css`
- `tailwind.config.js`
- `src/components/layout/AppLayout.vue`
- `src/components/layout/AppSidebar.vue`
- `src/components/layout/AppHeader.vue`
- `src/components/layout/TablePageLayout.vue`
- `src/components/common/DataTable.vue`
- `src/components/common/StatCard.vue`
- `src/components/common/Input.vue`
- `src/components/common/Select.vue`
- `src/components/common/SearchInput.vue`
- `src/components/common/BaseDialog.vue`
- `src/components/common/ConfirmDialog.vue`
- `src/components/common/EmptyState.vue`
- `src/components/common/Skeleton.vue`
- `src/components/common/StatusBadge.vue`
- `src/components/common/Toast.vue`
- `src/components/common/HelpTooltip.vue`
- `src/components/common/Pagination.vue`
- `src/components/charts/*`
- `src/components/payment/*`

统一组件规则:

- `card` 改成轻边线 panel。
- `btn-primary` 改为纯色或细微线性，不使用重渐变。
- `btn-secondary` 使用白底/暗底 + 边线。
- `input` 高度统一 44px。
- `modal` 最大高度、滚动区域、底部操作条统一。
- `table` 统一 sticky header、行 hover、空状态、loading state。

## 实施阶段

### Phase 1: Design Tokens and Shell

文件:

- `tailwind.config.js`
- `src/style.css`
- `AppLayout.vue`
- `AppSidebar.vue`
- `AppHeader.vue`
- `AuthLayout.vue`

目标:

- 替换全局背景、卡片、按钮、输入框、表格、弹窗 token。
- 去掉 mesh gradient 和装饰光球。
- 完成登录页和内部框架统一。

验收:

- 首页、登录页、用户 dashboard、管理员 dashboard 风格一致。
- 明暗主题均可读。
- 侧栏折叠和移动端抽屉正常。

### Phase 2: Public and Auth Pages

文件:

- `HomeView.vue`
- `LoginView.vue`
- `RegisterView.vue`
- `ForgotPasswordView.vue`
- `ResetPasswordView.vue`
- OAuth callback pages
- `SetupWizardView.vue`

目标:

- 首页完成 Quiet Gateway 方案。
- 登录注册完成统一布局。
- 安装向导变成步骤式系统配置界面。

验收:

- 官方首页核心信息没有丢失。
- 登录、注册、2FA、OAuth、协议确认流程正常。

### Phase 3: User Console

文件:

- `views/user/DashboardView.vue`
- `views/user/KeysView.vue`
- `views/user/UsageView.vue`
- `views/user/AvailableChannelsView.vue`
- `views/user/ChannelStatusView.vue`
- `views/user/SubscriptionsView.vue`
- `views/user/PaymentView.vue`
- `views/user/UserOrdersView.vue`
- `views/user/ProfileView.vue`
- `components/user/*`
- `components/keys/*`

目标:

- 用户侧核心任务页可用、清楚、稳定。
- API Key 和 Usage 优先。

验收:

- API Key 创建、复制、编辑、删除流程视觉一致。
- 用量和支付流程状态清楚。

### Phase 4: Admin Console

文件:

- `views/admin/*`
- `views/admin/ops/*`
- `views/admin/orders/*`
- `components/admin/*`
- `components/account/*`
- `components/payment/*`

目标:

- 管理员页面表格、筛选、批量操作、图表、modal 全部统一。

验收:

- 账号、用户、渠道、用量、订单、设置页面没有明显风格断层。
- 高危操作都有确认和清楚状态。

### Phase 5: QA and Accessibility

检查:

- `pnpm run typecheck`
- `pnpm run test:run`
- `pnpm run build`
- 浏览器验证 375px, 768px, 1024px, 1440px。
- 明暗主题各跑一遍。
- reduced motion 下无持续装饰动画。

## 页面优先级

P0:

- `HomeView.vue`
- `AuthLayout.vue`
- `LoginView.vue`
- `AppLayout.vue`
- `AppSidebar.vue`
- `AppHeader.vue`
- `DataTable.vue`
- `TablePageLayout.vue`

P1:

- 用户 Dashboard
- 用户 Keys
- 用户 Usage
- 管理员 Dashboard
- 管理员 Accounts
- 管理员 Users
- 管理员 Settings

P2:

- Payment 全链路
- Admin Orders
- Admin Usage
- Admin Channels
- Admin Groups
- Channel Monitor
- Profile

P3:

- Affiliate
- Promo Codes
- Redeem
- Announcements
- Proxies
- Risk Control
- Custom Pages
- Ops advanced details

## 验收标准

- 首页和内部页面属于同一视觉体系。
- 页面背景干净，不出现杂乱装饰。
- 控制台页面信息密度合理，表格可扫读。
- 颜色语义一致，状态清楚。
- 明暗主题均可用。
- 移动端无横向溢出，表格页可操作。
- 所有 icon-only button 有 accessible name。
- 登录、支付、删除、批量编辑等关键流程有清楚反馈。
- 不改变 API 调用语义，不引入 mock 数据覆盖真实接口。

## 实施注意事项

- 不要一次性重写所有页面逻辑。先改 design tokens 和通用组件，再逐页收敛。
- 保留现有 i18n key，不直接写死页面文案。
- 保留 feature flag、simple mode、backend mode、payment enabled、risk control enabled 等逻辑。
- 不破坏 router guard 和权限跳转。
- 自定义页面 iframe 和 markdown 渲染要继续兼容。
- 支付与 OAuth 回调页优先保证流程稳定，再做视觉增强。
- 图表和表格先保证尺寸稳定，避免异步加载造成布局跳动。

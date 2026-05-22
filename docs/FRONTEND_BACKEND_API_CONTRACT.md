# Frontend to Backend API Contract

Source baseline: `Wei-Shaw/sub2api` main at `16793d3a` (`chore: update sponsors`).

This document freezes the backend HTTP/WebSocket paths the current frontend depends on before replacing the embedded UI with an independent frontend. It is path/method focused: request and response schemas remain in the TypeScript API modules referenced in the `Source` column and in the backend handlers.

## Client Rules

- Default API base is `VITE_API_BASE_URL || /api/v1`. All `apiClient` relative paths below are expanded to full deployed paths under `/api/v1`.
- `apiClient` sends `withCredentials: true`, `Content-Type: application/json`, `Authorization: Bearer <auth_token>` when present, `Accept-Language`, and adds `timezone` to every GET query.
- Standard JSON responses use `{ code, message, data }`; the frontend unwraps successful `data` automatically.
- A 401 on non-auth requests triggers `POST /api/v1/auth/refresh`; failure clears local tokens and redirects to `/login`.
- Setup endpoints are outside `/api/v1`. Gateway endpoints such as `/v1/usage` are also outside `/api/v1`.

## Reverse Proxy Requirements

For an independent frontend, proxy these backend-owned prefixes before falling back to static SPA files:

- `/api/v1/` -> official sub2api backend
- `/setup/` -> official sub2api backend
- `/health` -> official sub2api backend
- `/v1/` -> official sub2api backend gateway
- `/api/event_logging/batch` -> official sub2api backend
- OAuth callbacks and payment webhooks under `/api/v1/auth/oauth/` and `/api/v1/payment/webhook/` must remain backend routes.

## Runtime, Setup, Gateway

| Method | Path | Auth / Access | Source | Notes |
|---|---|---|---|---|
| `POST` | `/api/event_logging/batch` | public | `backend/internal/server/routes/common.go` | Claude Code telemetry compatibility endpoint |
| `GET` | `/health` | public/setup | `frontend/src/components/common/VersionBadge.vue` | health check fetch |
| `POST` | `/setup/install` | public/setup | `frontend/src/api/setup.ts:86` |  |
| `GET` | `/setup/status` | public/setup | `frontend/src/api/setup.ts:64`<br>`frontend/src/views/setup/SetupWizardView.vue` | direct fetch after install restart |
| `POST` | `/setup/test-db` | public/setup | `frontend/src/api/setup.ts:72` |  |
| `POST` | `/setup/test-redis` | public/setup | `frontend/src/api/setup.ts:79` |  |
| `ANY` | `/v1/*` | API key | `backend gateway routes` | OpenAI/Anthropic-compatible API gateway surface; includes /v1/messages, /v1/chat/completions, /v1/responses, /v1/models, /v1/usage, etc. |
| `GET` | `/v1/usage` | API key | `frontend/src/views/KeyUsageView.vue` | public API-key usage query; Authorization: Bearer sk-... |

## Auth and Public Settings

| Method | Path | Auth / Access | Source | Notes |
|---|---|---|---|---|
| `POST` | `/api/v1/auth/forgot-password` | public or OAuth session | `frontend/src/api/auth.ts:530` |  |
| `POST` | `/api/v1/auth/login` | public or OAuth session | `frontend/src/api/auth.ts:92` |  |
| `POST` | `/api/v1/auth/login/2fa` | public or OAuth session | `frontend/src/api/auth.ts:115` |  |
| `POST` | `/api/v1/auth/logout` | public or OAuth session | `frontend/src/api/auth.ts:170` |  |
| `GET` | `/api/v1/auth/me` | user JWT | `frontend/src/api/auth.ts:156` |  |
| `POST` | `/api/v1/auth/oauth/bind-token` | user JWT | `frontend/src/api/auth.ts:288` |  |
| `GET` | `/api/v1/auth/oauth/dingtalk/bind/start` | public + bind cookie | `frontend/src/api/user.ts` | browser navigation after setting bind-token cookie |
| `GET` | `/api/v1/auth/oauth/dingtalk/callback` | public or OAuth session | `frontend/src/views/admin/SettingsView.vue` | OAuth provider callback; proxy to backend |
| `POST` | `/api/v1/auth/oauth/dingtalk/complete-registration` | public or OAuth session | `frontend/src/views/auth/*CallbackView.vue; frontend/src/api/auth.ts`<br>`frontend/src/views/auth/DingTalkCallbackView.vue:644` | OAuth registration completion |
| `GET` | `/api/v1/auth/oauth/dingtalk/start` | public or OAuth session | `frontend/src/components/auth/DingTalkOAuthSection.vue` | browser navigation |
| `GET` | `/api/v1/auth/oauth/github/callback` | public or OAuth session | `frontend/src/views/auth/OAuthCallbackView.vue` | browser redirects provider callback to backend |
| `POST` | `/api/v1/auth/oauth/github/complete-registration` | public or OAuth session | `frontend/src/views/auth/*CallbackView.vue; frontend/src/api/auth.ts` | OAuth registration completion |
| `GET` | `/api/v1/auth/oauth/github/start` | public or OAuth session | `frontend/src/components/auth/EmailOAuthButtons.vue` | browser navigation |
| `GET` | `/api/v1/auth/oauth/google/callback` | public or OAuth session | `frontend/src/views/auth/OAuthCallbackView.vue` | browser redirects provider callback to backend |
| `POST` | `/api/v1/auth/oauth/google/complete-registration` | public or OAuth session | `frontend/src/views/auth/*CallbackView.vue; frontend/src/api/auth.ts` | OAuth registration completion |
| `GET` | `/api/v1/auth/oauth/google/start` | public or OAuth session | `frontend/src/components/auth/EmailOAuthButtons.vue` | browser navigation |
| `GET` | `/api/v1/auth/oauth/linuxdo/bind/start` | public + bind cookie | `frontend/src/api/user.ts` | browser navigation after setting bind-token cookie |
| `GET` | `/api/v1/auth/oauth/linuxdo/callback` | public or OAuth session | `frontend/src/views/admin/SettingsView.vue` | OAuth provider callback; proxy to backend |
| `POST` | `/api/v1/auth/oauth/linuxdo/complete-registration` | public or OAuth session | `frontend/src/views/auth/*CallbackView.vue; frontend/src/api/auth.ts`<br>`frontend/src/views/auth/LinuxDoCallbackView.vue:641` | OAuth registration completion |
| `GET` | `/api/v1/auth/oauth/linuxdo/start` | public or OAuth session | `frontend/src/components/auth/LinuxDoOAuthSection.vue` | browser navigation |
| `GET` | `/api/v1/auth/oauth/oidc/bind/start` | public + bind cookie | `frontend/src/api/user.ts` | browser navigation after setting bind-token cookie |
| `GET` | `/api/v1/auth/oauth/oidc/callback` | public or OAuth session | `frontend/src/views/admin/SettingsView.vue` | OAuth provider callback; proxy to backend |
| `POST` | `/api/v1/auth/oauth/oidc/complete-registration` | public or OAuth session | `frontend/src/views/auth/*CallbackView.vue; frontend/src/api/auth.ts`<br>`frontend/src/views/auth/OidcCallbackView.vue:665` | OAuth registration completion |
| `GET` | `/api/v1/auth/oauth/oidc/start` | public or OAuth session | `frontend/src/components/auth/OidcOAuthSection.vue` | browser navigation |
| `POST` | `/api/v1/auth/oauth/pending/bind-login` | public or OAuth session | `frontend/src/views/auth/DingTalkCallbackView.vue:710`<br>`frontend/src/views/auth/LinuxDoCallbackView.vue:708`<br>`+2 more` |  |
| `POST` | `/api/v1/auth/oauth/pending/create-account` | public or OAuth session | `frontend/src/views/auth/DingTalkCallbackView.vue:682`<br>`frontend/src/views/auth/DingTalkEmailCompletionView.vue:73`<br>`+4 more` |  |
| `POST` | `/api/v1/auth/oauth/pending/exchange` | public or OAuth session | `frontend/src/api/auth.ts:647` |  |
| `POST` | `/api/v1/auth/oauth/pending/send-verify-code` | public or OAuth session | `frontend/src/api/auth.ts:464` |  |
| `GET` | `/api/v1/auth/oauth/wechat/bind/start` | public + bind cookie | `frontend/src/api/user.ts` | browser navigation after setting bind-token cookie |
| `GET` | `/api/v1/auth/oauth/wechat/callback` | public or OAuth session | `frontend/src/views/admin/SettingsView.vue` | OAuth provider callback; proxy to backend |
| `POST` | `/api/v1/auth/oauth/wechat/complete-registration` | public or OAuth session | `frontend/src/views/auth/*CallbackView.vue; frontend/src/api/auth.ts`<br>`frontend/src/views/auth/WechatCallbackView.vue:875` | OAuth registration completion |
| `GET` | `/api/v1/auth/oauth/wechat/payment/callback` | public or OAuth session | `backend route needed by payment OAuth provider` | OAuth provider callback; proxy to backend |
| `GET` | `/api/v1/auth/oauth/wechat/payment/start` | public or OAuth session | `frontend/src/views/user/PaymentView.vue` | browser navigation for WeChat payment OAuth |
| `GET` | `/api/v1/auth/oauth/wechat/start` | public or OAuth session | `frontend/src/components/auth/WechatOAuthSection.vue; frontend/src/views/auth/WechatCallbackView.vue` | browser navigation |
| `POST` | `/api/v1/auth/refresh` | public or OAuth session | `frontend/src/api/auth.ts:301` |  |
| `POST` | `/api/v1/auth/register` | public or OAuth session | `frontend/src/api/auth.ts:136` |  |
| `POST` | `/api/v1/auth/reset-password` | public or OAuth session | `frontend/src/api/auth.ts:556` |  |
| `POST` | `/api/v1/auth/revoke-all-sessions` | user JWT | `frontend/src/api/auth.ts:318` |  |
| `POST` | `/api/v1/auth/send-verify-code` | public or OAuth session | `frontend/src/api/auth.ts:457` |  |
| `POST` | `/api/v1/auth/validate-invitation-code` | public or OAuth session | `frontend/src/api/auth.ts:505` |  |
| `POST` | `/api/v1/auth/validate-promo-code` | public or OAuth session | `frontend/src/api/auth.ts:487` |  |
| `GET` | `/api/v1/settings/public` | public or OAuth session | `frontend/src/api/auth.ts:335` |  |

## User

| Method | Path | Auth / Access | Source | Notes |
|---|---|---|---|---|
| `GET` | `/api/v1/announcements` | user JWT | `frontend/src/api/announcements.ts:9` |  |
| `POST` | `/api/v1/announcements/{id}/read` | user JWT | `frontend/src/api/announcements.ts:16` |  |
| `GET` | `/api/v1/channel-monitors` | user JWT | `frontend/src/api/channelMonitor.ts:64` |  |
| `GET` | `/api/v1/channel-monitors/{id}/status` | user JWT | `frontend/src/api/channelMonitor.ts:74` |  |
| `GET` | `/api/v1/channels/available` | user JWT | `frontend/src/api/channels.ts:68` |  |
| `GET` | `/api/v1/groups/available` | user JWT | `frontend/src/api/groups.ts:17` |  |
| `GET` | `/api/v1/groups/rates` | user JWT | `frontend/src/api/groups.ts:26` |  |
| `GET` | `/api/v1/keys` | user JWT | `frontend/src/api/keys.ts:31` |  |
| `POST` | `/api/v1/keys` | user JWT | `frontend/src/api/keys.ts:99` |  |
| `GET` | `/api/v1/keys/{id}` | user JWT | `frontend/src/api/keys.ts:44` |  |
| `PUT` | `/api/v1/keys/{id}` | user JWT | `frontend/src/api/keys.ts:110` |  |
| `DELETE` | `/api/v1/keys/{id}` | user JWT | `frontend/src/api/keys.ts:120` |  |
| `POST` | `/api/v1/redeem` | user JWT | `frontend/src/api/redeem.ts:42` |  |
| `GET` | `/api/v1/redeem/history` | user JWT | `frontend/src/api/redeem.ts:58` |  |
| `GET` | `/api/v1/subscriptions` | user JWT | `frontend/src/api/subscriptions.ts:30` |  |
| `GET` | `/api/v1/subscriptions/active` | user JWT | `frontend/src/api/subscriptions.ts:38` |  |
| `GET` | `/api/v1/subscriptions/progress` | user JWT | `frontend/src/api/subscriptions.ts:46` |  |
| `GET` | `/api/v1/subscriptions/summary` | user JWT | `frontend/src/api/subscriptions.ts:54` |  |
| `GET` | `/api/v1/subscriptions/{subscriptionId}/progress` | user JWT | `frontend/src/api/subscriptions.ts:64` |  |
| `GET` | `/api/v1/usage` | user JWT | `frontend/src/api/usage.ts:112`<br>`frontend/src/api/usage.ts:127`<br>`+1 more` |  |
| `POST` | `/api/v1/usage/dashboard/api-keys-usage` | user JWT | `frontend/src/api/usage.ts:295` |  |
| `GET` | `/api/v1/usage/dashboard/models` | user JWT | `frontend/src/api/usage.ts:252` |  |
| `GET` | `/api/v1/usage/dashboard/stats` | user JWT | `frontend/src/api/usage.ts:229` |  |
| `GET` | `/api/v1/usage/dashboard/trend` | user JWT | `frontend/src/api/usage.ts:239` |  |
| `GET` | `/api/v1/usage/stats` | user JWT | `frontend/src/api/usage.ts:150`<br>`frontend/src/api/usage.ts:177` |  |
| `GET` | `/api/v1/usage/{id}` | user JWT | `frontend/src/api/usage.ts:218` |  |
| `PUT` | `/api/v1/user` | user JWT | `frontend/src/api/user.ts:42` |  |
| `POST` | `/api/v1/user/account-bindings/email` | user JWT | `frontend/src/api/user.ts:108` |  |
| `POST` | `/api/v1/user/account-bindings/email/send-code` | user JWT | `frontend/src/api/user.ts:100` |  |
| `DELETE` | `/api/v1/user/account-bindings/{provider}` | user JWT | `frontend/src/api/user.ts:113` |  |
| `GET` | `/api/v1/user/aff` | user JWT | `frontend/src/api/user.ts:179` |  |
| `POST` | `/api/v1/user/aff/transfer` | user JWT | `frontend/src/api/user.ts:184` |  |
| `GET` | `/api/v1/user/api-keys/{apiKeyId}/usage/daily` | user JWT | `frontend/src/api/usage.ts:266` |  |
| `DELETE` | `/api/v1/user/notify-email` | user JWT | `frontend/src/api/user.ts:86` |  |
| `POST` | `/api/v1/user/notify-email/send-code` | user JWT | `frontend/src/api/user.ts:69` |  |
| `PUT` | `/api/v1/user/notify-email/toggle` | user JWT | `frontend/src/api/user.ts:95` |  |
| `POST` | `/api/v1/user/notify-email/verify` | user JWT | `frontend/src/api/user.ts:78` |  |
| `PUT` | `/api/v1/user/password` | user JWT | `frontend/src/api/user.ts:60` |  |
| `GET` | `/api/v1/user/profile` | user JWT | `frontend/src/api/user.ts:26` |  |
| `POST` | `/api/v1/user/totp/disable` | user JWT | `frontend/src/api/totp.ts:70` |  |
| `POST` | `/api/v1/user/totp/enable` | user JWT | `frontend/src/api/totp.ts:60` |  |
| `POST` | `/api/v1/user/totp/send-code` | user JWT | `frontend/src/api/totp.ts:40` |  |
| `POST` | `/api/v1/user/totp/setup` | user JWT | `frontend/src/api/totp.ts:50` |  |
| `GET` | `/api/v1/user/totp/status` | user JWT | `frontend/src/api/totp.ts:22` |  |
| `GET` | `/api/v1/user/totp/verification-method` | user JWT | `frontend/src/api/totp.ts:31` |  |

## Custom Pages

| Method | Path | Auth / Access | Source | Notes |
|---|---|---|---|---|
| `GET` | `/api/v1/pages/{slug}` | user JWT + visibility | `frontend/src/views/user/CustomPageView.vue` | custom markdown page content |
| `GET` | `/api/v1/pages/{slug}/images/{filename}` | public + visibility | `frontend/src/views/user/CustomPageView.vue` | custom page image asset |

## Payment

| Method | Path | Auth / Access | Source | Notes |
|---|---|---|---|---|
| `GET` | `/api/v1/payment/channels` | user JWT | `frontend/src/api/payment.ts:32` |  |
| `GET` | `/api/v1/payment/checkout-info` | user JWT | `frontend/src/api/payment.ts:37` |  |
| `GET` | `/api/v1/payment/config` | user JWT | `frontend/src/api/payment.ts:22` |  |
| `GET` | `/api/v1/payment/limits` | user JWT | `frontend/src/api/payment.ts:42` |  |
| `POST` | `/api/v1/payment/orders` | user JWT | `frontend/src/api/payment.ts:47` |  |
| `GET` | `/api/v1/payment/orders/my` | user JWT | `frontend/src/api/payment.ts:52` |  |
| `GET` | `/api/v1/payment/orders/refund-eligible-providers` | user JWT | `frontend/src/api/payment.ts:87` |  |
| `POST` | `/api/v1/payment/orders/verify` | user JWT | `frontend/src/api/payment.ts:67` |  |
| `GET` | `/api/v1/payment/orders/{id}` | user JWT | `frontend/src/api/payment.ts:57` |  |
| `POST` | `/api/v1/payment/orders/{id}/cancel` | user JWT | `frontend/src/api/payment.ts:62` |  |
| `POST` | `/api/v1/payment/orders/{id}/refund-request` | user JWT | `frontend/src/api/payment.ts:82` |  |
| `GET` | `/api/v1/payment/plans` | user JWT | `frontend/src/api/payment.ts:27` |  |
| `POST` | `/api/v1/payment/public/orders/resolve` | public | `frontend/src/api/payment.ts:77` |  |
| `POST` | `/api/v1/payment/public/orders/verify` | public | `frontend/src/api/payment.ts:72` |  |
| `POST` | `/api/v1/payment/webhook/airwallex` | public webhook | `frontend/src/components/payment/providerConfig.ts` | displayed/configured webhook URL |
| `POST` | `/api/v1/payment/webhook/alipay` | public webhook | `frontend/src/components/payment/providerConfig.ts` | displayed/configured webhook URL |
| `GET` | `/api/v1/payment/webhook/easypay` | public webhook | `frontend/src/components/payment/providerConfig.ts` | displayed/configured webhook URL |
| `POST` | `/api/v1/payment/webhook/easypay` | public webhook | `frontend/src/components/payment/providerConfig.ts` | displayed/configured webhook URL |
| `POST` | `/api/v1/payment/webhook/stripe` | public webhook | `frontend/src/components/payment/providerConfig.ts` | displayed/configured webhook URL |
| `POST` | `/api/v1/payment/webhook/wxpay` | public webhook | `frontend/src/components/payment/providerConfig.ts` | displayed/configured webhook URL |

## Admin

| Method | Path | Auth / Access | Source | Notes |
|---|---|---|---|---|
| `GET` | `/api/v1/admin/accounts` | admin JWT | `frontend/src/api/admin/accounts.ts:50`<br>`frontend/src/api/admin/accounts.ts:91` |  |
| `POST` | `/api/v1/admin/accounts` | admin JWT | `frontend/src/api/admin/accounts.ts:134` |  |
| `GET` | `/api/v1/admin/accounts/antigravity/default-model-mapping` | admin JWT | `frontend/src/api/admin/accounts.ts:579` |  |
| `POST` | `/api/v1/admin/accounts/batch` | admin JWT | `frontend/src/api/admin/accounts.ts:341` |  |
| `POST` | `/api/v1/admin/accounts/batch-clear-error` | admin JWT | `frontend/src/api/admin/accounts.ts:627` |  |
| `POST` | `/api/v1/admin/accounts/batch-refresh` | admin JWT | `frontend/src/api/admin/accounts.ts:639` |  |
| `POST` | `/api/v1/admin/accounts/batch-update-credentials` | admin JWT | `frontend/src/api/admin/accounts.ts:363` |  |
| `POST` | `/api/v1/admin/accounts/bulk-update` | admin JWT | `frontend/src/api/admin/accounts.ts:393` |  |
| `POST` | `/api/v1/admin/accounts/check-mixed-channel` | admin JWT | `frontend/src/api/admin/accounts.ts:155` |  |
| `POST` | `/api/v1/admin/accounts/cookie-auth` | admin JWT | `frontend/src/composables/useAccountOAuth.ts` | Claude cookie auth |
| `GET` | `/api/v1/admin/accounts/data` | admin JWT | `frontend/src/api/admin/accounts.ts:554` |  |
| `POST` | `/api/v1/admin/accounts/data` | admin JWT | `frontend/src/api/admin/accounts.ts:562` |  |
| `POST` | `/api/v1/admin/accounts/exchange-code` | admin JWT | `frontend/src/composables/useAccountOAuth.ts` | Claude OAuth code exchange |
| `POST` | `/api/v1/admin/accounts/exchange-setup-token-code` | admin JWT | `frontend/src/composables/useAccountOAuth.ts` | Claude setup-token code exchange |
| `POST` | `/api/v1/admin/accounts/generate-auth-url` | admin JWT | `frontend/src/composables/useAccountOAuth.ts` | Claude OAuth auth URL |
| `POST` | `/api/v1/admin/accounts/generate-setup-token-url` | admin JWT | `frontend/src/composables/useAccountOAuth.ts` | Claude setup-token auth URL |
| `POST` | `/api/v1/admin/accounts/import/codex-session` | admin JWT | `frontend/src/api/admin/accounts.ts:570` |  |
| `POST` | `/api/v1/admin/accounts/setup-token-cookie-auth` | admin JWT | `frontend/src/composables/useAccountOAuth.ts; frontend/src/components/account/*AccountModal.vue` | Claude setup-token cookie auth |
| `POST` | `/api/v1/admin/accounts/sync/crs` | admin JWT | `frontend/src/api/admin/accounts.ts:507` |  |
| `POST` | `/api/v1/admin/accounts/sync/crs/preview` | admin JWT | `frontend/src/api/admin/accounts.ts:484` |  |
| `POST` | `/api/v1/admin/accounts/today-stats/batch` | admin JWT | `frontend/src/api/admin/accounts.ts:423` |  |
| `GET` | `/api/v1/admin/accounts/{accountId}/scheduled-test-plans` | admin JWT | `frontend/src/api/admin/scheduledTests.ts:20` |  |
| `GET` | `/api/v1/admin/accounts/{id}` | admin JWT | `frontend/src/api/admin/accounts.ts:124` |  |
| `PUT` | `/api/v1/admin/accounts/{id}` | admin JWT | `frontend/src/api/admin/accounts.ts:145` |  |
| `DELETE` | `/api/v1/admin/accounts/{id}` | admin JWT | `frontend/src/api/admin/accounts.ts:165` |  |
| `POST` | `/api/v1/admin/accounts/{id}/clear-error` | admin JWT | `frontend/src/api/admin/accounts.ts:226` |  |
| `POST` | `/api/v1/admin/accounts/{id}/clear-rate-limit` | admin JWT | `frontend/src/api/admin/accounts.ts:251` |  |
| `GET` | `/api/v1/admin/accounts/{id}/models` | admin JWT | `frontend/src/api/admin/accounts.ts:448` |  |
| `POST` | `/api/v1/admin/accounts/{id}/models/sync-upstream` | admin JWT | `frontend/src/api/admin/accounts.ts:462` |  |
| `POST` | `/api/v1/admin/accounts/{id}/recover-state` | admin JWT | `frontend/src/api/admin/accounts.ts:263` |  |
| `POST` | `/api/v1/admin/accounts/{id}/refresh` | admin JWT | `frontend/src/api/admin/accounts.ts:203` |  |
| `POST` | `/api/v1/admin/accounts/{id}/reset-quota` | admin JWT | `frontend/src/api/admin/accounts.ts:273` |  |
| `POST` | `/api/v1/admin/accounts/{id}/schedulable` | admin JWT | `frontend/src/api/admin/accounts.ts:436` |  |
| `POST` | `/api/v1/admin/accounts/{id}/set-privacy` | admin JWT | `frontend/src/api/admin/accounts.ts:653` |  |
| `GET` | `/api/v1/admin/accounts/{id}/stats` | admin JWT | `frontend/src/api/admin/accounts.ts:214` |  |
| `GET` | `/api/v1/admin/accounts/{id}/temp-unschedulable` | admin JWT | `frontend/src/api/admin/accounts.ts:285` |  |
| `DELETE` | `/api/v1/admin/accounts/{id}/temp-unschedulable` | admin JWT | `frontend/src/api/admin/accounts.ts:297` |  |
| `POST` | `/api/v1/admin/accounts/{id}/test` | admin JWT | `frontend/src/api/admin/accounts.ts:189`<br>`frontend/src/components/admin/account/AccountTestModal.vue; frontend/src/components/account/AccountTestModal.vue` | fetch streaming/SSE variant |
| `GET` | `/api/v1/admin/accounts/{id}/today-stats` | admin JWT | `frontend/src/api/admin/accounts.ts:409` |  |
| `GET` | `/api/v1/admin/accounts/{id}/usage` | admin JWT | `frontend/src/api/admin/accounts.ts:239` |  |
| `GET` | `/api/v1/admin/affiliates/invites` | admin JWT | `frontend/src/api/admin/affiliates.ts:182` |  |
| `GET` | `/api/v1/admin/affiliates/rebates` | admin JWT | `frontend/src/api/admin/affiliates.ts:192` |  |
| `GET` | `/api/v1/admin/affiliates/transfers` | admin JWT | `frontend/src/api/admin/affiliates.ts:202` |  |
| `GET` | `/api/v1/admin/affiliates/users` | admin JWT | `frontend/src/api/admin/affiliates.ts:115` |  |
| `POST` | `/api/v1/admin/affiliates/users/batch-rate` | admin JWT | `frontend/src/api/admin/affiliates.ts:159` |  |
| `GET` | `/api/v1/admin/affiliates/users/lookup` | admin JWT | `frontend/src/api/admin/affiliates.ts:129` |  |
| `PUT` | `/api/v1/admin/affiliates/users/{userId}` | admin JWT | `frontend/src/api/admin/affiliates.ts:140` |  |
| `DELETE` | `/api/v1/admin/affiliates/users/{userId}` | admin JWT | `frontend/src/api/admin/affiliates.ts:150` |  |
| `GET` | `/api/v1/admin/affiliates/users/{userId}/overview` | admin JWT | `frontend/src/api/admin/affiliates.ts:212` |  |
| `GET` | `/api/v1/admin/announcements` | admin JWT | `frontend/src/api/admin/announcements.ts:27` |  |
| `POST` | `/api/v1/admin/announcements` | admin JWT | `frontend/src/api/admin/announcements.ts:40` |  |
| `GET` | `/api/v1/admin/announcements/{id}` | admin JWT | `frontend/src/api/admin/announcements.ts:35` |  |
| `PUT` | `/api/v1/admin/announcements/{id}` | admin JWT | `frontend/src/api/admin/announcements.ts:45` |  |
| `DELETE` | `/api/v1/admin/announcements/{id}` | admin JWT | `frontend/src/api/admin/announcements.ts:50` |  |
| `GET` | `/api/v1/admin/announcements/{id}/read-status` | admin JWT | `frontend/src/api/admin/announcements.ts:67` |  |
| `POST` | `/api/v1/admin/antigravity/oauth/auth-url` | admin JWT | `frontend/src/api/admin/antigravity.ts:39` |  |
| `POST` | `/api/v1/admin/antigravity/oauth/exchange-code` | admin JWT | `frontend/src/api/admin/antigravity.ts:49` |  |
| `POST` | `/api/v1/admin/antigravity/oauth/refresh-token` | admin JWT | `frontend/src/api/admin/antigravity.ts:63` |  |
| `PUT` | `/api/v1/admin/api-keys/{id}` | admin JWT | `frontend/src/api/admin/apiKeys.ts:23` |  |
| `GET` | `/api/v1/admin/backups` | admin JWT | `frontend/src/api/admin/backup.ts:81` |  |
| `POST` | `/api/v1/admin/backups` | admin JWT | `frontend/src/api/admin/backup.ts:76` |  |
| `GET` | `/api/v1/admin/backups/s3-config` | admin JWT | `frontend/src/api/admin/backup.ts:49` |  |
| `PUT` | `/api/v1/admin/backups/s3-config` | admin JWT | `frontend/src/api/admin/backup.ts:54` |  |
| `POST` | `/api/v1/admin/backups/s3-config/test` | admin JWT | `frontend/src/api/admin/backup.ts:59` |  |
| `GET` | `/api/v1/admin/backups/schedule` | admin JWT | `frontend/src/api/admin/backup.ts:65` |  |
| `PUT` | `/api/v1/admin/backups/schedule` | admin JWT | `frontend/src/api/admin/backup.ts:70` |  |
| `GET` | `/api/v1/admin/backups/{id}` | admin JWT | `frontend/src/api/admin/backup.ts:86` |  |
| `DELETE` | `/api/v1/admin/backups/{id}` | admin JWT | `frontend/src/api/admin/backup.ts:91` |  |
| `GET` | `/api/v1/admin/backups/{id}/download-url` | admin JWT | `frontend/src/api/admin/backup.ts:95` |  |
| `POST` | `/api/v1/admin/backups/{id}/restore` | admin JWT | `frontend/src/api/admin/backup.ts:101` |  |
| `GET` | `/api/v1/admin/channel-monitor-templates` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:71` |  |
| `POST` | `/api/v1/admin/channel-monitor-templates` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:85` |  |
| `GET` | `/api/v1/admin/channel-monitor-templates/{id}` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:78` |  |
| `PUT` | `/api/v1/admin/channel-monitor-templates/{id}` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:93` |  |
| `DELETE` | `/api/v1/admin/channel-monitor-templates/{id}` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:101` |  |
| `POST` | `/api/v1/admin/channel-monitor-templates/{id}/apply` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:110` |  |
| `GET` | `/api/v1/admin/channel-monitor-templates/{id}/monitors` | admin JWT | `frontend/src/api/admin/channelMonitorTemplate.ts:121` |  |
| `GET` | `/api/v1/admin/channel-monitors` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:133` |  |
| `POST` | `/api/v1/admin/channel-monitors` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:152` |  |
| `GET` | `/api/v1/admin/channel-monitors/{id}` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:144` |  |
| `PUT` | `/api/v1/admin/channel-monitors/{id}` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:161` |  |
| `DELETE` | `/api/v1/admin/channel-monitors/{id}` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:169` |  |
| `GET` | `/api/v1/admin/channel-monitors/{id}/history` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:188` |  |
| `POST` | `/api/v1/admin/channel-monitors/{id}/run` | admin JWT | `frontend/src/api/admin/channelMonitor.ts:177` |  |
| `GET` | `/api/v1/admin/channels` | admin JWT | `frontend/src/api/admin/channels.ts:109` |  |
| `POST` | `/api/v1/admin/channels` | admin JWT | `frontend/src/api/admin/channels.ts:132` |  |
| `GET` | `/api/v1/admin/channels/model-pricing` | admin JWT | `frontend/src/api/admin/channels.ts:161` |  |
| `GET` | `/api/v1/admin/channels/pricing/sync-models` | admin JWT | `frontend/src/api/admin/channels.ts:175` |  |
| `GET` | `/api/v1/admin/channels/{id}` | admin JWT | `frontend/src/api/admin/channels.ts:124` |  |
| `PUT` | `/api/v1/admin/channels/{id}` | admin JWT | `frontend/src/api/admin/channels.ts:140` |  |
| `DELETE` | `/api/v1/admin/channels/{id}` | admin JWT | `frontend/src/api/admin/channels.ts:148` |  |
| `GET` | `/api/v1/admin/dashboard/api-keys-trend` | admin JWT | `frontend/src/api/admin/dashboard.ts:221` |  |
| `POST` | `/api/v1/admin/dashboard/api-keys-usage` | admin JWT | `frontend/src/api/admin/dashboard.ts:316` |  |
| `GET` | `/api/v1/admin/dashboard/groups` | admin JWT | `frontend/src/api/admin/dashboard.ts:157` |  |
| `GET` | `/api/v1/admin/dashboard/models` | admin JWT | `frontend/src/api/admin/dashboard.ts:104` |  |
| `GET` | `/api/v1/admin/dashboard/realtime` | admin JWT | `frontend/src/api/admin/dashboard.ts:38` |  |
| `GET` | `/api/v1/admin/dashboard/snapshot-v2` | admin JWT | `frontend/src/api/admin/dashboard.ts:196` |  |
| `GET` | `/api/v1/admin/dashboard/stats` | admin JWT | `frontend/src/api/admin/dashboard.ts:24` |  |
| `GET` | `/api/v1/admin/dashboard/trend` | admin JWT | `frontend/src/api/admin/dashboard.ts:74` |  |
| `GET` | `/api/v1/admin/dashboard/user-breakdown` | admin JWT | `frontend/src/api/admin/dashboard.ts:186` |  |
| `GET` | `/api/v1/admin/dashboard/users-ranking` | admin JWT | `frontend/src/api/admin/dashboard.ts:263` |  |
| `GET` | `/api/v1/admin/dashboard/users-trend` | admin JWT | `frontend/src/api/admin/dashboard.ts:249` |  |
| `POST` | `/api/v1/admin/dashboard/users-usage` | admin JWT | `frontend/src/api/admin/dashboard.ts:292` |  |
| `GET` | `/api/v1/admin/data-management/agent/health` | admin JWT | `frontend/src/api/admin/dataManagement.ts:220` |  |
| `GET` | `/api/v1/admin/data-management/backups` | admin JWT | `frontend/src/api/admin/dataManagement.ts:301` |  |
| `POST` | `/api/v1/admin/data-management/backups` | admin JWT | `frontend/src/api/admin/dataManagement.ts:292` |  |
| `GET` | `/api/v1/admin/data-management/backups/{jobID}` | admin JWT | `frontend/src/api/admin/dataManagement.ts:308` |  |
| `GET` | `/api/v1/admin/data-management/config` | admin JWT | `frontend/src/api/admin/dataManagement.ts:225` |  |
| `PUT` | `/api/v1/admin/data-management/config` | admin JWT | `frontend/src/api/admin/dataManagement.ts:230` |  |
| `GET` | `/api/v1/admin/data-management/s3/profiles` | admin JWT | `frontend/src/api/admin/dataManagement.ts:264` |  |
| `POST` | `/api/v1/admin/data-management/s3/profiles` | admin JWT | `frontend/src/api/admin/dataManagement.ts:269` |  |
| `PUT` | `/api/v1/admin/data-management/s3/profiles/{profileID}` | admin JWT | `frontend/src/api/admin/dataManagement.ts:274` |  |
| `DELETE` | `/api/v1/admin/data-management/s3/profiles/{profileID}` | admin JWT | `frontend/src/api/admin/dataManagement.ts:279` |  |
| `POST` | `/api/v1/admin/data-management/s3/profiles/{profileID}/activate` | admin JWT | `frontend/src/api/admin/dataManagement.ts:283` |  |
| `POST` | `/api/v1/admin/data-management/s3/test` | admin JWT | `frontend/src/api/admin/dataManagement.ts:235` |  |
| `GET` | `/api/v1/admin/data-management/sources/{sourceType}/profiles` | admin JWT | `frontend/src/api/admin/dataManagement.ts:240` |  |
| `POST` | `/api/v1/admin/data-management/sources/{sourceType}/profiles` | admin JWT | `frontend/src/api/admin/dataManagement.ts:245` |  |
| `PUT` | `/api/v1/admin/data-management/sources/{sourceType}/profiles/{profileID}` | admin JWT | `frontend/src/api/admin/dataManagement.ts:250` |  |
| `DELETE` | `/api/v1/admin/data-management/sources/{sourceType}/profiles/{profileID}` | admin JWT | `frontend/src/api/admin/dataManagement.ts:255` |  |
| `POST` | `/api/v1/admin/data-management/sources/{sourceType}/profiles/{profileID}/activate` | admin JWT | `frontend/src/api/admin/dataManagement.ts:259` |  |
| `GET` | `/api/v1/admin/error-passthrough-rules` | admin JWT | `frontend/src/api/admin/errorPassthrough.ts:73` |  |
| `POST` | `/api/v1/admin/error-passthrough-rules` | admin JWT | `frontend/src/api/admin/errorPassthrough.ts:93` |  |
| `GET` | `/api/v1/admin/error-passthrough-rules/{id}` | admin JWT | `frontend/src/api/admin/errorPassthrough.ts:83` |  |
| `PUT` | `/api/v1/admin/error-passthrough-rules/{id}` | admin JWT | `frontend/src/api/admin/errorPassthrough.ts:104` |  |
| `DELETE` | `/api/v1/admin/error-passthrough-rules/{id}` | admin JWT | `frontend/src/api/admin/errorPassthrough.ts:114` |  |
| `POST` | `/api/v1/admin/gemini/oauth/auth-url` | admin JWT | `frontend/src/api/admin/gemini.ts:52` |  |
| `GET` | `/api/v1/admin/gemini/oauth/capabilities` | admin JWT | `frontend/src/api/admin/gemini.ts:68` |  |
| `POST` | `/api/v1/admin/gemini/oauth/exchange-code` | admin JWT | `frontend/src/api/admin/gemini.ts:60` |  |
| `GET` | `/api/v1/admin/groups` | admin JWT | `frontend/src/api/admin/groups.ts:37` |  |
| `POST` | `/api/v1/admin/groups` | admin JWT | `frontend/src/api/admin/groups.ts:85` |  |
| `GET` | `/api/v1/admin/groups/all` | admin JWT | `frontend/src/api/admin/groups.ts:54` |  |
| `GET` | `/api/v1/admin/groups/capacity-summary` | admin JWT | `frontend/src/api/admin/groups.ts:298` |  |
| `PUT` | `/api/v1/admin/groups/sort-order` | admin JWT | `frontend/src/api/admin/groups.ts:191` |  |
| `GET` | `/api/v1/admin/groups/usage-summary` | admin JWT | `frontend/src/api/admin/groups.ts:284` |  |
| `GET` | `/api/v1/admin/groups/{groupId}/subscriptions` | admin JWT | `frontend/src/api/admin/subscriptions.ts:153` |  |
| `GET` | `/api/v1/admin/groups/{id}` | admin JWT | `frontend/src/api/admin/groups.ts:75` |  |
| `PUT` | `/api/v1/admin/groups/{id}` | admin JWT | `frontend/src/api/admin/groups.ts:96` |  |
| `DELETE` | `/api/v1/admin/groups/{id}` | admin JWT | `frontend/src/api/admin/groups.ts:106` |  |
| `GET` | `/api/v1/admin/groups/{id}/api-keys` | admin JWT | `frontend/src/api/admin/groups.ts:152` |  |
| `GET` | `/api/v1/admin/groups/{id}/rate-multipliers` | admin JWT | `frontend/src/api/admin/groups.ts:177`<br>`frontend/src/api/admin/groups.ts:238` |  |
| `PUT` | `/api/v1/admin/groups/{id}/rate-multipliers` | admin JWT | `frontend/src/api/admin/groups.ts:215` |  |
| `DELETE` | `/api/v1/admin/groups/{id}/rate-multipliers` | admin JWT | `frontend/src/api/admin/groups.ts:203` |  |
| `PUT` | `/api/v1/admin/groups/{id}/rpm-overrides` | admin JWT | `frontend/src/api/admin/groups.ts:261` |  |
| `DELETE` | `/api/v1/admin/groups/{id}/rpm-overrides` | admin JWT | `frontend/src/api/admin/groups.ts:272` |  |
| `GET` | `/api/v1/admin/groups/{id}/stats` | admin JWT | `frontend/src/api/admin/groups.ts:131` |  |
| `POST` | `/api/v1/admin/openai/exchange-code` | admin JWT | `frontend/src/composables/useOpenAIOAuth.ts` | OpenAI OAuth code exchange |
| `POST` | `/api/v1/admin/openai/generate-auth-url` | admin JWT | `frontend/src/composables/useOpenAIOAuth.ts` | OpenAI OAuth auth URL |
| `POST` | `/api/v1/admin/openai/refresh-token` | admin JWT | `frontend/src/composables/useOpenAIOAuth.ts` | OpenAI refresh token validation |
| `GET` | `/api/v1/admin/ops/account-availability` | admin JWT | `frontend/src/api/admin/ops.ts:411` |  |
| `GET` | `/api/v1/admin/ops/advanced-settings` | admin JWT | `frontend/src/api/admin/ops.ts:1257` |  |
| `PUT` | `/api/v1/admin/ops/advanced-settings` | admin JWT | `frontend/src/api/admin/ops.ts:1262` |  |
| `GET` | `/api/v1/admin/ops/alert-events` | admin JWT | `frontend/src/api/admin/ops.ts:1179` |  |
| `GET` | `/api/v1/admin/ops/alert-events/{id}` | admin JWT | `frontend/src/api/admin/ops.ts:1184` |  |
| `PUT` | `/api/v1/admin/ops/alert-events/{id}/status` | admin JWT | `frontend/src/api/admin/ops.ts:1189` |  |
| `GET` | `/api/v1/admin/ops/alert-rules` | admin JWT | `frontend/src/api/admin/ops.ts:1146` |  |
| `POST` | `/api/v1/admin/ops/alert-rules` | admin JWT | `frontend/src/api/admin/ops.ts:1151` |  |
| `PUT` | `/api/v1/admin/ops/alert-rules/{id}` | admin JWT | `frontend/src/api/admin/ops.ts:1156` |  |
| `DELETE` | `/api/v1/admin/ops/alert-rules/{id}` | admin JWT | `frontend/src/api/admin/ops.ts:1161` |  |
| `POST` | `/api/v1/admin/ops/alert-silences` | admin JWT | `frontend/src/api/admin/ops.ts:1200` |  |
| `GET` | `/api/v1/admin/ops/concurrency` | admin JWT | `frontend/src/api/admin/ops.ts:350` |  |
| `GET` | `/api/v1/admin/ops/dashboard/error-distribution` | admin JWT | `frontend/src/api/admin/ops.ts:1043` |  |
| `GET` | `/api/v1/admin/ops/dashboard/error-trend` | admin JWT | `frontend/src/api/admin/ops.ts:1025` |  |
| `GET` | `/api/v1/admin/ops/dashboard/latency-histogram` | admin JWT | `frontend/src/api/admin/ops.ts:1007` |  |
| `GET` | `/api/v1/admin/ops/dashboard/openai-token-stats` | admin JWT | `frontend/src/api/admin/ops.ts:1054` |  |
| `GET` | `/api/v1/admin/ops/dashboard/overview` | admin JWT | `frontend/src/api/admin/ops.ts:953` |  |
| `GET` | `/api/v1/admin/ops/dashboard/snapshot-v2` | admin JWT | `frontend/src/api/admin/ops.ts:971` |  |
| `GET` | `/api/v1/admin/ops/dashboard/throughput-trend` | admin JWT | `frontend/src/api/admin/ops.ts:989` |  |
| `GET` | `/api/v1/admin/ops/email-notification/config` | admin JWT | `frontend/src/api/admin/ops.ts:1205` |  |
| `PUT` | `/api/v1/admin/ops/email-notification/config` | admin JWT | `frontend/src/api/admin/ops.ts:1210` |  |
| `GET` | `/api/v1/admin/ops/errors` | admin JWT | `frontend/src/api/admin/ops.ts:1086` |  |
| `PUT` | `/api/v1/admin/ops/errors/{errorId}/resolve` | admin JWT | `frontend/src/api/admin/ops.ts:1096` |  |
| `GET` | `/api/v1/admin/ops/errors/{id}` | admin JWT | `frontend/src/api/admin/ops.ts:1091` |  |
| `GET` | `/api/v1/admin/ops/realtime-traffic` | admin JWT | `frontend/src/api/admin/ops.ts:450` |  |
| `GET` | `/api/v1/admin/ops/request-errors` | admin JWT | `frontend/src/api/admin/ops.ts:1101` |  |
| `PUT` | `/api/v1/admin/ops/request-errors/{errorId}/resolve` | admin JWT | `frontend/src/api/admin/ops.ts:1121` |  |
| `GET` | `/api/v1/admin/ops/request-errors/{id}` | admin JWT | `frontend/src/api/admin/ops.ts:1111` |  |
| `GET` | `/api/v1/admin/ops/request-errors/{id}/upstream-errors` | admin JWT | `frontend/src/api/admin/ops.ts:1135` |  |
| `GET` | `/api/v1/admin/ops/requests` | admin JWT | `frontend/src/api/admin/ops.ts:1140` |  |
| `GET` | `/api/v1/admin/ops/runtime/alert` | admin JWT | `frontend/src/api/admin/ops.ts:1216` |  |
| `PUT` | `/api/v1/admin/ops/runtime/alert` | admin JWT | `frontend/src/api/admin/ops.ts:1221` |  |
| `GET` | `/api/v1/admin/ops/runtime/logging` | admin JWT | `frontend/src/api/admin/ops.ts:1226` |  |
| `PUT` | `/api/v1/admin/ops/runtime/logging` | admin JWT | `frontend/src/api/admin/ops.ts:1231` |  |
| `POST` | `/api/v1/admin/ops/runtime/logging/reset` | admin JWT | `frontend/src/api/admin/ops.ts:1236` |  |
| `GET` | `/api/v1/admin/ops/settings/metric-thresholds` | admin JWT | `frontend/src/api/admin/ops.ts:1269` |  |
| `PUT` | `/api/v1/admin/ops/settings/metric-thresholds` | admin JWT | `frontend/src/api/admin/ops.ts:1274` |  |
| `GET` | `/api/v1/admin/ops/system-logs` | admin JWT | `frontend/src/api/admin/ops.ts:1241` |  |
| `POST` | `/api/v1/admin/ops/system-logs/cleanup` | admin JWT | `frontend/src/api/admin/ops.ts:1246` |  |
| `GET` | `/api/v1/admin/ops/system-logs/health` | admin JWT | `frontend/src/api/admin/ops.ts:1251` |  |
| `GET` | `/api/v1/admin/ops/upstream-errors` | admin JWT | `frontend/src/api/admin/ops.ts:1106` |  |
| `PUT` | `/api/v1/admin/ops/upstream-errors/{errorId}/resolve` | admin JWT | `frontend/src/api/admin/ops.ts:1125` |  |
| `GET` | `/api/v1/admin/ops/upstream-errors/{id}` | admin JWT | `frontend/src/api/admin/ops.ts:1116` |  |
| `GET` | `/api/v1/admin/ops/user-concurrency` | admin JWT | `frontend/src/api/admin/ops.ts:355` |  |
| `WS` | `/api/v1/admin/ops/ws/qps` | admin JWT | `frontend/src/api/admin/ops.ts` | ops realtime WebSocket; subprotocol carries jwt token |
| `GET` | `/api/v1/admin/payment/channels` | admin JWT | `frontend/src/api/admin/payment.ts:115` |  |
| `POST` | `/api/v1/admin/payment/channels` | admin JWT | `frontend/src/api/admin/payment.ts:120` |  |
| `PUT` | `/api/v1/admin/payment/channels/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:125` |  |
| `DELETE` | `/api/v1/admin/payment/channels/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:130` |  |
| `GET` | `/api/v1/admin/payment/config` | admin JWT | `frontend/src/api/admin/payment.ts:57` |  |
| `PUT` | `/api/v1/admin/payment/config` | admin JWT | `frontend/src/api/admin/payment.ts:62` |  |
| `GET` | `/api/v1/admin/payment/dashboard` | admin JWT | `frontend/src/api/admin/payment.ts:69` |  |
| `GET` | `/api/v1/admin/payment/orders` | admin JWT | `frontend/src/api/admin/payment.ts:88` |  |
| `GET` | `/api/v1/admin/payment/orders/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:93` |  |
| `POST` | `/api/v1/admin/payment/orders/{id}/cancel` | admin JWT | `frontend/src/api/admin/payment.ts:98` |  |
| `POST` | `/api/v1/admin/payment/orders/{id}/refund` | admin JWT | `frontend/src/api/admin/payment.ts:108` |  |
| `POST` | `/api/v1/admin/payment/orders/{id}/retry` | admin JWT | `frontend/src/api/admin/payment.ts:103` |  |
| `GET` | `/api/v1/admin/payment/plans` | admin JWT | `frontend/src/api/admin/payment.ts:137` |  |
| `POST` | `/api/v1/admin/payment/plans` | admin JWT | `frontend/src/api/admin/payment.ts:142` |  |
| `PUT` | `/api/v1/admin/payment/plans/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:147` |  |
| `DELETE` | `/api/v1/admin/payment/plans/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:152` |  |
| `GET` | `/api/v1/admin/payment/providers` | admin JWT | `frontend/src/api/admin/payment.ts:159` |  |
| `POST` | `/api/v1/admin/payment/providers` | admin JWT | `frontend/src/api/admin/payment.ts:164` |  |
| `PUT` | `/api/v1/admin/payment/providers/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:169` |  |
| `DELETE` | `/api/v1/admin/payment/providers/{id}` | admin JWT | `frontend/src/api/admin/payment.ts:174` |  |
| `GET` | `/api/v1/admin/promo-codes` | admin JWT | `frontend/src/api/admin/promo.ts:27` |  |
| `POST` | `/api/v1/admin/promo-codes` | admin JWT | `frontend/src/api/admin/promo.ts:40` |  |
| `GET` | `/api/v1/admin/promo-codes/{id}` | admin JWT | `frontend/src/api/admin/promo.ts:35` |  |
| `PUT` | `/api/v1/admin/promo-codes/{id}` | admin JWT | `frontend/src/api/admin/promo.ts:45` |  |
| `DELETE` | `/api/v1/admin/promo-codes/{id}` | admin JWT | `frontend/src/api/admin/promo.ts:50` |  |
| `GET` | `/api/v1/admin/promo-codes/{id}/usages` | admin JWT | `frontend/src/api/admin/promo.ts:59` |  |
| `GET` | `/api/v1/admin/proxies` | admin JWT | `frontend/src/api/admin/proxies.ts:39` |  |
| `POST` | `/api/v1/admin/proxies` | admin JWT | `frontend/src/api/admin/proxies.ts:86` |  |
| `GET` | `/api/v1/admin/proxies/all` | admin JWT | `frontend/src/api/admin/proxies.ts:55`<br>`frontend/src/api/admin/proxies.ts:64` |  |
| `POST` | `/api/v1/admin/proxies/batch` | admin JWT | `frontend/src/api/admin/proxies.ts:208` |  |
| `POST` | `/api/v1/admin/proxies/batch-delete` | admin JWT | `frontend/src/api/admin/proxies.ts:219` |  |
| `GET` | `/api/v1/admin/proxies/data` | admin JWT | `frontend/src/api/admin/proxies.ts:247` |  |
| `POST` | `/api/v1/admin/proxies/data` | admin JWT | `frontend/src/api/admin/proxies.ts:254` |  |
| `GET` | `/api/v1/admin/proxies/{id}` | admin JWT | `frontend/src/api/admin/proxies.ts:76` |  |
| `PUT` | `/api/v1/admin/proxies/{id}` | admin JWT | `frontend/src/api/admin/proxies.ts:97` |  |
| `DELETE` | `/api/v1/admin/proxies/{id}` | admin JWT | `frontend/src/api/admin/proxies.ts:107` |  |
| `GET` | `/api/v1/admin/proxies/{id}/accounts` | admin JWT | `frontend/src/api/admin/proxies.ts:187` |  |
| `POST` | `/api/v1/admin/proxies/{id}/quality-check` | admin JWT | `frontend/src/api/admin/proxies.ts:155` |  |
| `GET` | `/api/v1/admin/proxies/{id}/stats` | admin JWT | `frontend/src/api/admin/proxies.ts:171` |  |
| `POST` | `/api/v1/admin/proxies/{id}/test` | admin JWT | `frontend/src/api/admin/proxies.ts:136` |  |
| `GET` | `/api/v1/admin/redeem-codes` | admin JWT | `frontend/src/api/admin/redeem.ts:36` |  |
| `POST` | `/api/v1/admin/redeem-codes/batch-delete` | admin JWT | `frontend/src/api/admin/redeem.ts:115` |  |
| `POST` | `/api/v1/admin/redeem-codes/batch-update` | admin JWT | `frontend/src/api/admin/redeem.ts:135` |  |
| `GET` | `/api/v1/admin/redeem-codes/export` | admin JWT | `frontend/src/api/admin/redeem.ts:187` |  |
| `POST` | `/api/v1/admin/redeem-codes/generate` | admin JWT | `frontend/src/api/admin/redeem.ts:92` |  |
| `GET` | `/api/v1/admin/redeem-codes/stats` | admin JWT | `frontend/src/api/admin/redeem.ts:164` |  |
| `GET` | `/api/v1/admin/redeem-codes/{id}` | admin JWT | `frontend/src/api/admin/redeem.ts:53` |  |
| `DELETE` | `/api/v1/admin/redeem-codes/{id}` | admin JWT | `frontend/src/api/admin/redeem.ts:102` |  |
| `POST` | `/api/v1/admin/redeem-codes/{id}/expire` | admin JWT | `frontend/src/api/admin/redeem.ts:148` |  |
| `POST` | `/api/v1/admin/risk-control/api-keys/test` | admin JWT | `frontend/src/api/admin/riskControl.ts:215` |  |
| `GET` | `/api/v1/admin/risk-control/config` | admin JWT | `frontend/src/api/admin/riskControl.ts:196` |  |
| `PUT` | `/api/v1/admin/risk-control/config` | admin JWT | `frontend/src/api/admin/riskControl.ts:203` |  |
| `DELETE` | `/api/v1/admin/risk-control/hashes` | admin JWT | `frontend/src/api/admin/riskControl.ts:236` |  |
| `DELETE` | `/api/v1/admin/risk-control/hashes/all` | admin JWT | `frontend/src/api/admin/riskControl.ts:243` |  |
| `GET` | `/api/v1/admin/risk-control/logs` | admin JWT | `frontend/src/api/admin/riskControl.ts:222` |  |
| `GET` | `/api/v1/admin/risk-control/status` | admin JWT | `frontend/src/api/admin/riskControl.ts:208` |  |
| `POST` | `/api/v1/admin/risk-control/users/{userID}/unban` | admin JWT | `frontend/src/api/admin/riskControl.ts:229` |  |
| `POST` | `/api/v1/admin/scheduled-test-plans` | admin JWT | `frontend/src/api/admin/scheduledTests.ts:32` |  |
| `PUT` | `/api/v1/admin/scheduled-test-plans/{id}` | admin JWT | `frontend/src/api/admin/scheduledTests.ts:46` |  |
| `DELETE` | `/api/v1/admin/scheduled-test-plans/{id}` | admin JWT | `frontend/src/api/admin/scheduledTests.ts:58` |  |
| `GET` | `/api/v1/admin/scheduled-test-plans/{planId}/results` | admin JWT | `frontend/src/api/admin/scheduledTests.ts:68` |  |
| `GET` | `/api/v1/admin/settings` | admin JWT | `frontend/src/api/admin/settings.ts:787` |  |
| `PUT` | `/api/v1/admin/settings` | admin JWT | `frontend/src/api/admin/settings.ts:799` |  |
| `GET` | `/api/v1/admin/settings/admin-api-key` | admin JWT | `frontend/src/api/admin/settings.ts:975` |  |
| `DELETE` | `/api/v1/admin/settings/admin-api-key` | admin JWT | `frontend/src/api/admin/settings.ts:997` |  |
| `POST` | `/api/v1/admin/settings/admin-api-key/regenerate` | admin JWT | `frontend/src/api/admin/settings.ts:986` |  |
| `GET` | `/api/v1/admin/settings/beta-policy` | admin JWT | `frontend/src/api/admin/settings.ts:1182` |  |
| `PUT` | `/api/v1/admin/settings/beta-policy` | admin JWT | `frontend/src/api/admin/settings.ts:1196` |  |
| `POST` | `/api/v1/admin/settings/email-template-preview` | admin JWT | `frontend/src/api/admin/settings.ts:955` |  |
| `GET` | `/api/v1/admin/settings/email-templates` | admin JWT | `frontend/src/api/admin/settings.ts:914` |  |
| `GET` | `/api/v1/admin/settings/email-templates/{event}/{locale}` | admin JWT | `frontend/src/api/admin/settings.ts:924` |  |
| `PUT` | `/api/v1/admin/settings/email-templates/{event}/{locale}` | admin JWT | `frontend/src/api/admin/settings.ts:935` |  |
| `POST` | `/api/v1/admin/settings/email-templates/{event}/{locale}/restore-official` | admin JWT | `frontend/src/api/admin/settings.ts:946` |  |
| `GET` | `/api/v1/admin/settings/overload-cooldown` | admin JWT | `frontend/src/api/admin/settings.ts:1014` |  |
| `PUT` | `/api/v1/admin/settings/overload-cooldown` | admin JWT | `frontend/src/api/admin/settings.ts:1023` |  |
| `GET` | `/api/v1/admin/settings/rate-limit-429-cooldown` | admin JWT | `frontend/src/api/admin/settings.ts:1038` |  |
| `PUT` | `/api/v1/admin/settings/rate-limit-429-cooldown` | admin JWT | `frontend/src/api/admin/settings.ts:1047` |  |
| `GET` | `/api/v1/admin/settings/rectifier` | admin JWT | `frontend/src/api/admin/settings.ts:1111` |  |
| `PUT` | `/api/v1/admin/settings/rectifier` | admin JWT | `frontend/src/api/admin/settings.ts:1125` |  |
| `POST` | `/api/v1/admin/settings/send-test-email` | admin JWT | `frontend/src/api/admin/settings.ts:854` |  |
| `GET` | `/api/v1/admin/settings/stream-timeout` | admin JWT | `frontend/src/api/admin/settings.ts:1072` |  |
| `PUT` | `/api/v1/admin/settings/stream-timeout` | admin JWT | `frontend/src/api/admin/settings.ts:1086` |  |
| `POST` | `/api/v1/admin/settings/test-smtp` | admin JWT | `frontend/src/api/admin/settings.ts:825` |  |
| `GET` | `/api/v1/admin/settings/web-search-emulation` | admin JWT | `frontend/src/api/admin/settings.ts:1228` |  |
| `PUT` | `/api/v1/admin/settings/web-search-emulation` | admin JWT | `frontend/src/api/admin/settings.ts:1237` |  |
| `POST` | `/api/v1/admin/settings/web-search-emulation/reset-usage` | admin JWT | `frontend/src/api/admin/settings.ts:1257` |  |
| `POST` | `/api/v1/admin/settings/web-search-emulation/test` | admin JWT | `frontend/src/api/admin/settings.ts:1247` |  |
| `GET` | `/api/v1/admin/subscriptions` | admin JWT | `frontend/src/api/admin/subscriptions.ts:38` |  |
| `POST` | `/api/v1/admin/subscriptions/assign` | admin JWT | `frontend/src/api/admin/subscriptions.ts:78` |  |
| `POST` | `/api/v1/admin/subscriptions/bulk-assign` | admin JWT | `frontend/src/api/admin/subscriptions.ts:90` |  |
| `GET` | `/api/v1/admin/subscriptions/{id}` | admin JWT | `frontend/src/api/admin/subscriptions.ts:58` |  |
| `DELETE` | `/api/v1/admin/subscriptions/{id}` | admin JWT | `frontend/src/api/admin/subscriptions.ts:120` |  |
| `POST` | `/api/v1/admin/subscriptions/{id}/extend` | admin JWT | `frontend/src/api/admin/subscriptions.ts:107` |  |
| `GET` | `/api/v1/admin/subscriptions/{id}/progress` | admin JWT | `frontend/src/api/admin/subscriptions.ts:68` |  |
| `POST` | `/api/v1/admin/subscriptions/{id}/reset-quota` | admin JWT | `frontend/src/api/admin/subscriptions.ts:134` |  |
| `GET` | `/api/v1/admin/system/check-updates` | admin JWT | `frontend/src/api/admin/system.ts:37` |  |
| `POST` | `/api/v1/admin/system/restart` | admin JWT | `frontend/src/api/admin/system.ts:69` |  |
| `POST` | `/api/v1/admin/system/rollback` | admin JWT | `frontend/src/api/admin/system.ts:61` |  |
| `POST` | `/api/v1/admin/system/update` | admin JWT | `frontend/src/api/admin/system.ts:53` |  |
| `GET` | `/api/v1/admin/system/version` | admin JWT | `frontend/src/api/admin/system.ts:28` |  |
| `GET` | `/api/v1/admin/tls-fingerprint-profiles` | admin JWT | `frontend/src/api/admin/tlsFingerprintProfile.ts:66` |  |
| `POST` | `/api/v1/admin/tls-fingerprint-profiles` | admin JWT | `frontend/src/api/admin/tlsFingerprintProfile.ts:76` |  |
| `GET` | `/api/v1/admin/tls-fingerprint-profiles/{id}` | admin JWT | `frontend/src/api/admin/tlsFingerprintProfile.ts:71` |  |
| `PUT` | `/api/v1/admin/tls-fingerprint-profiles/{id}` | admin JWT | `frontend/src/api/admin/tlsFingerprintProfile.ts:81` |  |
| `DELETE` | `/api/v1/admin/tls-fingerprint-profiles/{id}` | admin JWT | `frontend/src/api/admin/tlsFingerprintProfile.ts:86` |  |
| `GET` | `/api/v1/admin/usage` | admin JWT | `frontend/src/api/admin/usage.ts:99` |  |
| `GET` | `/api/v1/admin/usage/cleanup-tasks` | admin JWT | `frontend/src/api/admin/usage.ts:171` |  |
| `POST` | `/api/v1/admin/usage/cleanup-tasks` | admin JWT | `frontend/src/api/admin/usage.ts:184` |  |
| `POST` | `/api/v1/admin/usage/cleanup-tasks/{taskId}/cancel` | admin JWT | `frontend/src/api/admin/usage.ts:193` |  |
| `GET` | `/api/v1/admin/usage/search-api-keys` | admin JWT | `frontend/src/api/admin/usage.ts:156` |  |
| `GET` | `/api/v1/admin/usage/search-users` | admin JWT | `frontend/src/api/admin/usage.ts:136` |  |
| `GET` | `/api/v1/admin/usage/stats` | admin JWT | `frontend/src/api/admin/usage.ts:124` |  |
| `GET` | `/api/v1/admin/user-attributes` | admin JWT | `frontend/src/api/admin/userAttributes.ts:19`<br>`frontend/src/api/admin/userAttributes.ts:27` |  |
| `POST` | `/api/v1/admin/user-attributes` | admin JWT | `frontend/src/api/admin/userAttributes.ts:39` |  |
| `POST` | `/api/v1/admin/user-attributes/batch` | admin JWT | `frontend/src/api/admin/userAttributes.ts:112` |  |
| `PUT` | `/api/v1/admin/user-attributes/reorder` | admin JWT | `frontend/src/api/admin/userAttributes.ts:69` |  |
| `PUT` | `/api/v1/admin/user-attributes/{id}` | admin JWT | `frontend/src/api/admin/userAttributes.ts:50` |  |
| `DELETE` | `/api/v1/admin/user-attributes/{id}` | admin JWT | `frontend/src/api/admin/userAttributes.ts:61` |  |
| `GET` | `/api/v1/admin/users` | admin JWT | `frontend/src/api/admin/users.ts:93` |  |
| `POST` | `/api/v1/admin/users` | admin JWT | `frontend/src/api/admin/users.ts:122` |  |
| `GET` | `/api/v1/admin/users/{id}` | admin JWT | `frontend/src/api/admin/users.ts:106` |  |
| `PUT` | `/api/v1/admin/users/{id}` | admin JWT | `frontend/src/api/admin/users.ts:133` |  |
| `DELETE` | `/api/v1/admin/users/{id}` | admin JWT | `frontend/src/api/admin/users.ts:143` |  |
| `GET` | `/api/v1/admin/users/{id}/api-keys` | admin JWT | `frontend/src/api/admin/users.ts:195` |  |
| `POST` | `/api/v1/admin/users/{id}/balance` | admin JWT | `frontend/src/api/admin/users.ts:161` |  |
| `GET` | `/api/v1/admin/users/{id}/balance-history` | admin JWT | `frontend/src/api/admin/users.ts:263` |  |
| `GET` | `/api/v1/admin/users/{id}/usage` | admin JWT | `frontend/src/api/admin/users.ts:213` |  |
| `GET` | `/api/v1/admin/users/{userId}/attributes` | admin JWT | `frontend/src/api/admin/userAttributes.ts:79` |  |
| `PUT` | `/api/v1/admin/users/{userId}/attributes` | admin JWT | `frontend/src/api/admin/userAttributes.ts:92` |  |
| `POST` | `/api/v1/admin/users/{userId}/auth-identities` | admin JWT | `frontend/src/api/admin/users.ts:293` |  |
| `POST` | `/api/v1/admin/users/{userId}/replace-group` | admin JWT | `frontend/src/api/admin/users.ts:282` |  |
| `GET` | `/api/v1/admin/users/{userId}/subscriptions` | admin JWT | `frontend/src/api/admin/subscriptions.ts:174` |  |

## Notes For Custom Frontend Work

- Prefer calling the same `/api/v1` paths instead of inventing a new BFF layer until the UI is stable.
- Keep OAuth start/callback paths server-owned. The frontend may navigate to them, but the backend manages state, provider exchange, pending sessions, and cookies.
- Keep `/v1/*` fully proxied to the backend even if the SPA only directly calls `/v1/usage`; end users and copied examples depend on the gateway surface.
- If the custom frontend omits a feature area, do not remove its proxy route; leave backend route ownership unchanged for rollback and official UI comparison.

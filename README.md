# Sub2API Standalone Frontend

This project is the official `sub2api/frontend` extracted into an independently deployable static frontend. It serves the Vue SPA and reverse proxies backend-owned paths to an official Sub2API backend, so the official Docker image and one-click update flow remain untouched.

Upstream baseline: `Wei-Shaw/sub2api` frontend, extracted for standalone deployment.

## API Contract

The frontend-to-backend contract used for this extraction is documented in [docs/FRONTEND_BACKEND_API_CONTRACT.md](docs/FRONTEND_BACKEND_API_CONTRACT.md).

## What Changed From Official Frontend

- `vite.config.ts` now builds to local `dist/` instead of `../backend/internal/web/dist`.
- The default API base remains `/api/v1`.
- Docker/Nginx files were added to serve static files and proxy Sub2API backend routes.
- No backend code or official `weishaw/sub2api:latest` image is modified.

## Local Development

```bash
pnpm install
pnpm dev
```

By default Vite proxies API requests to `http://localhost:8080`. Override with:

```bash
VITE_DEV_PROXY_TARGET=http://127.0.0.1:8080 pnpm dev
```

## Static Build

```bash
pnpm install
pnpm build
```

The build output is `dist/`.

## Docker Deployment

Start the official Sub2API backend first, then run this frontend:

```bash
cp .env.example .env
docker compose up -d --build
```

Default behavior:

- Frontend listens on host port `8081`.
- Nginx proxies backend routes to `http://host.docker.internal:8080`.
- Change `SUB2API_BACKEND` in `.env` if your backend is elsewhere.

If this frontend runs in the same Docker network as the official `sub2api` service, use:

```env
SUB2API_BACKEND=http://sub2api:8080
```

## Required Backend Proxy Paths

The Nginx template proxies these backend-owned paths before SPA fallback:

- `/api/v1/`
- `/setup/`
- `/health`
- `/api/event_logging/batch`
- `/v1/`
- `/v1beta/`
- `/responses`
- `/backend-api/codex/`
- `/chat/completions`
- `/images/generations`
- `/images/edits`
- `/antigravity/`

Keep OAuth callbacks and payment webhooks backend-owned. They are under `/api/v1/auth/oauth/` and `/api/v1/payment/webhook/`, so they are covered by `/api/v1/`.

## Updating Safely

Official Sub2API updates can continue to update `weishaw/sub2api:latest` or the official binary. This project is a separate static frontend and is not overwritten by official update commands.

When you want to sync newer official frontend code, copy the official `frontend` source into this project, then re-apply the standalone changes: local `dist` output plus Docker/Nginx deployment files.

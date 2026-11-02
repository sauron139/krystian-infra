# krystian-infra

Everything needed to run the platform locally and in production: Docker Compose files,
Caddy config, deploy and backup scripts, CI/CD workflows for deployment.
System context: `../CLAUDE.md`, `../docs/ARCHITECTURE.md` §2–3.

## Stack
Docker · Docker Compose · Caddy · PostgreSQL 17 · Redis 7 · Mailpit (dev) ·
GitHub Actions · GHCR · Hetzner VPS · Cloudflare (DNS, R2, Turnstile) · Uptime Kuma

## Planned structure
```
compose.dev.yml          # local: db, redis, mailpit + apps with hot reload (mounts ../krystian-*)
compose.prod.yml         # prod: pulls images from GHCR
caddy/Caddyfile          # routes krystian.dev, api., admin.
env/                     # *.env.example per service (real .env files are git-ignored)
scripts/
├── bootstrap-server.sh  # harden a fresh VPS, install Docker, firewall
├── deploy.sh            # pull images, migrate, restart
├── backup-db.sh         # pg_dump → R2
└── restore-db.sh        # tested restore
.github/workflows/deploy.yml
docs/                    # runbooks (deploy, rollback, restore)
```

## Rules
- No secrets in git. Ever. Only `.env.example` files.
- Postgres and Redis stay on the internal Docker network; only Caddy exposes ports 80/443.
- Every service has a healthcheck; apps wait for dependencies to be healthy.
- Pin image versions (no `latest`).
- Any change to the production setup gets a runbook update in `docs/`.

## Commands (planned)
- `docker compose -f compose.dev.yml up` — full local stack
- `./scripts/deploy.sh` — deploy (normally run by CI)
- `./scripts/backup-db.sh` / `./scripts/restore-db.sh`

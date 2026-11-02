# Architecture

## 1. System overview — PROPOSED
```
                     Internet
                        │  HTTPS
                ┌───────▼────────┐
                │     Caddy      │  reverse proxy, auto TLS (Let's Encrypt)
                └──┬──────┬───┬──┘
   krystian.dev    │      │   │  admin.krystian.dev
        ┌──────────▼┐     │  ┌▼──────────────┐
        │ frontend  │     │  │ admin (static │
        │ Astro SSR │     │  │ React SPA)    │
        │ (Node)    │     │  └──────┬────────┘
        └─────┬─────┘     │         │
              │ HTTP      │ api.krystian.dev
              │  ┌────────▼─────────▼┐
              └─►│  backend (FastAPI)│
                 └──┬───────┬────┬───┘
                    │       │    │
             ┌──────▼─┐ ┌───▼──┐ ┌▼───────────────┐
             │Postgres│ │Redis │ │ Object storage │
             └────────┘ └──────┘ │ S3 / R2        │
                                 └────────────────┘
```
Domains are placeholders until TODO(krystian) picks one.

### How a content change reaches the site
1. Krystian edits a project in **admin** → `PATCH /admin/projects/{id}` to **backend**.
2. Backend validates, writes to **Postgres**, and **invalidates** the related Redis cache keys.
3. Next visitor request hits **frontend** (Astro in server mode), which calls the backend's
   public API. The backend serves from Redis (or rebuilds the cache from Postgres).
4. The new content is live within seconds. No rebuild, no redeploy.

*Why Astro in server (SSR) mode rather than fully static?* Static would need a rebuild on
every admin edit. SSR keeps edits instant and is still fast because responses are cached
in Redis, and pages ship almost no JavaScript.

## 2. Repositories
Polyrepo: four independent git repos inside this workspace. Each builds its own Docker image.

### krystian-backend — FastAPI
| Concern | Choice | Why |
|---------|--------|-----|
| Language / runtime | Python 3.13 | Current stable |
| Package manager | **uv** | Fast, lockfile, manages Python versions |
| Framework | **FastAPI** | Async, automatic OpenAPI spec (clients generate types from it) |
| Validation | Pydantic v2 + pydantic-settings | Schemas and typed config from env |
| ORM / migrations | **SQLAlchemy 2.0 (async)** + asyncpg, **Alembic** | Mature, typed, explicit migrations |
| Database | **PostgreSQL 17** | Reliable, JSONB for flexible fields, full-text search later |
| Cache / rate limit / jobs | **Redis 7**; **arq** for background jobs | Cache public reads, throttle contact form, send emails off the request path |
| Auth | Single admin user; argon2 password hashing; short-lived JWT access token + refresh token in httpOnly cookie; TOTP 2FA later | Simple and secure for one user |
| File storage | S3 API (**Cloudflare R2** in prod; local S3 stand-in TBD in Milestone 4) | Same code both places; R2 has no egress fees |
| Email | **Resend** (or any SMTP) | New-lead notifications |
| Spam protection | Honeypot field + rate limit + **Cloudflare Turnstile** | Contact form is public |
| Quality | Ruff (lint + format), mypy, **pytest** + httpx | |
| Observability | Structured JSON logs, Sentry (free tier), `/health` endpoint | |

Layering inside the backend: `api/` (routers) → `services/` (business logic) →
`repositories/` (DB access) → `models/`. Routers stay thin.

### krystian-frontend — Astro (public site)
| Concern | Choice | Why |
|---------|--------|-----|
| Framework | **Astro 5**, `output: 'server'`, `@astrojs/node` adapter | Instant content updates, minimal JS |
| Language | TypeScript (strict) | |
| Styling | **Tailwind CSS v4** + CSS custom properties (tokens from DESIGN.md) | |
| API client | Types generated from backend OpenAPI via **openapi-typescript** + `openapi-fetch` | Contract stays in sync |
| Markdown rendering | unified/remark/rehype + **rehype-katex** + rehype-sanitize | Project/post bodies stored as Markdown in DB |
| Simulations | Canvas 2D + custom TS physics engine; WebGL (raw or **OGL**) for lensing shader | Light, full control |
| Interactive islands | Plain TS; **Svelte** islands if UI state gets complex | Small bundles |
| Images | Served from object storage, resized via backend or Astro image service | |
| Tests | Vitest (physics engine), Playwright (smoke tests) | |

Physics engine lives in `src/physics/` and is **pure math, no DOM**, so it is unit testable.
Rendering and input live in `src/sims/`.

### krystian-admin — React SPA
| Concern | Choice | Why |
|---------|--------|-----|
| Build | **Vite** + React 19 + TypeScript | Admin is an app, not a content site; SPA fits |
| Routing / data | **TanStack Router** + **TanStack Query** | Typed routes, caching, optimistic updates |
| UI | **shadcn/ui** + Tailwind v4 (same tokens) | Accessible primitives you own |
| Forms | React Hook Form + zod | Validation mirrors backend schemas |
| Markdown editor | **Milkdown** or **MDXEditor** with KaTeX live preview | Write project write-ups with equations |
| Media | Drag-and-drop upload to backend (presigned URLs) | |
| API client | openapi-typescript (same as frontend) | |
| Tests | Vitest + Testing Library; Playwright for login/edit flow | |

Served as static files by Caddy. Never indexed (`noindex`, robots disallow).

### krystian-infra — deployment & local environment
| Concern | Choice | Why |
|---------|--------|-----|
| Containers | **Docker**, multi-stage builds (Dockerfiles live in each app repo) | |
| Orchestration | **Docker Compose**: `compose.dev.yml` and `compose.prod.yml` | Right size for one server |
| Reverse proxy | **Caddy** | Automatic HTTPS, simple config |
| Services | Postgres, Redis, Mailpit (dev only), backend, frontend, admin, arq worker; local S3 stand-in added in M4 | |
| Hosting | One VPS (e.g. **Hetzner** CX22, ~€4–5/month) | Cheap, full control |
| DNS / CDN | **Cloudflare** (DNS, proxy, R2, Turnstile) | |
| CI/CD | **GitHub Actions** in each app repo: test → build image → push to **GHCR**; infra repo deploys via SSH (`docker compose pull && up -d`) | |
| Backups | Nightly `pg_dump` → R2, 14-day retention; tested restore script | |
| Monitoring | **Uptime Kuma** (or Better Stack free tier) + Sentry | |
| Secrets | `.env` files on server, never committed; `.env.example` in each repo; SOPS later | |
| IaC (later) | Terraform/OpenTofu for VPS + DNS | Not needed for v1 |

Rough running cost: VPS ~€5/month + domain ~$10–15/year. R2/Resend/Sentry free tiers.

## 3. Local development
From `krystian-infra/`: `make up` starts Postgres, Redis,
Mailpit (catches emails locally), and the three apps with hot reload, mounting the
sibling repos (`../krystian-backend`, etc.). So the four repos must be cloned side by side.

| Service | Local URL |
|---------|-----------|
| frontend | http://localhost:4321 |
| admin | http://localhost:5173 |
| backend API / docs | http://localhost:8000 · /docs |
| Mailpit | http://localhost:8025 |

## 4. Data model (summary) — PROPOSED
Full field lists in `docs/API.md`.

| Entity | Notes |
|--------|-------|
| `Profile` | Singleton: name, headline, bios, photo, CV, socials, availability |
| `Project` | slug, title, summary, body (Markdown), category, tags, links, cover, featured, order, status |
| `Service` | Freelance offering: title, summary, deliverables, pricing note, order, status |
| `Experience` | type (work/education/research), org, role, dates, bullets |
| `Skill` | name, category, years, proficiency (feeds HR diagram) |
| `Post` | Blog article (optional at launch) |
| `Media` | Uploaded file metadata (key, type, size, alt text) |
| `ContactMessage` | Lead from contact form: intent (job/freelance/other), status |
| `SiteSettings` | SEO defaults, OG image, placeholder toggles |
| `AdminUser` | Single row, credentials + 2FA secret |

Every content entity has `status` (`draft` / `published`) and `is_placeholder` (seed data flag).

## 5. Security
- HTTPS everywhere; HSTS; strict CORS (only frontend + admin origins).
- Admin API under `/admin/*`, requires auth; public API is read-only plus `POST /contact`.
- Login rate-limited; argon2 hashing; refresh tokens rotated and revocable.
- Uploaded files validated by type/size; served from storage, never executed.
- Markdown sanitized before rendering.
- Postgres/Redis not exposed to the internet (Docker internal network only).

## 6. Decision log
| # | Decision | Status |
|---|----------|--------|
| 1 | Polyrepo: backend / frontend / admin / infra | CONFIRMED |
| 2 | Backend: FastAPI | CONFIRMED |
| 3 | Frontend: Astro | CONFIRMED |
| 4 | Theme: deep space, dark only in v1 | CONFIRMED |
| 5 | Astro in SSR mode + Redis cache (instant content updates) | PROPOSED |
| 6 | Admin: React + Vite + TanStack + shadcn/ui | PROPOSED |
| 7 | Postgres + Redis + S3-compatible storage | PROPOSED |
| 8 | Single VPS + Docker Compose + Caddy | PROPOSED |
| 9 | GitHub Actions → GHCR → SSH deploy | PROPOSED |
| 10 | Defaults accepted: domain `krystian.dev`, personal GitHub, public repos, Hetzner | CONFIRMED |
| 11 | Node 24 in containers; TypeScript 6 (Astro check not yet on TS 7) | CONFIRMED |

## 7. Open questions
| # | Question | Default if no answer |
|---|----------|----------------------|
| 1 | Domain name | `krystian.dev` placeholder (CONFIRMED as default) |
| 2 | GitHub: personal account or organization? Public repos? | Personal account, public repos (they're portfolio pieces), secrets kept out |
| 3 | Hosting provider | Hetzner |
| 4 | Where do the shared `docs/` get versioned? | RESOLVED: in `krystian-infra`, see note below |
| 5 | Blog at launch? | Built, hidden until first post |
| 6 | Local S3 stand-in (MinIO stopped publishing images in late 2025): SeaweedFS, Garage or RustFS? | Decide in Milestone 4 |

**Shared docs (resolved):** the canonical copies live in `krystian-infra/` (`WORKSPACE.md` and
`docs/`). `krystian-infra/scripts/setup-workspace.sh` (run by `make setup`) links them into the
workspace root as `CLAUDE.md` and `docs/`.

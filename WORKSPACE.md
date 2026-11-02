# Krystian — Deep Space Portfolio Platform

Personal brand and freelancing platform for Krystian, a software engineer who also studies
physics. It shows what Krystian builds (regular software as well as physics-driven software),
what services they offer, and makes it easy for employers and clients to get in touch.
The theme is **deep space**, built on real physics (gravity, orbits, light, spectra).

## Workspace layout
This folder is a **workspace** holding four separate git repositories plus shared docs.

```
krystian/                    ← workspace folder (not a repo)
├── CLAUDE.md                ← symlink → krystian-infra/WORKSPACE.md (you are here)
├── docs/                    ← symlink → krystian-infra/docs (read these first)
├── krystian-backend/        ← FastAPI API, database, business logic
├── krystian-frontend/       ← public website (Astro)
├── krystian-admin/          ← private dashboard to edit site content (React)
└── krystian-infra/          ← Docker, Compose, Caddy, CI/CD, deploy scripts
```

Each repo has its own `CLAUDE.md` with repo-specific rules. Claude Code loads this file
too when working inside any repo, so system-wide rules live here.

## Docs
| File | What it covers |
|------|----------------|
| `docs/PROJECT_BRIEF.md` | Goals, audience, pages, content, scope, milestones |
| `docs/DESIGN.md` | Deep-space theme, colors, type, motion, physics visuals, accessibility |
| `docs/ARCHITECTURE.md` | System design, tech stack per repo, data flow, deployment, decisions |
| `docs/API.md` | Contract between backend and frontend/admin: resources and endpoints |

Keep docs current. When a decision changes, update the doc in the same change.

## Status
- Phase: **2 — Backend core** done on branch `milestone-2-backend-core` (models, migrations, seed, public + admin API, auth, contact). Next: Milestone 3, frontend skeleton.
- `PROPOSED` = suggested, not yet confirmed by Krystian. `CONFIRMED` = agreed.
- `TODO(krystian)` = needs Krystian's input.

## How Krystian wants to work
- Krystian codes, and likes to learn as we go: briefly explain the *why* behind
  non-obvious choices (a sentence or two, not a lecture).
- Ask before adding a dependency, changing the stack, or changing the API contract.

## System-wide rules
- **The backend is the single source of truth for content.** Frontend and admin never
  hard-code bios, projects, etc. Missing content shows a designed placeholder.
- **API contract first:** change `docs/API.md` and the backend schema before the clients.
  Clients use types generated from the backend's OpenAPI spec.
- **Real physics:** simulations use real equations and correct units/notation.
- **Accessibility:** every animation respects `prefers-reduced-motion`; no content lives
  only inside a canvas.
- **Secrets** never get committed. Each repo ships a `.env.example`.
- **Performance:** public site Lighthouse ≥ 95; heavy visuals lazy-load.

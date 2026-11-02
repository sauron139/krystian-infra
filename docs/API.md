# API Contract — PROPOSED

The backend (`krystian-backend`) owns this contract. The live, authoritative spec is the
OpenAPI document at `GET /openapi.json`; this file is the human-readable plan.
Frontend and admin generate TypeScript types from the OpenAPI spec.

Base URL: `https://api.krystian.dev/v1` (local: `http://localhost:8000/v1`)

## Conventions
- JSON everywhere; `snake_case` fields; ISO 8601 dates (UTC).
- Lists: `?page=1&page_size=20` → `{ items: [...], total, page, page_size }`.
- Errors: `{ "error": { "code": "not_found", "message": "...", "details": {...} } }`.
- Public endpoints return only `status = published` items.
- Cache: public GETs cached in Redis; any admin write invalidates related keys.
- Every content item includes `is_placeholder: boolean` so clients can style placeholder content.

## Public endpoints (no auth)
| Method | Path | Returns |
|--------|------|---------|
| GET | `/health` | `{ status: "ok" }` |
| GET | `/profile` | Profile |
| GET | `/projects?category=&tag=&featured=` | Paginated projects (cards) |
| GET | `/projects/{slug}` | Project with Markdown body |
| GET | `/services` | Services (ordered) |
| GET | `/experience` | Experience entries (newest first) |
| GET | `/skills` | Skills (for HR diagram + list) |
| GET | `/posts`, `/posts/{slug}` | Blog posts |
| GET | `/site-settings` | SEO defaults, feature toggles |
| POST | `/contact` | Create a ContactMessage (rate-limited, Turnstile token required) |

## Admin endpoints (auth required)
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/admin/auth/login` | Email + password (+ TOTP later) → access token, sets refresh cookie |
| POST | `/admin/auth/refresh` | Rotate tokens |
| POST | `/admin/auth/logout` | Revoke refresh token |
| GET/PUT | `/admin/profile` | Read / update profile |
| GET/POST | `/admin/projects` | List (all statuses) / create |
| GET/PATCH/DELETE | `/admin/projects/{id}` | Read / update / delete |
| POST | `/admin/projects/reorder` | `{ ids: [...] }` |
| — | same pattern for `services`, `experience`, `skills`, `posts` | |
| POST | `/admin/media/upload-url` | Presigned upload URL |
| GET/PATCH/DELETE | `/admin/media`, `/admin/media/{id}` | Manage media |
| GET | `/admin/messages?status=` | Lead inbox |
| PATCH | `/admin/messages/{id}` | Change status (new / replied / archived) |
| GET/PUT | `/admin/site-settings` | SEO and toggles |
| GET | `/admin/content-checklist` | Which content is still placeholder |

## Resources (fields)
**Profile**: `full_name, headline, short_bio, long_bio (md), photo (Media?), cv (Media?),
location, email, socials { github, linkedin, x, website }, availability (open_to_work |
open_to_freelance | busy), is_placeholder`

**Project**: `id, slug, title, summary, body (md), category (software | physics | freelance |
research), tags[], tech_stack[], cover (Media?), gallery (Media[]), links { repo, demo,
paper }, featured, sort_order, status, published_at, is_placeholder`

**Service**: `id, title, summary, description (md), deliverables[], pricing_note,
sort_order, status, is_placeholder`

**Experience**: `id, type (work | education | research | volunteer), organization, role,
location, start_date, end_date?, bullets[], sort_order, status, is_placeholder`

**Skill**: `id, name, category (language | framework | physics | math | tool | cloud),
years (number), proficiency (1–5), featured, is_placeholder`

**Post**: `id, slug, title, summary, body (md), tags[], cover?, status, published_at`

**Media**: `id, url, key, content_type, size_bytes, width?, height?, alt_text`

**ContactMessage**: `id, name, email, intent (job | freelance | other), company?,
budget_range?, message, status (new | replied | archived), created_at`

**SiteSettings**: `seo_title, seo_description, og_image (Media?), show_blog, show_cv_button`

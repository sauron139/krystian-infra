# Project Brief

## 1. Purpose — CONFIRMED
A **personal brand and freelancing platform**. Krystian is a software engineer who studies
physics. They build regular software and also turn physics knowledge into software.
The site should:
1. Show prospective **employers** what Krystian builds, so they reach out with job offers.
2. Show prospective **clients** which services Krystian offers, so they hire them for freelance work.
3. Build a **personal brand**: a memorable, technically impressive site that is itself a
   portfolio piece (full-stack, self-hosted, physics-driven visuals).

Krystian edits all content through a private admin dashboard; changes appear on the site
without a code change or redeploy.

## 2. Audience
| Who | What they need in under 30 seconds |
|-----|------------------------------------|
| Hiring managers / recruiters | Who Krystian is, stack, best projects, CV, contact |
| Freelance clients | Services, past work, how to start a project, contact |
| Engineers / peers | Interesting projects, code, technical write-ups |

## 3. Public pages — PROPOSED
Each section has a deep-space name; the plain name always appears with it for clarity.

| Route | Section | Space framing | Content |
|-------|---------|---------------|---------|
| `/` | Home | **Origin** | Name, headline, "available for work" status, gravity-field hero, featured projects, services teaser, CTA |
| `/about` | About | **Mission Profile** | Bio, photo, education, what drives you, physics + software story |
| `/projects` | Projects | **Observations** | Filterable project grid (software / physics / freelance) |
| `/projects/[slug]` | Project detail | **Observation Log** | Problem → approach → result, with equations, images, links |
| `/services` | Services | **Mission Services** | Freelance offerings, process, pricing model or "get a quote", FAQ |
| `/skills` (or section on `/about`) | Skills | **Star Catalogue** | Skills plotted like a Hertzsprung–Russell diagram, with a plain list fallback |
| `/experience` | Experience | **Trajectory** | Timeline of work, education, and research |
| `/writing` (optional at launch) | Blog | **Transmissions** | Articles, with LaTeX math support |
| `/contact` | Contact | **Open a Channel** | Contact form (job / freelance / other), email, socials, CV download |
| `/404` | Not found | **Lost Signal** | "This page fell past the event horizon" + way home |

## 4. Admin dashboard (private) — PROPOSED
- Sign in (single admin user: Krystian)
- Edit **Profile**: name, headline, bios, photo, CV, socials, availability status
- Create / edit / reorder / publish **Projects**, **Services**, **Experience**, **Skills**, **Posts**
- Upload and manage **media** (images, CV PDF)
- Read and triage **contact messages** (leads) — new / replied / archived
- Edit **site settings**: SEO title/description, Open Graph image
- Preview drafts before publishing

## 5. Content and placeholders — CONFIRMED
Krystian has no bio, CV, projects, or photo yet. The system must work without them:
- Backend ships **seed data** with clearly marked placeholder content.
- Frontend shows **designed placeholder states**, not broken layouts:
  - Photo → astronaut-helmet silhouette with a faint starfield
  - Bio → "Mission profile loading…" style text, flagged as placeholder
  - CV → button hidden or shown as "CV coming soon"
  - Projects → 3 placeholder "uncharted object" cards
- Admin dashboard shows a **"content checklist"** of what is still placeholder.

Content to gather later (TODO(krystian)):
- [ ] Short bio (2–3 sentences) and long bio (2–3 paragraphs)
- [ ] Photo
- [ ] CV (PDF)
- [ ] 3–6 projects (mix of software and physics-driven)
- [ ] List of freelance services (and pricing approach)
- [ ] Skills, education, experience
- [ ] Social links: GitHub, LinkedIn, X, email
- [ ] Domain name (e.g. `krystian.dev`)

## 6. Scope
**In scope (v1)**
- Four repos: backend, frontend, admin, infra (see `ARCHITECTURE.md`)
- Public site with the pages above, dark deep-space theme, responsive
- Admin dashboard with auth, content editing, media upload, lead inbox
- Contact form with spam protection, email notification to Krystian
- Content changes appear on the public site within seconds
- Self-hosted deployment with Docker on a VPS, HTTPS, automated deploys, database backups
- SEO: meta tags, Open Graph images, sitemap, structured data (Person schema)

**Out of scope (v1)**
- Light theme (deep space is dark by design; revisit later)
- Multiple admin users / roles
- Payments, invoicing, client portal
- Comments, newsletter
- Multilingual content
- Kubernetes (Docker Compose is enough at this scale)

## 7. Milestones — PROPOSED
| # | Milestone | Done when |
|---|-----------|-----------|
| 0 | Planning | Docs confirmed |
| 1 | Foundations | 4 repos initialised; `docker compose up` runs Postgres, Redis, Mailpit, empty backend/frontend/admin |
| 2 | Backend core | Models, migrations, seed data, public read API, admin auth, CRUD, tests |
| 3 | Frontend skeleton | Design tokens, layout, all pages rendering seed/placeholder data |
| 4 | Admin MVP | Login, edit profile/projects/services, media upload, lead inbox |
| 5 | Physics visuals | Gravity hero, starfield, orbits, HR-diagram skills, lensing effects |
| 6 | Production | VPS, domain, HTTPS, CI/CD, backups, monitoring |
| 7 | Polish & launch | Accessibility, performance, SEO, real content entered |

## 8. Success criteria
- Visitor finds who Krystian is, the best project, services, and contact in < 30 s.
- Editing content in admin updates the live site within ~10 s, no redeploy.
- Public site Lighthouse ≥ 95 on all categories.
- Works on phones, by keyboard only, and with reduced motion.
- Deploy is one command / one merge to `main`.

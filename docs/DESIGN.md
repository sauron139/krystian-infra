# Design

## 1. Concept — CONFIRMED direction: Deep Space
**"Mission control for a universe of projects."**

The site is the night sky seen through an observatory: deep black, real starlight colors,
and objects that move according to real physics. Krystian's work appears as celestial
objects you observe; contacting them is "opening a channel".

Principles:
1. **Content first.** Space frames the content and never hides it. Text sits on calm,
   high-contrast surfaces, not on top of busy animation.
2. **Real physics.** Motion comes from actual equations: Newtonian gravity, Kepler orbits,
   blackbody color, Doppler shift. A physicist should nod, not wince.
3. **Calm until touched.** The sky drifts slowly; it responds when the visitor moves,
   hovers, or scrolls.
4. **Professional.** This is a hiring and sales page. Playful details are rewards, not obstacles.

## 2. Color — PROPOSED
Dark only (v1). Star colors follow real blackbody temperatures (spectral classes O → M).

| Token | Value | Use |
|-------|-------|-----|
| `--void` | `#05070D` | Page background |
| `--space` | `#0A0F1C` | Section background alternation |
| `--surface` | `#111829` | Cards, panels (slightly translucent + blur over sky) |
| `--surface-border` | `#1F2A44` | Card borders, dividers |
| `--text` | `#E8ECF5` | Body text (starlight white) |
| `--text-muted` | `#94A0B8` | Captions, meta |
| `--accent` | `#7DD3FC` (blueshift) | Links, primary buttons, focus ring |
| `--accent-2` | `#A78BFA` (nebula violet) | Highlights, gradients |
| `--warm` | `#FDBA74` (K-class star) | Secondary emphasis, "available" badge |
| `--danger` | `#F87171` (redshift) | Errors |
| `--success` | `#6EE7B7` | Success states |

Spectral palette (for skills/categories, stars in sims):
`O #9BB0FF · B #AABFFF · A #CAD7FF · F #F8F7FF · G #FFF4EA · K #FFD2A1 · M #FFCC6F`

Gradients: subtle nebula washes (violet → blue) at low opacity behind section headers only.
All text pairs meet WCAG AA (4.5:1 body, 3:1 large).

## 3. Typography — PROPOSED
| Role | Font | Notes |
|------|------|-------|
| Headings | **Space Grotesk** | Technical, slightly futuristic |
| Body | **Inter** | Readable at all sizes |
| Data / labels / code | **JetBrains Mono** | Coordinates, units, telemetry-style labels |
| Math | **KaTeX** | Real LaTeX rendering in write-ups |

Scale ratio 1.25, base 17px, body line height 1.65. Fonts self-hosted.

Telemetry details: small mono labels like `RA 14h 29m · §02 OBSERVATIONS` or
`T+3.2 yr` on timeline entries. Use sparingly.

## 4. Layout
- Content max width ~72ch (text), ~1200px (grids). 8px spacing scale.
- Mobile first. Breakpoints 640 / 768 / 1024 / 1280.
- A fixed, low-cost starfield sits behind everything; content sits on surfaces above it.
- Nav: no menu bar. Home is the planetary system (planets are the menu); inside a scene, the brand star
  (top-left) goes home and a small orrery (bottom-right) reaches the other planets. See §5.

## 5. Physics system — CONFIRMED direction (preview v3)
The site is a planetary system. Navigation is orbital mechanics, and each page (scene) runs one real phenomenon.
Live preview: https://claude.ai/artifact/MZWMs7ci2MBM2wUpg73zfe

### Navigation: orbital system (CONFIRMED)
- **Home = the star system.** Full-screen view of a star with six planets on circular Kepler orbits
  (μ = 4π² AU³/yr², n = 2π/a^1.5, 1 simulated year = 16 s). The visitor ("You") sits in a parking orbit at 0.55 AU.
  Short intro copy + two CTAs on the left. No text menu bar.
- **Each page is a planet:** Projects 1.0 AU (banded gas giant), Services 1.45 (cyan storm world),
  Skills 1.9 (ringed), About 2.35 (ocean world), Experience 2.8 (rust, cratered), Contact 3.25 (ice).
  Planets are lit from the star (terminator follows the light direction).
- **Clicking a planet** solves Lambert's problem (universal variables, Curtis Alg. 5.2) from the ship's
  current body to where the target *will be*. Several flight times (0.5–2.1 × Hohmann) are tried; routes
  passing within 0.3 AU of the star are rejected; the lowest-Δv one wins (a tiny porkchop plot).
  The path is integrated with leapfrog and drawn as the ship flies.
- **Timing ("watch it, quick"):** flight ≈ 0.95 s with time warp, then ≈ 0.5 s zoom anchored on the planet
  until its horizon fills the bottom of the screen and the scene fades in. Scene → scene: zoom out 0.38 s,
  fly, zoom in. Any click or key skips. Reduced motion: instant cut.
- **Only readout:** one fading caption during flight, e.g. "Lambert transfer to Skills · Δv 10.0 km/s · 1.30 yr".
- **In a scene:** brand star (top-left) returns home; a small orrery (bottom-right) is the menu for other
  planets. Esc returns home.
- **Separate scenes, real URLs.** One scene at a time, each with its own URL (preview uses `#projects` etc.;
  Astro will use real routes `/projects` …). Back/forward work. Focus moves to the scene heading.
  Planet and orrery hit targets are real `<button>`/`<a>` elements over the canvas, so keyboard and
  screen readers work and nothing lives only in a canvas.

### Scenes
| Scene | Phenomenon | Real physics used |
|-------|------------|-------------------|
| Projects | Kepler orbit on each card (runs on hover/focus); placeholder card jitters | Kepler's equation (Newton solve); Brownian motion (Ornstein–Uhlenbeck in a harmonic trap) |
| Services | Each service is a bulb on one battery; switches toggle them; watts per card | Ohm's law, parallel resistors, internal resistance, P = I²R |
| Skills | HR-style chart, spectral class per category | Blackbody colour by temperature; Wien's law λ_max = b/T |
| About | White light through a steerable prism | Snell's law (vector form), Cauchy dispersion (dense flint), total internal reflection |
| Experience | Rocket passes career stages as the scene scrolls; Δv toward orbit | Tsiolkovsky Δv = I_sp g₀ ln(m₀/m_f); ~9.4 km/s LEO budget |
| Contact | Two-source interference (cursor moves one source); sending times an echo | Superposition; reflection via image source; d = vt/2 |
| 404 (planned) | A planet that isn't there: event horizon | Schwarzschild radius visual |

Removed after v2 feedback (felt like a "regular dev page"): text menu bar, launch console,
stacked long-scroll sections, extra readouts (β/γ HUD, formula strips), gravity-particle hero, bubble chamber.

Rules:
- Every route is a normal link: direct loads, modifier-click and no-JS all work; the flight is an enhancement.
- Only the active scene's simulation ticks; the system view pauses while a scene is open except the orrery.
- Example numbers (stage Isp, circuit values) are labelled as such; the equations are real.
- Physics code lives in `src/physics/` and is unit tested (Lambert round-trip vs propagation, energy
  conservation, Snell/TIR cases).

Ideas held in reserve: Doppler tint on fast flights, gravity assists for long routes, resonance on button hover.

## 6. Motion
- Durations: 150ms micro, 300ms UI, 600ms+ scenes.
- Prefer spring/damped motion over fixed easing curves.
- Transfers: ≈1–1.5 s total, skippable by any click or key.
- `prefers-reduced-motion: reduce` → static starfield, planets frozen, no flights (instant cut to the scene), fades only.
- Simulations pause when off-screen or the tab is hidden.

## 7. Placeholder states (content not yet provided)
| Missing | Shows |
|---------|-------|
| Photo | Astronaut-helmet silhouette with reflected starfield |
| Bio | Styled placeholder text with an "awaiting transmission" tag |
| Projects | "Uncharted object" cards with a dim, unresolved star |
| CV | Button shown disabled as "CV coming soon" (or hidden; admin setting) |

Placeholders must look intentional, never broken.

## 8. Components (frontend)
Nav/HUD bar, Footer, SectionHeader (with telemetry label), Button, Badge (availability),
ProjectCard, ServiceCard, SkillStar + HRDiagram, TimelineEvent, Equation, Figure,
ContactForm, CVButton, Placeholder variants, SimulationCanvas wrapper.

## 9. Admin design
The admin dashboard reuses the color tokens and fonts but is a plain, efficient tool:
no simulations, dense tables, clear forms. Built with shadcn/ui components themed with
the tokens above.

## 10. Accessibility
- Semantic landmarks, one `h1` per page, skip link.
- Canvases are decorative (`aria-hidden`) or have text equivalents (HR diagram ↔ skill list).
- Visible focus ring (`--accent`). Full keyboard support.
- KaTeX output includes MathML.
- Contrast checked against the actual translucent surfaces, not just the tokens.

## 11. Inspiration
TODO(krystian): add links to sites, images, or space imagery you like.
Reference ideas: NASA Eyes on the Solar System, JWST image palettes, observatory HUDs.

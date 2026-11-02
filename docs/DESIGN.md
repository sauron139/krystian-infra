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
- Nav: compact top bar; on scroll it becomes a translucent "HUD" bar.

## 5. Physics system — CONFIRMED direction (preview v2)
Every section runs one real phenomenon, and navigation itself is physics.
Live preview: https://claude.ai/artifact/MZWMs7ci2MBM2wUpg73zfe

| Where | Phenomenon | Real physics used |
|-------|------------|-------------------|
| **Navigation** | **Projectile launch.** Each section is a beacon at a different range on a "launch console". Clicking a link auto-aims and fires a probe; landing within 30 m of a beacon arrives at that section. Users can also aim by dragging (slingshot). | Range equation R = v₀² sin 2θ / g; optional quadratic drag a = −k\|v\|v integrated with RK4, auto-aim by bisection on v₀; apex kept on screen via tan θ ≤ 4H/R; time warp shown |
| Origin (hero) | Gravity well; the cursor is a second mass | Newtonian gravity, Plummer softening, kick-drift-kick leapfrog (symplectic) |
| Observations | Kepler orbits on project cards; bubble-chamber tracks in the background | Kepler's equation (Newton solve); Lorentz force in uniform B with energy loss → spirals; pair production vertices |
| Placeholder cards | "Unresolved object" jitters | Brownian motion (Ornstein–Uhlenbeck in a harmonic trap) |
| Services | Each service is a bulb on one battery; switches toggle them | Ohm's law, parallel resistors, internal resistance (remaining bulbs brighten when others switch off), P = I²R |
| Star catalogue | Skills on an HR-style chart, spectral classes by category | Blackbody colour by temperature; Wien's law λ_max = b/T |
| Mission profile | White light through a steerable prism | Snell's law (vector form) at each face, Cauchy dispersion (dense flint), total internal reflection handled |
| Trajectory | Rocket passes career stages as you scroll; Δv accumulates toward orbit | Tsiolkovsky Δv = I_sp g₀ ln(m₀/m_f); ~9.4 km/s LEO budget |
| Contact | Two-source interference (cursor moves one source); sending pings the wall and times the echo | Superposition I ∝ (cos(kr₁−ωt)+cos(kr₂−ωt))²; reflection via image source; d = vt/2 |
| HUD readout | Scroll speed shown as β and γ; headings contract vertically | Special relativity: γ = 1/√(1−β²), length contraction L/γ (c scaled to 3000 px/s) |
| 404 (planned) | Page falls past an event horizon; a ball occasionally tunnels through a barrier | Schwarzschild radius visual; tunnelling probability T ≈ e^(−2κL) |

Rules:
- Every link still works as a normal link: modifier-click, keyboard, and `prefers-reduced-motion` skip the launch and jump directly.
- At most one heavy simulation runs at a time; each module ticks only while on screen.
- Example numbers (stage Isp, circuit values) are labelled as such; the equations are real.
- Physics code lives in `src/physics/` and is unit tested (energy conservation, range accuracy, Snell/TIR cases).

Ideas held in reserve: resonance (driven oscillator) on button hover, magnetic field lines around the cursor, thermodynamics/entropy for a "loading" state, Doppler shift on fast navigation.

## 6. Motion
- Durations: 150ms micro, 300ms UI, 600ms+ scenes.
- Prefer spring/damped motion over fixed easing curves.
- `prefers-reduced-motion: reduce` → static starfield, no hero sim (show a still frame), fades only.
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

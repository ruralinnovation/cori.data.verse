# CORI Data Verse — Content Plan
## Conference Prep: October 2026

---

## Overview

This document tracks the content work needed to prepare the CORI Data Verse site for
presentation at the October 2026 economic conference. A separate branch handles frontend
lean-out (UI/UX). This plan covers **content population** — packages, datasets, and projects.

The goal is a lean, substantive site that showcases CORI's rural data infrastructure:
what data exists, how to access it via R packages, and what research it enables.

---

## Purpose & Context

### What is the CORI Data Verse?

The CORI Data Verse is a **public-facing catalog and knowledge hub** that coalesces rural
data assets — datasets, R packages, research projects, and tools — into a single
discoverable resource. It serves anyone interested in understanding or working with rural
America data: researchers, policymakers, funders, community advocates, and data practitioners.

While the ecosystem is currently over-indexed toward R tooling, the site is intentionally
broader: it surfaces **tools, research, packages, and key data sources** in support of
rural communities making data-informed decisions.

### Who is CORI?

The Center on Rural Innovation (CORI) is building infrastructure for inclusive innovation
in rural America through three reinforcing pillars: Research & Data Infrastructure,
Rural Innovation Ecosystem Building, and Rural Startup Investment. CORI works directly
with 44 communities across 26 states and brings place-based expertise, original research,
and emerging AI capabilities to transform fragmented rural data into actionable intelligence.

This on-the-ground credibility — combined with a track record of $276M secured for local
economic development and 400+ startups launched — is what distinguishes CORI's data work
from static federal sources (USDA ERS, Census, etc.). CORI doesn't just aggregate data;
it contextualizes it for rural decision-making.

### Where does the Data Verse fit in the larger picture?

The Data Verse is **foundational infrastructure for the Rural Insights Hub** (coming 2027)
— CORI's next-generation AI-powered intelligence platform. Specifically:

- The **vignettes, project documentation, and dataset pages** feed directly into the
  Rural Insights Hub's knowledge base (`cori.agent.kb`), where they are chunked,
  processed, and ingested into a Bedrock vector store
- The **R packages** (`cori.data.*`) are among the ETL sources that populate a **data
  lake**, which the agent draws from — they don't feed the agent directly at runtime
- Documentation quality directly affects the agent's response quality — poorly written
  or thin content produces weaker AI-grounded answers

The Rural Insights Hub agent is designed to serve **rural leaders, community advocates,
and decision-makers**. Crucially, it goes beyond simple data lookup — the agent is
designed to synthesize data into economic development intelligence. Not just
"here is your broadband coverage rate" but rather "here is how your broadband gap
may be constraining your community's economic potential and long-term wellbeing, and
here is what the research says about addressing it."

These are not technical data users — they are practitioners who need intelligence, not
infrastructure. The Data Verse must therefore be legible to both the technical audience
(who will use the R packages) and the non-technical audience (who will encounter this
content through the AI agent or direct browsing).

### What gap does this fill?

Federal rural data sources (USDA ERS, Census Bureau, BLS) exist but are fragmented,
difficult to use, and not contextualized for rural decision-making. CORI's value is
translating that raw data into trusted, actionable intelligence — cleaning it, linking
it across sources, applying rural-specific methodologies (e.g., rural classifications),
and embedding it in research context. The Data Verse is where that translation work
becomes publicly visible and credible.

---

## Guiding Principles

- **Substance over volume.** Fewer pages done well beats many thin pages. A lean,
  high-quality 20-page site signals capability. A bloated 100-page site with thin
  content signals immaturity.
- **Every page must earn its place.** Before writing or keeping any page, ask: is this
  credible, substantive, and something we'd be comfortable presenting to a funder or
  conference attendee? If not, cut it.
- **Packages are the hero.** The `cori.data` ecosystem is the key differentiator — it
  represents real, sustained investment in rural data infrastructure that federal sources
  can't replicate.
- **Datasets support packages.** Dataset pages should show how CORI packages make the
  data accessible and contextualized, not just describe the raw federal source.
- **Projects prove the value.** 2–3 strong project examples demonstrate what's possible
  with this infrastructure.
- **Cut ruthlessly.** Stale, thin, or AI-generated content must be removed, not polished.
  A missing page is better than a bad one.
- **Write for two audiences simultaneously.** Content must be legible to a rural
  community leader (why does this matter, what decisions does it inform?) and credible
  to a researcher or data practitioner (what is the methodology, how do I use this?).
- **Draw on team expertise, not just CORI outputs.** The team includes trained economists,
  researchers, an anthropologist, a sociologist, and a data viz designer. Content can and
  should reflect that depth — contextualizing data, explaining methodology, and framing
  rural conditions with genuine disciplinary expertise. This is a differentiator, not a
  liability.
- **Quality gates before publishing.** No page goes live without a human read-through.
  If it reads like it was generated and not reviewed, it doesn't ship.

## Content Quality Standards

A page is **ready** when it meets all of these:
- [ ] Written by or substantively shaped by a team member with domain expertise (not raw AI output)
- [ ] Grounded in accurate data and credible methodology
- [ ] Has a clear answer to "why does this matter for rural communities?"
- [ ] Has complete, correct frontmatter (all required fields populated)
- [ ] Code examples run without error (for package pages)
- [ ] Cross-links to related packages, datasets, or projects are accurate
- [ ] Has been read top-to-bottom by at least one person before publishing

A page is **not ready** when:
- It was generated and not substantively edited
- It has placeholder text, broken examples, or stub sections
- Its cross-links point to content that doesn't exist
- It describes work CORI hasn't actually done

---

## Content Inventory & Status

### Packages (Priority: HIGH)

`cori.data` is a **meta-package** — installing it pulls in all companion packages and
loading it attaches them all. Companion packages share a consistent 4-parameter interface
(`geography`, `geoids`, `years`, `variables`) and return tidy long-format data.

The developer has built technical foundations for all packages. **Our job is to add the
interpretive layer** — the "What This Data Tells Us About Rural America" section and
ported vignettes — to every page.

| Slug | Dev Branch State | Our Action |
|------|-----------------|------------|
| `cori-data` | Exists — solid technical foundation | Add interpretive section, port `getting-started` + `tidy-data` vignettes inline |
| `cori-data-bds` | Exists — good technical docs | Add interpretive section, port vignettes |
| `cori-data-qcew` | Exists — new, good foundation | Add interpretive section, port `employment-rate`, `sector-analysis`, `weighted-averages` vignettes |
| `cori-data-fcc` | Exists — solid | Add interpretive section, port `broadband` vignette |
| `cori-data-pep` | Exists — good | Add interpretive section |
| `cori-data-bfs` | Exists | Add interpretive section |
| `cori-data-bps` | Exists — new | Add interpretive section |
| `cori-data-hu` | Exists | Add interpretive section — may cut for v1 |
| `cori-data-s3` | Exists — infrastructure only | No interpretive section needed — keep technical |
| `ruraldefinitions` | Exists — strongest page | Add interpretive section on why rural definitions matter |
| `dform` | Exists | Cut for v1 — not in core ecosystem |

**Target for conference:** All core ecosystem packages with interpretive sections +
vignettes ported inline for `cori-data`, `cori-data-qcew`, `cori-data-fcc`

**Vignettes available to port (from cori.data GitHub):**
- `getting-started.Rmd` — ecosystem overview, consistent interface, tidy format
- `tidy-data.Rmd` — filtering, pivoting, joining across packages, rural classifications
- `employment-rate.Rmd` — QCEW + PEP cross-package analysis, maps, line charts
- `sector-analysis.Rmd` — rural vs. nonrural sector composition, CORI super-sector classification
- `weighted-averages.Rmd` — why simple means mislead, how to use agg_var correctly
- `broadband.Rmd` — FCC NBM data access, broadband + employment analysis

**Recommended vignette distribution:**
- `cori.data` umbrella page — hosts `getting-started` and `tidy-data`; tells the
  ecosystem story (what the meta-package is, how to install, consistent interface,
  tidy format, cross-package analysis pattern)
- Individual package pages — host domain-specific vignettes:
  - `cori-data-qcew` ← `employment-rate`, `sector-analysis`, `weighted-averages`
  - `cori-data-fcc` ← `broadband`
  - Others get their own examples once pages are created

---

### Datasets (Priority: MEDIUM — DEFERRED)

The developer gutted all dataset content and replaced with a single "coming soon"
placeholder. Dataset cut list and page structure **have not yet been decided** —
this requires its own interview process (see Step 1).

Dataset work does not begin until packages are complete.

> **Do not write dataset pages until the interview process is done and a cut list is agreed.**

---

### Projects (Priority: MEDIUM)

All 3 existing projects are marked `draft: true`. They have strong methodology/ETL
documentation but **no actual findings or outputs**. Our work is to add the interpretive
layer and surface real results where they exist.

| Slug | Dev Branch State | Our Action |
|------|-----------------|------------|
| `rural-economic-outlook` | Strong ETL docs, outputs "in development" | Add findings + interpretive section, confirm outputs exist |
| `rwjf-seeds-of-change-public-funding` | Strong methodology, no findings | Add findings + interpretive section — confirm public-facing ready |
| `capital-one-business-demographics` | Good methodology, no index values shown | Evaluate — keep if findings can be shared publicly |

**Target for conference:** 2 strong projects with findings visible, `draft: true` removed

---

### Charts (Priority: LOW for v1)

- 70+ charts exist, mostly from rural-economic-outlook
- No new chart authoring planned for v1
- Review which charts surface on the site and ensure they link correctly to projects
- Cut charts from removed projects

---

## Page Templates (v1)

> **Status: DRAFT — needs review and sign-off before writing begins**
> Templates are intentionally lean for v1. See V2 Backlog section for deferred sections.

### Dataset Pages (v1)

```
---
[frontmatter — see schema below]
---

## Overview
What is this dataset? Who produces it? Why does it matter for rural communities?
Plain language. 1–2 paragraphs.

## What This Data Tells Us About Rural America
[NON-NEGOTIABLE — this is the KB differentiator]
What patterns emerge in rural vs. nonrural contexts? What economic, social,
or structural dynamics does this data illuminate? 2–4 paragraphs of genuine
expert analysis — not a description of column names.

## Coverage
- **Geography:** County / State / etc.
- **Time Range:** YYYY–YYYY (update frequency)

## Key Variables
Short grouped list of the most important fields. Not exhaustive.

## Accessing the Data
### Via CORI R Package (if available)
### Direct from Source

## Related
- Relevant packages
- Projects that use this data
```

---

### Package Pages (v1)

```
---
[frontmatter — see schema below]
---

## Overview
What does this package do? What problem does it solve?
What does CORI's version add over the raw federal source?

## Installation & Quick Start
Install command + minimal working example (data in < 5 lines).

## What This Data Tells Us About Rural America
[NON-NEGOTIABLE — same as datasets]
Expert framing of what this data reveals in a rural context.

## Vignettes
[Ported from cori.data GitHub — bulk of the page]
Organized by analytical use case.

## Related
- Datasets it wraps
- Other packages
- Projects that use it
```

---

### Project Pages (v1)

```
---
[frontmatter — see schema below]
---

## Overview
What question does this project address and why does it matter for rural communities?

## What This Project Reveals About Rural America
[NON-NEGOTIABLE]
Expert framing — economic, social, or policy context a community leader
would find meaningful. Lead with the insight, support with the data.

## Data & Methods
What datasets and packages were used. Key methodological decisions.

## Key Findings
What did the analysis reveal?

## Outputs
Charts, reports, tools produced. Links where available.

## Related
Datasets, packages, other projects.
```

---

## Frontmatter Schemas (Reference)

### Package
```yaml
title: "cori.data.bds"
description: "..."
author: "Mapping & Data Analytics Team"
date: "YYYY-MM-DD"
categories: ["R Package", "Economy", ...]
tags: [census, business, ...]

package:
  name: "cori.data.bds"
  githubUrl: "https://github.com/ruralinnovation/cori.data.bds"
  installCommand: 'devtools::install_github("ruralinnovation/cori.data.bds")'
  status: "stable"        # stable | development
  version: "X.Y.Z"
  maintainer: "Name"
  featured: true          # true for umbrella + top packages

usesDatasets: ["census-bds"]
usesResources: []

execute:
  echo: true
  warning: false
  message: false

editor:
  markdown:
    wrap: 72
```

### Dataset
```yaml
title: "Census Business Dynamics Statistics"
description: "..."
author: "Mapping & Data Analytics Team"
date: "YYYY-MM-DD"
categories: ["Dataset", "Economy", ...]
tags: [census, business, ...]

dataset:
  name: "Census Business Dynamics Statistics"
  source: "U.S. Census Bureau"
  sourceUrl: "https://..."
  accessMethod: "API"     # API | Direct Download | Bulk Download | Census API and Bulk Download
  updateFrequency: "Annual"
  geographicLevel: "County"
  dataFormat: ["CSV", "API"]
  featured: true          # true for primary datasets

execute:
  echo: true
  warning: false
  message: false

editor:
  markdown:
    wrap: 72
```

### Project
```yaml
title: "Rural Economic Outlook"
description: "..."
date: "YYYY-MM-DD"
categories: ["Economic Analysis", ...]
tags: [economy, rural, ...]

projectUrl: "https://github.com/..."
status: "active"          # active | inactive
team: ["Mapping & Data Analytics"]

usesDatasets: ["census-bds", "fcc-broadband", ...]
usesPackages: ["cori-data-bds", "cori-data-fcc", ...]
usesResources: []

execute:
  echo: false
  warning: false
  message: false

format:
  gfm:
    toc: false
    wrap: none
```

---

## Work Sequence

### Step 0 — Branch Setup ✅ DONE
- [x] Developer merged frontend lean-out into `development`
- [ ] Pull latest `development` locally and verify clean build
- [ ] Create content branch off `development` (e.g. `content/v1-packages`)
- [ ] All content work happens on that branch — no direct commits to `development` or `main`
- [ ] PR content branch back into `development` when ready

---

### Step 1 — Align on Templates ✅ IN PROGRESS
- [x] Interview process — package page template (complete)
- [x] Page templates finalized for v1 (see Page Templates section)
- [x] Package cut list decided
- [ ] Interview process — dataset page template + cut list (pending — do after packages)
- [ ] Interview process — project page template + cut list (pending)
- [ ] Decide which projects make the v1 cut (pending — need to confirm findings are shareable)

### Step 2 — Packages

**Approach: pilot → skill update → apply to remaining packages**

Do `cori-data` first as the pilot. Get it right, review it, then update the
`generate-dataverse-package` skill to encode the pattern before touching other packages.
This ensures every subsequent package page is consistent without rework.

**For each package page:**

Trim from developer pages (v2 backlog):
- Exported functions table
- Key features section
- Use cases (standalone section)
- Performance tips
- Known limitations

Add to every page:
- "What This Data Tells Us About Rural America" section (non-negotiable)
- Vignettes inline where applicable (with GitHub link alongside)

**Pilot:**
- [ ] `cori-data` — trim to v1 template, add interpretive section, port `getting-started`
      + `tidy-data` vignettes inline, link to GitHub for full source
- [ ] Review and sign off on `cori-data` page
- [ ] Update `generate-dataverse-package` skill to encode v1 template + rural context +
      vignette porting pattern

**Remaining packages (apply updated skill):**
- [ ] `cori-data-qcew` — port `employment-rate`, `sector-analysis`, `weighted-averages`
- [ ] `cori-data-fcc` — port `broadband`
- [ ] `cori-data-bds`
- [ ] `cori-data-pep`
- [ ] `cori-data-bfs`
- [ ] `cori-data-bps`
- [ ] `ruraldefinitions`
- [ ] `cori-data-hu` — evaluate: keep or cut for v1
- [ ] `dform` — remove for v1

### Step 3 — Datasets
Write from scratch to v1 template. Each page: Overview, What This Data Tells Us, Coverage, Key Variables, Accessing the Data, Related.

- [ ] `qcew-employment-wages`
- [ ] `fcc-broadband`
- [ ] `census-bds` — draft exists, revise to template
- [ ] `census-population-estimates`
- [ ] `usda-county-typology`
- [ ] `american-community-survey`
- [ ] `census-bfs` (if time permits)
- [ ] `census-building-permits` (if time permits)

### Step 4 — Projects
- [ ] Confirm which project findings are public-facing ready
- [ ] `rural-economic-outlook` — add findings + interpretive section, remove `draft: true`
- [ ] `rwjf-seeds-of-change-public-funding` — add findings + interpretive section, remove `draft: true`
- [ ] `capital-one-business-demographics` — evaluate and keep or cut

### Step 5 — Review & QA
- [ ] Run full build locally, check for broken links / dangling references
- [ ] Read every page — cut anything that isn't ready
- [ ] Confirm search index reflects final content set
- [ ] Coordinate with developer for merge back to `development`

---

## User Journeys

These ground the content strategy — every page should serve at least one of these personas.

---

### Journey 1: The Researcher

**Persona:** Rural economist at a regional university studying labor market dynamics.
Comfortable in R. Publishes applied research. Expert in her domain (say, broadband) but
not necessarily in adjacent datasets (workforce, business dynamics).

**Before `cori.data`:**
She's working on a paper examining whether broadband expansion correlates with business
formation in rural counties. The data wrangling alone takes weeks — not just cleaning,
but discovery and comprehension. She has to:
- Find the right BLS QCEW files, understand their structure, and download them manually
  one year at a time, deciphering FIPS code quirks
- Locate Census BDS in a different portal in a completely different format — and spend
  time understanding what the variables actually mean for her analysis
- Pull FCC data in a third format with its own geographic identifiers
- Write substantial cleaning code just to get three tables into a joinable state
- Realize halfway through that her rural classification methodology is inconsistent
  across sources and has to restart part of the analysis

The real cost isn't just the code — it's the time spent understanding datasets she's not
an expert in, and the uncertainty about whether she's using them correctly.

**After `cori.data`:**
```r
library(cori.data)

employment   <- get_employment(geography = "county", years = 2018:2023)
business_apps <- get_business_applications(geography = "county", years = 2018:2023)
broadband    <- get_nbm_county(geography = "county")
rural        <- get_definition("rucc")

# Everything joins on geoid + year. Rural flag ready to go.
```
Analysis starts immediately. The variables are documented and interpretable. The
methodological decisions about rural classification are made and defensible. The Data
Verse vignettes give her enough context on QCEW and BDS to use them correctly without
becoming an expert in each. She cites the package in her paper.

---

### Journey 2: The Rural Data User

**Persona:** Economic development director for a rural regional planning commission.
Not a programmer. Advocates for 12 counties. Needs data to write grant applications and
make the case to state legislators.

**Before the Rural Insights Hub:**
He knows his region is struggling but can't quantify it in a way that resonates with
funders. He finds Census tables but can't tell if his counties are underperforming
comparable rural places or just underperforming urban places. He hires a consultant to
pull together a data snapshot. It costs $8,000 and is out of date six months later.

**After the Rural Insights Hub:**
He opens the Hub and asks: *"How is employment recovering in my counties compared to
similar rural Appalachian communities since COVID?"*

The agent — grounded in CORI's QCEW data, BDS data, and rural classification methodology
— responds with a narrative contextualizing his counties against peer communities, flags
that his region's tradable goods sector is contracting faster than comparable places, and
surfaces CORI research on what that pattern typically signals for long-term wage growth.
He uses it to write a stronger EDA grant application.

The agent also tells him: *"For a full data experience — including the underlying
datasets, methodology, and R tools used in this analysis — visit the CORI Rural
Dataverse."* The Data Verse is what makes him trust the Hub. He can see the sources,
the methodology, and the research behind the answers.

---

### Journey 3: The Rural Data Learner

**Persona:** Junior analyst or graduate student new to rural data. Comfortable enough in
R to follow examples but doesn't know what datasets exist, what they measure, or how
they relate to each other. Has deeper knowledge gaps than just tooling — she may not
know that counties are the standard unit of rural analysis, that "rural" has multiple
competing definitions, or that the same place can be classified differently depending on
which definition you apply. Trying to build fluency in rural economic analysis from the
ground up.

**Before the Data Verse:**
She knows she needs data for a project but doesn't know where to start — or even what
geography to start at. She searches "rural employment data" and gets buried in Census
documentation written for statisticians. She finds a dataset but isn't sure if it's the
right one, what the variables mean in a rural context, or how geographic definitions
affect her results. She spends more time reading documentation than doing analysis, and
isn't confident her methodological choices are defensible.

**After the Data Verse:**
The site orients her to the landscape before she ever touches data — what geography
matters and why, how rural classifications work and differ, what datasets exist and what
questions each answers. The vignettes are worked examples she can follow and adapt. The
"What This Data Tells Us About Rural America" sections give her the conceptual framing
to interpret results, not just produce them. She leaves with fluency, not just access.

---

## Process Notes

- **Dataset & project page templates must go through an interview process before writing
  begins.** Claude will ask structured questions to understand what each page type needs
  to communicate, then draft the template from the answers. Do not skip to writing content
  before this is done.

---

## Key Messaging & Framing

### The "Why CORI" Argument (use on cori.data umbrella page and throughout)

> Not all federal data sources are designed with rural communities in mind. CORI's data
> team has done the methodological work — identifying the right sources, applying
> consistent rural classifications, and packaging the data in a format that works across
> rural geographies — so you can focus on the research question, not the data
> infrastructure.

**What CORI adds over raw federal sources:**
- Brings together the right resources in one place — curation is the value
- Builds rural methodological expertise directly into the packages (classifications,
  aggregation, variable selection)
- Organizes and stores data consistently so cross-source analysis is tractable
- Provides vignettes that train users on the packages while demonstrating analytical
  patterns relevant to rural research
- Demonstrates graphical output via `cori.charts` — showing not just how to get the
  data but how to communicate it

**Tone notes:**
- Don't position this as "federal data is bad" — some sources are well-suited for rural
  work. The issue is inconsistency, gaps, and the methodological lift required to use
  them correctly together.
- The implicit point — that rural analysis requires specific expertise — should be made
  explicit on the page.

---

## Content Gaps Identified (To Scope)

These emerged during planning and need a decision on whether they're v1 or v2:

- **US TIGER/Line as a dataset** — county and place geometries are foundational to rural
  analysis; `cori.data` already bundles them. Needs a dataset page.
- **Geography orientation layer** — the rural data learner persona surfaces a need for
  content explaining *why counties*, what rural classifications exist, and how geographic
  definitions affect analysis. Could be a standalone page, a blog post, or a callout on
  the `ruraldefinitions` package page. Decision needed.

---

## Skill Update (End of Content Work)

The `generate-dataverse-package` skill at
`~/Documents/Github/cori.agent.skills/inst/commands/generate-dataverse-package.md`
is the automated generation tool for package pages. It is currently out of date
relative to our content decisions and will need to be updated after content work
is complete.

**What holds up:**
- Slug mapping table (package → dataset slug)
- Category/tag conventions
- Status inference (stable ≥ 1.0.0, development < 1.0.0)
- Claude-scans / R-validates division of labor
- Frontmatter schema

**What needs updating:**
1. Align `body_args` to v1 template — remove `exported_functions`, `key_features`,
   `use_cases`, `performance_tips`, `known_limitations` from generated output
   (these are v2 content, not v1)
2. Add `rural_context` as a required field in `body_args` — this is the
   "What This Data Tells Us About Rural America" section, currently absent entirely
3. Add vignette porting guidance — skill currently treats vignettes as external
   links only; our standard is inline content with a GitHub link alongside
4. Update slug mapping table — the following packages are missing from the skill's
   reference table and need to be added:

   | Package Name | Package Slug | Primary Dataset Slug |
   |---|---|---|
   | `cori.data.qcew` | `cori-data-qcew` | `qcew-employment-wages` |
   | `cori.data.bps` | `cori-data-bps` | `census-building-permits` |
   | `cori.data` | `cori-data` | (none — meta-package) |

   Note: `qcew-employment-wages` refers to BLS QCEW's employment AND wages data —
   both dimensions are covered by the package, not wages alone.

> **This skill update is the final deliverable of the content work phase.**
> Once all package pages are complete and the interpretive/vignette pattern is
> established, update the skill so future package pages can be generated
> consistently.

---

## V2 Backlog
Sections deferred from v1 templates — revisit after conference:

- **Datasets:** Rural Methodology Notes, Strengths & Limitations
- **Packages:** Core Functions table, Rural Research Applications
- **Projects:** Implications for Rural Communities (standalone section), Technical Details / Reproducibility
- **All types:** Deeper cross-linking once content volume warrants it

---

## Open Questions

1. **cori.data umbrella package:** Is this a real installable package or a meta-page
   that describes the ecosystem? Need to confirm before writing the page.

2. **Dataset cut list:** Which of the 15 datasets are actually used in featured
   packages/projects? We should only keep those for v1.

3. **Vignette porting workflow:** What's the cleanest way to pull vignettes from GitHub
   and adapt them? Are they in `.Rmd` format? Can we automate the pull?

4. **Projects:** Are capital-one and rwjf projects public-facing ready? Do they have
   outputs/charts we can show?

5. **Charts:** Do we show charts on the site for v1, or is that deferred?

---

## Notes

- QMD files are treated like RMarkdown — YAML frontmatter + markdown body + R code chunks
- Quarto directives: `::: callout-note`, `::: panel-tabset`, `::: columns` — use these
  for visual structure, they render correctly in the site
- All slugs use lowercase-with-hyphens format
- `featured: true` in frontmatter controls what surfaces on the homepage
- Coordinate with frontend branch owner before merging — they control site structure

---

*Last updated: 2026-08-26*

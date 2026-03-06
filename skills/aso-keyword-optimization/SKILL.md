---
name: aso-keyword-optimization
description: >
  iOS App Store Optimization (ASO) keyword strategy, metadata auditing, and optimization.
  Use when: (1) auditing App Store Connect metadata (app name, subtitle, keyword field) for
  optimization issues, (2) planning keyword changes for an iOS app, (3) researching keyword
  opportunities, (4) working with cross-localization strategy, (5) reviewing ASO best practices,
  (6) using the `asc` CLI to read/write App Store metadata, (7) using Astro MCP tools for
  keyword tracking and ranking data. Covers Apple's keyword algorithm mechanics, expert-backed
  rules, common mistakes, and the 2025-2026 algorithm changes (screenshot indexing, CPPs, AI tags).
---

# ASO Keyword Optimization

## Changelog & Strategy Integration

**At the start of ANY ASO work** (audit, research, planning, checkpoint, or changes):

1. **Read `ASO/CHANGELOG.md`** to review prior experiments, their hypotheses, and outcomes
2. **Read `ASO/STRATEGY.md`** for current metadata state, keyword tiers, and standing priorities
3. **Check if any checkpoint reviews are overdue** — if a checkpoint date has passed and its status is still "pending", flag it before proceeding with the current task

This applies to every workflow below. The changelog/strategy read is always the first action, before pulling metadata or running any checks.

**After making changes:**

1. Append a new entry to `ASO/CHANGELOG.md` using the template at the bottom of that file
2. Pull baseline rankings from Astro and record them in the entry (ranked keywords only; note unranked count)
3. Update `ASO/STRATEGY.md` if the metadata snapshot changed (new keyword values, char counts)
4. Include git changeset hash, build number, and version string in the entry header

**At checkpoint reviews (+1w, +2w, +3w, +4w):**

1. Pull current rankings via Astro (`mcp__astro__get_app_keywords`)
2. Compare to the entry's baseline rankings
3. Add a `### +Nw Checkpoint (YYYY-MM-DD)` section under the entry with a rankings table and delta column vs baseline
4. Update the checkpoint row's status from "pending" to "done"
5. Summarize: "N keywords improved avg X positions, M keywords declined avg Y positions"

## Metadata Audit Workflow

When auditing an app's ASO metadata:

0. **Read changelog and strategy** (see Changelog & Strategy Integration above)
1. **Pull current metadata** via `asc` CLI (see Tool Integration below)
2. **Run automated checks** per [references/audit-checklist.md](references/audit-checklist.md)
3. **Cross-reference with tracking data** via Astro MCP tools if available
4. **Report violations** with severity and recoverable character counts
5. **Propose changes** following the rules in [references/expert-consensus.md](references/expert-consensus.md)

## Keyword Planning Workflow

When planning keyword changes:

0. **Read changelog and strategy** (see Changelog & Strategy Integration above)
1. **Audit current state** (see above)
2. **Identify gaps** — high-value keywords not covered in any metadata field
3. **Prioritize by**: relevance first, difficulty second, popularity as tiebreaker (Sensor Tower's 3-step process)
4. **Allocate keywords across fields** using the weight hierarchy: Title (strongest, ~2x) > Subtitle (strong) ≥ Keyword Field (moderate)
5. **Consider CPP targeting** — keywords in the keyword field can be bound to Custom Product Pages for organic search. Group keywords by user intent and create matching CPPs
6. **Plan cross-localization** per [references/cross-localization.md](references/cross-localization.md) — use secondary locales to expand keyword space
7. **Align screenshot captions** — reinforce top keywords in screenshot caption text (repetition IS beneficial here, unlike other fields). Also introduce overflow keywords that don't fit in traditional metadata
8. **Validate** — no within-locale repetition, no cross-locale waste, all fields near capacity
9. **Wait 4 weeks** after deploying changes before judging performance
10. **Use Apple Search Ads data** to validate keyword choices — TTR and CR from Search Ads "probing campaigns" reveal which keywords convert before committing organically (Phiture method)

## Core Rules (Quick Reference)

These are universally agreed upon by 10+ expert sources. See [references/expert-consensus.md](references/expert-consensus.md) for full detail, evidence levels, and nuances.

1. **Never repeat keywords across Title, Subtitle, and Keyword Field** within a locale. Zero ranking benefit.
2. **Title carries ~2x weight** vs keyword field. Put most important keywords there.
3. **Apple auto-combines words** across Title + Subtitle + Keyword Field within a single locale.
4. **Format keyword field**: commas, no spaces. `budget,tracker,expense` not `budget, tracker, expense`.
5. **Use single words**, not phrases, in the keyword field to maximize combinations.
6. **"free", "app", and category name** are auto-indexed. Never include them.
7. **Cross-locale keywords do NOT combine** into phrases. Each locale combines only within itself.
8. **Fill all 100 characters** of the keyword field with relevant terms. Every empty character is missed indexing.
9. **Target long-tail combinations** — 75% of store visits come from multi-word searches.
10. **Do not use competitor trademarks** — risk of de-indexing or app removal.

## Key Don'ts

- Do not keyword-stuff the Title — hurts conversion rate, which is a ranking factor
- Do not update keywords more frequently than every ~4 weeks
- Do not use brand slogans in the keyword field — nobody searches for them
- Do not chase a single competitive keyword stubbornly — find alternatives, return after growth
- Do not ignore screenshot captions — they are indexed and can provide +217% visibility when keyword-optimized
- Do not repeat keywords across locales that index for the same territory (likely wasted, use space for unique words)
- Do not launch a new app with unoptimized metadata — the 5-7 day launch boost window is wasted permanently if missed

## Competitor Landscape Analysis (Experimental)

Use Astro MCP tools to identify who competes for the same keywords and flag potential trademark conflicts.

### Process

1. **Search the App Store for each core keyword** — use `mcp__astro__search_app_store` with your app ID to see who ranks and where you stand:
   ```
   mcp__astro__search_app_store(keyword="checkbook", store="us", appId="YOUR_APP_ID")
   ```
2. **Identify recurring competitors** — apps appearing in the top 10 across multiple core keywords are your primary competitors
3. **Flag trademark risks** — any app name that appears as a trademarked brand in search results is a keyword to avoid (Core Rule 10). Look for: distinctive brand names, apps with "®" or "™" in their title, well-known finance apps
4. **Mine competitor keyword ideas** — for tracked keywords, use `extract_competitors_keywords` to discover what terms competitors are targeting that you may be missing:
   ```
   mcp__astro__extract_competitors_keywords(keyword="checkbook", store="us")
   ```
5. **Assess competitive difficulty** — cross-reference with `search_rankings` to check difficulty scores. Keywords where top results are dominated by large publishers (banks, fintech unicorns) may not be worth targeting directly

### What to Look For

- **Trademark conflicts**: Competitor brand names appearing in your keyword field or theirs appearing in results for your generic terms
- **Keyword cannibalization**: Multiple competitors (including your own other apps) fighting for the same low-volume keyword
- **Opportunity gaps**: Keywords where top results are low-quality or irrelevant apps — these are easier to win
- **Dominance patterns**: If one competitor holds positions 1-3 for a keyword cluster, consider targeting adjacent long-tail terms instead

### Limitations

- `search_app_store` returns a point-in-time snapshot; rankings shift daily
- `extract_competitors_keywords` requires the keyword to be tracked first (use `add_keywords` if needed)
- Astro cannot identify which of a competitor's keywords come from their keyword field vs title/subtitle — only what they rank for
- No automated way to detect trademarks; use judgment and search the USPTO database for uncertain cases

## Tool Integration

### asc CLI — Reading Metadata

```bash
# List apps
asc apps list --output table

# Get app info IDs (needed for app-level fields)
asc app-infos list --app "APP_ID"

# Get app-level localizations (name, subtitle)
asc localizations list --app "APP_ID" --type app-info --app-info "APP_INFO_ID" --output table

# Get version localizations (keywords, description, whatsNew)
asc versions list --app "APP_ID" --output table
asc localizations list --version "VERSION_ID" --output table
```

### asc CLI — Writing Metadata

```bash
# Update keywords for a locale (version-level localization)
asc localizations update --version "VERSION_ID" --locale "en-US" --keywords "word1,word2,word3"

# Update subtitle (app-info-level localization)
# (via app-info localizations — see asc-metadata-sync skill)
```

### Astro MCP — Keyword Research

```
mcp__astro__list_apps                    # List tracked apps
mcp__astro__get_app_keywords             # Get all tracked keywords for an app
mcp__astro__search_rankings              # Search rankings with history/statistics
mcp__astro__get_keyword_suggestions      # AI-powered keyword suggestions
mcp__astro__extract_competitors_keywords # Mine competitor keyword ideas
mcp__astro__search_app_store             # Live App Store search results
mcp__astro__add_keywords                 # Add keywords to tracking
mcp__astro__get_app_ratings              # Get ratings data
```

## Reference Files

- **[references/expert-consensus.md](references/expert-consensus.md)** — All compiled expert rules with evidence levels, sources, and nuanced areas of disagreement
- **[references/cross-localization.md](references/cross-localization.md)** — Which locales index where, strategy for expanding keyword space, pitfalls
- **[references/audit-checklist.md](references/audit-checklist.md)** — Specific checks to run when auditing metadata, with severity levels

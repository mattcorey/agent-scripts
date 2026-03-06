# ASO Metadata Audit Checklist

Run these checks against each locale's metadata. Report violations with severity and estimated impact.

## Pull Metadata

Use the `asc` CLI to retrieve current metadata:

```bash
# Get app info ID
asc app-infos list --app "APP_ID" --output table

# Get app-level localizations (name, subtitle)
asc localizations list --app "APP_ID" --type app-info --app-info "APP_INFO_ID" --output table

# Get current version ID
asc versions list --app "APP_ID" --output table

# Get version localizations (keywords, whatsNew)
asc localizations list --version "VERSION_ID" --output table
```

## Within-Locale Checks (Per Locale)

### Check 1: Keyword Repetition Across Fields [CRITICAL]

Extract words from Title, Subtitle, and Keyword Field. Flag any word appearing in more than one field.

**How to check:**
1. Lowercase all fields, split into individual words
2. Remove stop words (and, to, by, with, the, a, for, of, in, on)
3. Find intersection between: Name words ∩ Keyword words, Subtitle words ∩ Keyword words, Name words ∩ Subtitle words

**Impact:** Each repeated word wastes its character count + 1 comma in the keyword field. Sum all repeated word lengths + commas for total wasted characters.

### Check 2: Keyword Field Character Usage [CRITICAL]

Count characters in keyword field. Flag if under 90/100.

| Usage | Severity |
|---|---|
| 95-100 | Good |
| 90-94 | Acceptable |
| 70-89 | Warning — significant wasted space |
| <70 | Critical — major missed opportunity |

### Check 3: Spaces After Commas [MEDIUM]

Search for ", " (comma-space) in keyword field. Each space wastes 1 character.

### Check 4: Phrases in Keyword Field [MEDIUM]

Split keyword field by commas. Flag any entry containing a space (indicates a multi-word phrase instead of single words).

**Exception:** Some ASO tools use bracket notation `[phrase]` for exact-match tracking. Note but don't flag as error.

### Check 5: Auto-Indexed Terms [LOW]

Flag if keyword field contains: "free", "app", the app's category name, or the developer name. These are indexed automatically.

### Check 6: Title and Subtitle Length [INFO]

Report character usage for Title (max 30) and Subtitle (max 30). Note unused characters as potential optimization space.

## Cross-Locale Checks (Grouped by Territory)

### Check 7: Cross-Locale Repetition [HIGH]

For each territory, identify all locales that index for it (see cross-localization.md). Extract all words from all fields of each locale. Flag words appearing in multiple locales.

**US territory locales:** en-US, es-MX, ru (minimum). Potentially also: ar, zh-Hans, zh-Hant, de, fr, it, ja, ko, pt, es, sv, tr, nl, vi.

**Impact:** Each cross-locale duplicate is likely wasted space that could hold a unique keyword.

### Check 8: Secondary Locale Utilization [HIGH]

For key territories (US, GB, CA), check if secondary locales have keyword fields filled.

| Locale | US Indexed | Typical Usage |
|---|---|---|
| es-MX | Yes (confirmed) | Often neglected |
| ru | Yes (confirmed) | Often neglected |
| ar | Yes (reported) | Rarely used |
| zh-Hans | Yes (reported) | Rarely used |

Flag secondary locales with <50 characters used in keyword field.

## Content Quality Checks

### Check 9: Keyword Relevance [MEDIUM]

Review each keyword for relevance to the app's actual functionality. Irrelevant keywords generate impressions without taps, hurting conversion rate (a ranking factor).

### Check 10: High-Value Keyword Gaps [HIGH]

Cross-reference tracked keywords (from Astro or equivalent) against metadata. Flag high-popularity keywords (pop >30) that don't appear in any metadata field of any indexed locale.

### Check 11: Screenshot Caption Keywords [HIGH]

Apple indexes screenshot caption text for search ranking. Check whether top target keywords appear in screenshot captions.

**How to check:**
1. Review screenshot captions for presence of core keywords from Title, Subtitle, and Keyword Field
2. Unlike other fields, **repeating keywords from Title/Subtitle in captions IS beneficial** — it reinforces them
3. Check for new keywords in captions that expand beyond the 160-character traditional metadata limit

**Quality checks:**
- Clean, simple fonts with high contrast (decorative text may not be read by Apple's AI)
- Captions placed at the **top of screenshots** for maximum indexing reliability
- Caption keywords aligned with overall keyword strategy

**Impact:** Apps with keyword-rich captions saw +217% visibility (Appfigures) and +22% search visibility within 30 days (AppTweak).

## Audit Report Format

```
## Audit Summary: [App Name]
Date: [date]
Locales Analyzed: [list]

### Critical Issues
- [issue]: [details] — ~[N] chars recoverable

### High Priority
- [issue]: [details]

### Medium/Low
- [issue]: [details]

### Recommendations
1. [specific change with rationale]
2. [specific change with rationale]
```

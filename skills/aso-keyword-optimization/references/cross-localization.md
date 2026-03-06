# Cross-Localization Strategy

Cross-localization is the practice of using secondary locale metadata fields to expand your keyword coverage in a target territory. Apple indexes multiple locales per territory.

## How It Works

Each locale gives you 160 indexable characters:
- App Name: 30 chars
- Subtitle: 30 chars
- Keyword Field: 100 chars

By filling secondary locale metadata (especially the keyword field) with additional keywords, you multiply your effective keyword space.

## Which Locales Index Where

### United States (Primary: English US)

Secondary locales confirmed indexed for the US market:
- **Spanish (Mexico)** — confirmed by all sources
- **Russian** — confirmed by Appfigures, AppFollow
- **Arabic** — confirmed by AppFollow
- **Chinese Simplified** — confirmed by AppFollow
- **Chinese Traditional** — confirmed by AppFollow

Additional locales reported as indexed (per AppFollow "Super Geos"):
- Dutch, French, German, Italian, Japanese, Korean, Portuguese, Spanish, Swedish, Turkish

**Case study:** Amma Pregnancy Tracker added just Arabic + Chinese Simplified with English keywords → **+49% US search visibility** in the first month (AppFollow).

**Case study:** Drift Legends added English keywords to Mexican locale → **+56% US search impressions** (AppFollow).

### United Kingdom (Primary: English UK)

- English (UK) primary
- Secondary locales TBD — research for specific territories as needed

### Canada (Primary: English CA)

- English (CA) primary
- French (Canada) secondary — if not enabled, French (France) falls back

### Switzerland

Indexes approximately 5 locales: German, French, Italian, English (AU), English (UK) — giving ~500 characters of keyword space (Sensor Tower).

## Critical Rules

### 1. Keywords Do NOT Combine Across Locales

"Budget" in English (US) + "tracker" in Spanish (MX) will NOT rank you for "budget tracker." Each locale's keywords combine only within itself.

**Implication:** If you want to rank for a specific phrase, all component words must exist within a single locale's metadata (Title + Subtitle + Keyword Field of that locale).

### 2. You Can Use English Keywords in Any Locale's Keyword Field

The keyword field is invisible to users. Apple does not validate language correctness. You can put English keywords in the Spanish (MX) or Russian keyword field to gain additional US indexing.

**Exception:** The Title and Subtitle ARE visible to users in those locales. Only put English in the keyword field, not the user-facing fields (unless you're okay with those markets seeing English text).

### 3. Avoid Repeating Words Across Locales (Same Territory)

If "register" is already in your English (US) metadata, putting it again in Spanish (MX) metadata is likely wasted (Apple indexes a word once per territory). Use the space for unique words instead.

**Caveat:** This is soft consensus, not hard proof. If you're running out of relevant unique keywords, repeating important terms may provide marginal reinforcement.

### 4. Be Aware of Collateral Impact

Using a locale for cross-localization affects the native market for that language. If you put English keywords in the Italian keyword field, Italian App Store users may see reduced Italian keyword coverage.

**Only use this tactic for locales where the native language market is not a priority for your app.**

## Implementation Strategy

### Step 1: Maximize Primary Locale First

Fill English (US) Title + Subtitle + Keyword Field to capacity with no repetition across fields before touching secondary locales.

### Step 2: Identify Keyword Overflow

List high-value keywords that don't fit in your primary locale's 160 characters.

### Step 3: Group for Secondary Locales

Since words combine within a locale, group overflow keywords that form useful phrases together into the same secondary locale.

Example for a budget app:
- Spanish (MX) keyword field: `savings,income,recurring,family,home,simple,weekly,paycheck`
- Russian keyword field: `cash,flow,money,snowball,avalanche,monthly,reminder`

These words combine within their locale (e.g., "weekly budget" if "budget" is also in es-MX title) but NOT across locales.

### Step 4: Verify No Cross-Territory Repetition

Cross-reference all locales that index for the same territory. Remove duplicates — use the space for unique keywords.

### Step 5: Track Secondary Locale Keywords

Use Astro or equivalent tools to track keywords placed in secondary locales. Monitor them with the same rigor as primary locale keywords.

## Character Budget Template

For the US market (en-US + es-MX + ru minimum):

| Field | en-US | es-MX | ru | Total |
|---|---|---|---|---|
| Name | 30 | 30 | 30 | 90 |
| Subtitle | 30 | 30 | 30 | 90 |
| Keywords | 100 | 100 | 100 | 300 |
| **Total** | **160** | **160** | **160** | **480** |

With additional locales (Arabic, Chinese, etc.), this can reach 1,000+ characters.

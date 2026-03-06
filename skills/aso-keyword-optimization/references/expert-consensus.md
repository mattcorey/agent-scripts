# Expert Consensus: ASO Keyword Optimization Rules

Compiled from 12 expert sources and 50+ articles (2025-2026). Each rule notes its evidence level and any areas of disagreement.

## Confirmed Rules (All Sources Agree)

### 1. Never Repeat Keywords Across Fields (Within a Locale)

Apple indexes each word once per locale. Repeating "tracker" in both subtitle and keyword field wastes keyword field characters for zero ranking benefit.

**Evidence:** Confirmed by Apple documentation, Appfigures, AppTweak, Sensor Tower, Phiture, App Radar, SplitMetrics, MobileAction, App Masters.

### 2. Keyword Weight Hierarchy

Title carries the strongest ranking signal (~2x vs keyword field per Sensor Tower data). Subtitle and keyword field are roughly equal, though some sources consider subtitle slightly stronger.

**Weight order:** App Name > Subtitle ≥ Keyword Field

**Minor disagreement:**
- AppTweak, SplitMetrics: Subtitle = Keyword Field (equal weight)
- App Radar, Appfigures, Sensor Tower: Subtitle slightly stronger

**Practical impact:** Either way, put your most important keywords in the Title. Use Subtitle for the next tier.

### 3. Apple Auto-Combines Words Across Fields

Within a single locale, Apple's algorithm creates phrase combinations from individual words across Title + Subtitle + Keyword Field. "Budget" in title + "tracker" in keyword field = ranking for "budget tracker."

**Implication:** Use single words in the keyword field, not phrases. This maximizes the number of combinations the algorithm can form.

### 4. Keyword Field Formatting

- Separate with commas, **no spaces**: `budget,tracker,expense`
- Spaces after commas waste characters (Sensor Tower showed one app freed 31 characters by removing spaces)
- 100 character limit
- Use only individual words, not phrases

### 5. Auto-Indexed Terms (Don't Include)

Apple automatically indexes:
- The word "free"
- The word "app"
- Your app's category name
- Your developer name

Including these in your keyword field wastes characters.

### 6. Wait ~4 Weeks After Changes

The algorithm needs time to properly index and measure new keywords. Evaluate performance after a full cycle, not days.

### 7. No Competitor Trademarks

Apple can de-index you for that keyword, reject your update, or remove your app. Not worth the risk.

### 8. Target Long-Tail Keywords

- 75% of store listing visits come from multi-word searches (TheTool)
- Long-tail users show 3x higher retention and 2.5x better LTV vs paid users (MobileAction)
- Recommended mix: 70-80% long-tail, 20-30% short-tail (MobileAction)
- Less competitive, more targeted, higher conversion

### 9. Conversion Rate Is a Ranking Factor

Tap-through rate (TTR) and conversion rate (CR) directly influence organic rankings. A 3-5% conversion improvement can materially increase organic installs (SplitMetrics). This means:
- Don't keyword-stuff the title — it hurts readability and TTR
- Screenshot quality matters for rankings, not just aesthetics
- Ratings volume matters (4.0+ stars is table stakes for featuring; 90% of featured apps are 4.0+)

### 10. Continuous Iteration Required

ASO is not "set and forget." Top-performing apps treat keyword optimization as an ongoing monthly cycle: Research → Implement → Monitor → Evaluate → Iterate (Phiture KWO Cycle).

### 11. Screenshot Captions Are Indexed

Apple uses AI to extract text from screenshot captions and indexes it for search ranking. Apps with keyword-rich captions saw **+217% visibility** (Appfigures) and **+22% search visibility within 30 days** (AppTweak).

**Key difference from other metadata:** Screenshot keywords **do not follow the "no duplication" rule.** Repeating important keywords from Title/Subtitle in captions IS beneficial — it reinforces them. You can also introduce new keywords via screenshots that don't fit in the 160 characters of traditional metadata.

**Best practices:**
- Use clean, simple fonts with high contrast — decorative text may not be read
- Place captions at the top of screenshots for maximum indexing reliability
- Align caption keywords with your Title/Subtitle/Keyword Field strategy

**Evidence:** Appfigures, ARPU Brothers, App Guardians, AppTweak

### 12. Algorithm Memory Retains Removed Keywords

Even after removing keywords from metadata or changing your app name, the algorithm retains a "memory" of previously used keywords. Old keywords continue to influence rankings at reduced strength.

**Implications:**
- Removing a keyword doesn't immediately de-index you for it
- Previous app names continue to carry some weight
- This can be beneficial (legacy authority) or harmful (legacy irrelevant keywords diluting focus)

**Evidence:** Appfigures (Keyword Teardown #91 — "Chat AI" formerly "ChatGPT - GPT 3" still ranks for old terms)

### 13. New Apps Get a Launch Boost

New apps receive a **5-7 day boost** in keyword rankings after launch. Apple temporarily ranks new apps higher to test user response. Rankings typically peak in top 10 for targeted keywords during the boost window, then drop after day 7.

**Implications:**
- Have metadata fully optimized BEFORE launch — this window is wasted permanently if not
- Target slightly more competitive keywords during the launch window
- This is not a long-term strategy but generates critical initial downloads

**Evidence:** Sensor Tower

### 14. Custom Product Pages Appear in Organic Search

Custom Product Pages (CPPs) can appear in organic search results, not just paid ads. Bind keywords from your Keyword Field to specific CPPs — when a user searches that keyword and your app ranks, the matching CPP replaces your default product page. Apps using CPPs saw **+5.9% average CVR boost** (AppTweak); generic campaigns reached **+8.6%**.

**Constraint:** CPP keyword binding only works with keywords from the private keyword field, NOT from Title or Subtitle. This gives keyword field entries a dual purpose: indexing AND CPP targeting.

**Evidence:** AppTweak, ARPU Brothers, Phiture

### 15. AI-Generated Feature Tags

Apple uses LLMs to auto-generate feature tags from your metadata. Users can search by these tags. Developers can remove tags but cannot add new ones (currently English-only, US App Store).

**Implications:**
- Accurate, descriptive metadata is rewarded more than ever
- Keyword-stuffing may generate misleading tags, which could hurt if users filter by tags
- Having a clear, focused app description helps Apple generate relevant tags

**Evidence:** TechCrunch, ARPU Brothers

## Areas of Nuance / Disagreement

### Singular vs. Plural

**Consensus position:** Apple handles regular plurals (adding "s") automatically. Use only the singular form.

**AppTweak's counter-data:** A study of 600 keywords across 3 countries found only ~50% overlap in top-10 results for singular vs plural forms. Some keywords (e.g., "casino" vs "casinos") had as few as 2/10 apps overlapping.

**Practical guidance:** For your most important keywords, research both forms separately. For less critical keywords, use singular only to save characters.

### Fill All 100 Characters vs. Focused Keywords

**Majority position:** Fill all 100 characters. Empty characters = missed indexing opportunities. The keyword field is invisible to users, so there's no conversion penalty.

**Appfigures counter-position:** "The algorithm has evolved: it now puts more weight on focus." Stuffing keywords may dilute signal.

**Resolution:** These likely apply to different contexts:
- **Title/Subtitle (user-facing):** Focus matters. Stuffing hurts conversion, which hurts rankings.
- **Keyword field (invisible):** No published evidence that fewer keywords = more weight. Fill it, but ensure every word is genuinely relevant to your app. Irrelevant keywords that generate impressions but no taps can hurt conversion rate.

### Cross-Locale Keyword Repetition

**Consensus position:** Don't repeat the same word across locales that index for the same territory. Apple indexes a word once; repeats waste space.

**Weaker evidence:** Some practitioners report slight reinforcement from multi-locale presence. No controlled study exists.

**Practical guidance:** If you have plenty of unique keywords to add, don't repeat — use the space for new words (higher expected value). If genuinely running out of relevant keywords, repeating important terms across locales is probably fine.

### Title Length

**Majority position:** Use all 30 characters for maximum keyword coverage.

**Contrarian finding (MobileApps Daily):** Shorter titles (15-20 chars) can outperform by improving tap-through rate on mobile screens.

**Practical guidance:** Use the full 30 characters, but ensure readability. A natural-sounding title with keywords beats a keyword-stuffed one.

### Keyword Count Targets

**TheTool:** Top-performing apps rank for 65-110 keywords on iOS.

**Appfigures:** Optimize for 5-10 keywords at any given time.

**Resolution:** These aren't contradictory. Track 65-110+ keywords for monitoring, but focus optimization effort on 5-10 keywords per cycle.

## Sources

- Appfigures (Ariel Michaeli): Algorithm mechanics, keyword teardowns, screenshot indexing
- AppTweak: Keyword field formatting, singular/plural study, ranking factors
- Sensor Tower: Keyword selection, localization, launch boost, title weight (~2x)
- Phiture / ASO Stack: Advanced keyword optimization, KWO cycle, Search Ads integration
- AppFollow: Cross-localization case studies (Amma: +49% visibility, Drift Legends: +56% impressions)
- App Radar / TheTool: Keyword field rules, common mistakes, keyword count benchmarks
- SplitMetrics: Ranking factor weights, metadata allocation, conversion impact
- RevenueCat (David Barnard): ASO as growth lever, holistic approach
- App Masters (Steve P. Young): Live audits, keyword placement case studies (+10 positions from field→subtitle move)
- MobileAction: Long-tail strategy, common mistakes, keyword cannibalization
- Gummicube (Dave Bell): Continuous optimization, AI search changes
- ARPU Brothers: WWDC25 changes, screenshot indexing analysis

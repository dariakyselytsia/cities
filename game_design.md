# Cities (Міста) — Game Design

> Source of truth for product scope and game rules. Technical decisions live in
> `tech_design.md`. Anything under **Future** is out of MVP scope — don't build
> it, but don't design it out either.

## 1. Product in one paragraph

"Cities" is an offline, educational word game for iOS and Android. You duel
**CityBot**: you and the bot take turns naming cities, and each city must start
with the *last valid letter* of the one before. You have a countdown each turn.
**You win if CityBot runs out of cities it knows**; you lose if your time runs
out or you give up. Difficulty sets how many cities CityBot knows. The game
remembers every city you have ever named, so playing is also slow, satisfying
geography discovery.

Languages: Ukrainian and English. Fully offline. No ads, no accounts in MVP.

## 2. Game rules

### 2.1 Setup (pre-game picker)
Tapping **Play** opens a short setup sheet. It remembers the last choice:
- **City list:** *Ukraine* (Ukrainian cities only) or *World* (cities worldwide).
- **Difficulty:** *Easy* / *Medium* / *Hard*.
- **Start** button.

### 2.2 Turns
- CityBot opens the game by naming a city.
- Turns alternate: player → bot → player → …
- The city list is the same for both sides. The **player** may name any city in
  the active list. **CityBot** only names cities from its *vocabulary* (§2.5).

### 2.3 The Letter Rule
- The next city must start with the **last letter** of the previous city.
- If no city in the active list starts with that letter (e.g. Ukrainian `ь`,
  `и`, `й`), skip back to the previous letter, and keep going until you reach a
  playable letter. This is **dataset-driven**, with no hard-coded letter list.
- The game always shows the required letter on the player's turn
  ("Your turn — start with «Х»").

### 2.4 Answer checking
An answer is accepted if all of these are true:
1. **It exists** in the active list. Matching is forgiving:
   - it ignores case, extra spaces, hyphens vs spaces, and apostrophe variants
     (`'`, `’`, `ʼ`);
   - it folds Latin diacritics (São Paulo = Sao Paulo) and treats Ukrainian `ґ`
     like `г`;
   - it accepts **known alternate names in the same language**, including
     historic ones (Kiev → Kyiv, Кіровоград → Кропивницький, Bombay →
     Mumbai). Russian names are not accepted.
   - There is **no typo guessing** in MVP.
2. **It starts with the required letter** (§2.3).
3. **It hasn't been used** in this game by either side. There is one shared
   used-set.

A rejected answer shows its reason inline ("not in the list", "must start with
«Х»", "already used"). The player may retry until the timer runs out. The timer
does **not** reset on a wrong answer.

City names are displayed and matched in the **app language** only. In
Ukrainian, a Latin-script answer like "Kyiv" is not accepted.

### 2.5 CityBot and difficulty
Cities are ranked into **tiers** by fame. Fame is based on population rank
within the active list, and capitals always count as tier 1. CityBot's
vocabulary is the tiers its difficulty allows:

| Difficulty | Bot knows | Player turn timer |
|---|---|---|
| Easy   | tier 1 only (≈ the best-known cities)  | 45 s |
| Medium | tiers 1–2                              | 30 s |
| Hard   | tiers 1–3                              | 20 s |

Tier sizes are per list and are **tuning values**, to be set by playtesting.
Starting guesses:
- World: T1 ≈ 300, T2 ≈ 1,500, T3 ≈ 5,000, T4 = the rest.
- Ukraine: T1 ≈ 50, T2 ≈ 150, T3 ≈ 300, T4 = the rest.

- The bot picks a **random** unused city from its vocabulary that satisfies the
  letter rule, weighted toward better-known cities. That keeps games varied and
  keeps its cities recognizable.
- The bot "thinks" for a short moment before answering (≈ 0.6–1.2 s) for feel.
- **When the bot has no valid city left, it gives up, and the player wins.**

### 2.6 Hints
- **3 hints per game.** A hint plays a valid, unused city on the player's
  behalf, preferring well-known ones.
- A hinted city scores **0 points**, doesn't count toward the chain, and isn't
  added to the player's discovered cities. It just keeps the game alive.

### 2.7 End of game
- **Win:** CityBot can't answer.
- **Loss:** the player's timer hits zero, or the player taps **Give up**.
- The game-over view shows: Win/Loss, score, cities you named, **new cities
  discovered** this game, and the **Play again** / **Home** actions.

### 2.8 Scoring
| Event | Points |
|---|---|
| City you named | +10 |
| …and you had **never named it before** in any game | +25 instead of +10 |
| Hinted city | 0 |
| Win | +50 × difficulty (Easy 1, Medium 2, Hard 3) |

**Chain** = the number of cities you named yourself (not hinted) in one game.

## 3. Screens (MVP)

The visual design carries over from the current app: the "vibrant" palette,
rounded cards, chat bubbles, and glow buttons. The fonts are Nunito (headings)
and Rubik (body). They replace the design file's Baloo 2 and Poppins, which
can't render Ukrainian.

1. **Home.** Hero, a **Play** button (opens the setup sheet), a small lifetime
   stats card (tapping it opens Statistics), a Settings icon and a Statistics
   icon.
2. **Setup sheet.** City list + difficulty + Start (§2.1).
3. **Game (chat).**
   - Bot bubbles on the left, player bubbles on the right. The first letter of
     each city is accented.
   - A turn banner shows "your turn — «Х»" or "CityBot is thinking…".
   - A timer badge, a score pill, and a hint button with the remaining count.
   - A **Give up** action and an input bar that auto-focuses.
4. **Game over.** A win/loss view, as in §2.7.
5. **Settings.**
   - Language: Ukrainian / English, applied live.
   - About / credits, including the GeoNames data attribution required by its
     license.
6. **Statistics.**
   - **Summary:** games played, games won, win rate, longest chain, cities
     discovered.
   - **Per-list × difficulty record:** wins/losses and best score for each of
     the 6 combinations.
   - **Discovery progress:** % of Ukraine cities and % of World cities you have
     ever named, shown as progress bars with counts.

All data stays on the device and persists across launches.

## 4. City data (MVP requirements)

Each city has:
- a stable, globally unique `id` (the GeoNames id), which is the same across
  both lists;
- `nameEN`, an **optional** `nameUA`, alternate names for each language,
  `countryCode`, `isCapital`, and `population`.

Tiers and first letters are **derived at load time**, not stored.

List sizes (GeoNames, Sept 2026 build):

| List | English | Ukrainian |
|---|---|---|
| Ukraine (≥ 5,000 people) | 848 cities | 848 cities |
| World (≥ 15,000 people) | ~31,400 cities | ~7,200 cities |

- **Ukrainian cities' English names** follow Ukraine's official
  transliteration (Zaporizhzhia, Kryvyi Rih). Older spellings and pre-renaming
  names are still accepted (Zaporozhye, Chervonohrad / Червоноград).

- **World in Ukrainian contains only cities with a real Ukrainian name.**
  GeoNames has one for only ~7,000 of them. Machine-transliterating the rest
  produced names nobody would type, so they're left out. Important gaps
  (capitals, big cities) are filled by hand (T04).
- The Ukraine list includes smaller towns than World, because Ukrainian
  players know them. The details are in `tech_design.md` §4.

## 5. Future (not MVP, keep the door open)

- **Endurance mode.** An unbeatable bot; the goal is the highest score/chain
  before the timer wins.
- **Leaderboards.** Local personal bests first, then global (Supabase).
- **Monetization.** Rewarded ads for extra hints and "revive" after a timeout;
  optional banners on non-game screens.
- **Richer stats.** Most-used cities, favorite country, per-country progress,
  and a game history list.
- **Interactive map.** Color countries by % discovered (uses `countryCode`).
- **More modes.** Country-specific lists ("France only"), a Capitals mode
  (`isCapital`), and a merged Ukraine + World pool.
- **Multiplayer (PvP).** Real-time play against a human. The bot's turn is
  already a discrete step in the game loop, so a network turn can replace it.
- **Polish.** Sound effects and haptics, typo tolerance, more UI languages,
  daily challenge.

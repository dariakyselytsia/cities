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
- CityBot opens the game by naming a city. A **"Who starts"** setting lets
  the player open instead (CityBot by default). The opening city can start
  with any letter.
- Turns alternate: player → bot → player → …
- The city list is the same for both sides. The **player** may name any city in
  the active list. **CityBot** only names cities from its *vocabulary* (§2.5).

### 2.3 The Letter Rule
- The next city must start with the **last letter** of the previous city.
- If too few cities in the active list start with that letter, skip back to
  the previous letter, and keep going until you reach a playable letter.
  Apostrophes, hyphens and spaces are not letters.
  - **Rare letters.** A letter is playable when at least **5** (Ukraine
    list) or **20** (World) cities start with it.
    - So `ь` and `и` are always skipped. World also skips `й`, `ї` and `щ`:
      145 names end in `й` (Шанхай, Дубай) but only 16 start with it, and
      requiring it would jam most games. Ukraine skips `ї`, `ц`, `е`, `ф`,
      `є` and `щ`.
    - Skipping a letter few names end in costs nothing: its cities stay
      reachable through the rare-letter choice below. So the minimum
      doesn't need to be exact.
  - **Trap letters (T25, T20).** A letter is also skipped when **more
    than 6×** as many names require it as cities start with it.
    - Today that's only `а` in the Ukraine list: 235 names require it
      (Полтава, Одеса, Біла Церква), but only 16 cities start with it. So
      Полтава asks for «в» (or «а», below).
    - T25 kept `а` required on Medium and Hard. The T20 simulator showed
      that didn't make them harder: games were ~35% shorter, almost all
      ended on «а», and steering onto «а» paid off. So it's skipped on every
      difficulty.
    - The ratio is counted after skipping. «ц» counts the "-ець" names, and
      once `а` is skipped its names count for the letter before it (Полтава
      for «в»). Traps are removed worst first until no letter is over the
      ratio. In World no playable letter comes close (the worst is `я`,
      4.7×).
  - Examples: Хмельницький → «к», Шанхай → «а», Кременець → «ц» in World,
    but «н» in Ukraine.
  - The minimums and the ratio are tuning values (T20). The letters
    themselves are **dataset-driven**, with no hard-coded letter list.
    `dart run tool/letter_report.dart` prints the numbers.
  - **Rare-letter choice.** The player may also answer with any letter that
    was skipped after the required one, as rare or as a trap: after
    «Кам'янське» you can play on «К» or on «Е» (Енергодар); after
    «Кременець» on «Н», «Е» or «Ц»; after «Полтава» on «В» or «А». Letters no city starts with («ь», «и») never count. So a player who
    knows a rare city can use it, and nothing jams.
  - **CityBot and hints use the required letter, and a skipped letter only
    as a fallback (T25):** when no unused city they know starts with the
    required letter. The bot doesn't give up while it knows Енергодар, but
    it doesn't go looking for rare cities either, so they stay a find for
    the player.
- The game always shows the allowed letters on the player's turn
  ("Your turn — «К» or «Е»"), and the chat marks them in teal in the newest
  city.

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
2. **It starts with the required letter** (§2.3), by what the player typed
   **or** by the city's display name. So "Bombay" is accepted for «b» and for
   «m» (it's Mumbai), which is forgiving on purpose. The next letter always
   comes from the display name, which is what the chat shows. *Open question:
   revisit after playtesting (§6).*
3. **It hasn't been used** in this game by either side. There is one shared
   used-set.

A rejected answer shows its reason inline ("not in the list", "must start with
«Х»", "already used"). The player may retry until the timer runs out. The timer
does **not** reset on a wrong answer.

City names are displayed and matched in the **app language** only. In
Ukrainian, a Latin-script answer like "Kyiv" is not accepted.

### 2.5 CityBot and difficulty
Cities are ranked into **tiers** by fame. Fame is based on population rank
among the cities playable in the active list **and language** (T20), and
capitals of sovereign states always count as tier 1 (territory capitals such
as Flying Fish Cove don't). CityBot's vocabulary is the tiers its difficulty
allows, plus the best-known few cities of **every letter**:

| Difficulty | Bot knows | …and per letter at least | Player turn timer |
|---|---|---|---|
| Easy   | tier 1 only (≈ the best-known cities) | 2  | 45 s |
| Medium | tiers 1–2                             | 6  | 30 s |
| Hard   | tiers 1–3                             | 10 | 20 s |

Tier sizes are per list and are **tuning values**, set with the balance
simulator (`tool/simulate.dart`, T20):
- World: T1 = 150, T2 = 500, T3 = 1,500, T4 = the rest. The first guesses
  (300 / 1,500 / 5,000) let a keen player win World Medium about 1% of the
  time.
- Ukraine: T1 = 50, T2 = 150, T3 = 300, T4 = the rest.
- Ranking per language matters for World: most cities past its top 1,000
  have no Ukrainian name. Ranked over the whole list, the Ukrainian Hard bot
  knew 2,138 cities against 5,038 in English.
- The per-letter minimum closes holes the tiers leave: the Easy World bot
  knew no «ж» city and the Medium one no «ю», so a player could win just by
  steering onto those letters.

With these values, in simulated games against a player who knows the top N
cities (Ukraine 30 / 100 / 300, World 100 / 400 / 1,500), in Ukrainian:
- **Easy** is winnable: a casual player wins about half the Ukraine games
  (38% in World), a keen one nearly all.
- **Medium** is a challenge: a keen player wins about 55%.
- **Hard** is rare: a keen player almost never wins; an expert wins ~94%.

English plays harder at the same knowledge (World Medium: keen 17%).

- The bot picks a **random** unused city from its vocabulary that satisfies the
  letter rule, weighted toward better-known cities: a tier-1 city is 4× as
  likely as a tier-3 one, and tier 2 is 2× (tuning values). That keeps games
  varied and keeps its cities recognizable.
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
  Leaving the game mid-way (Back) counts as giving up; both ask first,
  and both end on the results, like any other end.
  - The **give-up dialog** says the game will be a loss and, once the player
    has named cities, that their chain of N ends. "Keep playing" is the big
    teal button, and "Give up" the quieter coral one.
  - A **timeout** first shows a dark **"Out of time!"** screen: the empty
    timer, the chain the player built, and "See results". A rewarded-ad
    "revive" (Future, §5) would be offered here; until then it's hidden.
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

**Button colors (T27):** positive actions (Play, Start, Play again, Keep
playing, Try again) are **teal**; negative ones (Give up) are **coral**.
Coral stays the brand color (the logo).

1. **Home.** Hero, a **Play** button (opens the setup sheet), a small lifetime
   stats card (tapping it opens Statistics), a Settings icon and a Statistics
   icon.
2. **Setup sheet.** City list + difficulty + Start (§2.1).
3. **Game (chat).**
   - Bot bubbles on the left, player bubbles on the right. The first letter of
     each city is accented. In the newest city, the letter the next city must
     start with is teal, matching the teal turn banner, and so are the rarer
     letters skipped after it, which may be played too (§2.3): Кременець →
     «н», «е», «ц». Letters no city starts with («ь») aren't marked.
   - The turn banner is teal: coral is kept for errors and low time.
   - A turn banner shows "your turn — «Х»" or "CityBot is thinking…".
   - A timer badge, a score pill, and a hint button with the remaining count.
   - A **Give up** action and an input bar that auto-focuses.
   - When the app goes to the background, the game pauses: the countdown
     stops, and the chat is blurred under a big pause icon (‖) so the clock
     can't be used to look cities up. A tap resumes it.
4. **Game over.** The give-up dialog, the "Out of time!" screen and a
   win/loss view, as in §2.7.
5. **Settings.**
   - Language: Ukrainian / English, applied live.
   - Who starts: CityBot (default) / me (§2.2).
   - About / credits, including the GeoNames data attribution required by its
     license.
6. **Statistics.**
   - **Summary:** games played, games won, win rate, longest chain, cities
     discovered.
   - **Per-list × difficulty record:** wins/losses and best score for each of
     the 6 combinations.
   - **Discovery progress:** % of Ukraine cities and % of World cities you have
     ever named, shown as progress bars with counts. The totals are the
     cities playable in the app's language (World in Ukrainian ≈ 7k).
   - A new player sees a welcome with a Play button instead of zeros.

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

## 6. Open questions (revisit after playtesting)

Rules that were decided provisionally. Each one is easy to change in
`engine/`; decide after the playtest (T28).

- **Alias answers and the letter (T09, §2.4).** Today an answer fits the
  required letter by what was typed **or** by the city's display name, so
  "Bombay" is accepted for «b» and «m». Alternatives:
  - strict: the display name only;
  - typed only: the next letter then follows what was typed, but the chat
    shows the display name.
  Watch whether players find the lenient rule confusing or exploit it.
- **Which letters the letter rule skips (§2.3).** Per-list minimums plus
  trap letters, on every difficulty (T25, T20); CityBot uses the skipped
  letters as a fallback. In the playtest, check that players understand
  "«В» or «А»" after Полтава.
- **Turn timers (§2.5).** 45 / 30 / 20 s are still the first guesses: the
  simulator measures what a player knows, not how fast they recall it.
  Time real turns in the playtest; Hard games now run 40–100 cities.
- **Who starts by default (§2.2).** CityBot, with a setting to open
  yourself. Check which default new players prefer.

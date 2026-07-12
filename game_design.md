# Product Overview
"Cities" (Міста) is an interactive, educational mobile word game for iOS and Android. The core loop is a turn-by-turn duel against **CityBot**: the bot and the player alternate naming cities, each city beginning with the *last valid letter* of the one before. The player races a per-turn countdown, scoring points for every valid city they name. There is **no solo/self-play mode** — every game is played against CityBot.

# MVP Feature Scope

## 1. City Lists (the pool a game draws from)
- **Ukraine Only:** Only cities located within Ukraine are valid.
- **World:** Cities from all around the world are valid.

*(These are the datasets a match uses — selected in Settings — not separate play modes. The play mode is always Player vs. CityBot.)*

## 2. Core Game Logic
- **Opponent — CityBot (the main and only mode):** The player always plays against
  CityBot. Turns alternate: the bot opens by naming a city, the player must answer
  with a city starting from the bot's last valid letter, the bot replies off the
  player's last letter, and so on.
  - *Bot behavior:* CityBot draws from the **same active city list** as the player,
    obeys the same Letter and Uniqueness rules, and **always answers if any valid
    unused city exists** (with a big dataset that is effectively always). It is a
    pace-setter, not a beatable opponent — you cannot "stump" it.
  - *Bot response:* answers instantly (an optional short "thinking" delay is a
    polish item, not required for MVP). The absolute-new-city bonus and scoring
    apply only to the **player's** cities; the bot's cities score nothing.
- **The Letter Rule:** The next city must start with the *last valid letter* of the previous city.
  - *Exception Handling:* Letters like 'ь' (soft sign), 'и' in Ukrainian must be skipped if no city starts with them. The algorithm must backtrack to the previous letter.
- **Uniqueness Rule:** A city can only be used ONCE per game session — the used-city
  set is **shared** across both sides, so neither the player nor the bot may repeat
  any city already named by either of them this session.
- **Timer & end of round (endurance / high score):** The player has a strict time
  limit (e.g., 15-30 seconds per answer, so it resets every turn). The round can end
  **only one way — the player's clock hitting zero** (or an explicit Surrender). Since
  the bot can't be beaten, there is no "you win" state: the goal is the **highest
  score / longest streak** before the player fails. (A game-over dialog then offers
  Revive-via-ad; see §3.)
- **Scoring System:** 
  - Standard city = Base points (e.g., +10).
  - *Absolute New City* (a city the player has NEVER named in any previous session across the app's lifetime) = Bonus points (e.g., +25). This requires keeping a local historic array of `usedCityIds`.

## 3. Screens & UI Elements
**Home Screen:**
- A static image of a World Map (acts as a placeholder for a future interactive map).
- "Play" button.
- "Settings" icon (Top right).
- "Leaderboard" button (Below Play).

**Settings Screen:**
- **Language Toggle:** Ukrainian / English (applies live).
- **City lists** (multi-select checkboxes): *Ukraine* and/or *World*. At least one must stay selected. Ukraine-only → `GameMode.ukraine`; World checked (alone or with Ukraine) → `GameMode.world`. *(A true merged "both" pool is a future domain change — for MVP, both-checked plays World.)*
- **Sound effects:** on/off *(held but not consumed yet — no audio system wired)*.
- Preferences persist across launches (`shared_preferences`).

**Game Screen (Chat Interface):**
- **UI:** A scrollable chat-like list showing the volley of named cities — the
  player's cities as right-aligned bubbles and **CityBot's** as left-aligned bubbles
  (with a bot avatar/name). The input field is fixed at the bottom with auto-focus;
  a turn banner cues whose move it is and the required starting letter.
- **Header Tools:** 
  - "Hint" button (User starts with 3 free hints. Further hints require watching a Rewarded Video Ad).
  - "Surrender / Give Up" button.
- **Timer Visual:** A clear countdown indicator with visual countdown.
- **Revive Mechanic:** On timeout, present a dialog: "Watch Ad to Continue". If the ad is watched, the game provides a valid city automatically, and the timer resets.

**Leaderboard Screen:**
The leaderboard has **two independent axes**:
- **Mode tabs:** Ukraine Cities Rankings / World Cities Rankings.
- **Scope filter:** Weekly / Global / Friends.

Displays the user's Local High Score (per mode). **Global** scope fetches Top Players
from the Supabase PostgreSQL database. **Weekly** windowing and **Friends** scope are
post-MVP hooks (design-ready; the Supabase schema — per-session timestamps and a
friends relation — isn't wired yet). Layout: podium (top 3) + ranked list.

## 4. Monetization Strategy
- **Rewarded Video Ads:** Used for extra hints and reviving after the timer runs out.
- **Banner Ads:** Optional placement at the bottom of non-gameplay screens (e.g., Home or Leaderboard).

# Data Models Foundation (Crucial for Future-Proofing)
The initial JSON data and Isar schema for a `City` MUST include the following fields to support future updates without database migrations:
```dart
class City {
  int id;
  String nameUA;
  String nameEN;
  String countryCode;   // ISO-3166 alpha-2, e.g. 'UA', 'FR'. Always a real code
                        // (dataset guarantees no 'Unknown'). Used for future map coloring.
  bool isCapital;       // Crucial for future "Capitals Only" mode.
  String firstLetterUA; // First letter of nameUA. Indexed for O(1) gameplay lookup.
  String firstLetterEN; // First letter of nameEN. Indexed separately — a city's UA
                        // and EN names start with different letters, and the
                        // letter-chain runs per active language/mode.
}
```

> **Why two first-letter fields:** the game is bilingual; the last-valid-letter chain
> is computed in the session's language, so each name needs its own indexed first
> letter. A single `firstLetter` can't serve both.


## 5. User Statistics & Insights (NEW)

At the end of every game session, the app recalculates and updates the following user statistics:

- **Most Used Cities:** Top N cities the user has named most frequently.
- **High Scores:** All-time and recent best scores per mode.
- **Used Cities Percentage:** Progress bars showing % of all cities discovered (Ukraine, World, and per country).
- **Favorite Country:** The country where the user has named the most unique cities.
- **Longest Streak:** The highest number of consecutive correct answers in a session.
- **Session History:** Recent session stats (score, mode, time, unique cities).

# Future Roadmap (Do NOT build for MVP, but architect for it)
- Interactive Map: countryCode will be used to calculate what percentage of a country`s cities have been discovered, coloring an SVG map dynamically.
- Specific Country Modes: e.g., "France only", filtering by countryCode.
- Capitals Mode: Filtering by isCapital == true.
- Multiplayer (PvP): Real-time battles against another human using Supabase Realtime WebSockets. The MVP's Player-vs-CityBot loop is the seam for this: the BLoC must model an opponent turn as a discrete event so a "Bot Turn" can be swapped for a "Network Turn" without reworking the game loop.
- Beatable / difficulty-tiered CityBot: bot think-time and a chance to "give up" (a real win state), so the player can defeat the bot — an enhancement over the MVP's unbeatable endurance pace-setter.
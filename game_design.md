# Product Overview
"Cities" (Міста) is an interactive, educational mobile word game for iOS and Android. The core loop involves the player typing a city name that begins with the last valid letter of the previously named city. 

# MVP Feature Scope

## 1. Game Modes
- **Ukraine Only:** Only cities located within Ukraine are valid.
- **World:** Cities from all around the world are valid.

## 2. Core Game Logic
- **The Letter Rule:** The next city must start with the *last valid letter* of the previous city.
  - *Exception Handling:* Letters like 'ь' (soft sign), 'и' in Ukrainian must be skipped if no city starts with them. The algorithm must backtrack to the previous letter.
- **Uniqueness Rule:** A city can only be used ONCE per game session.
- **Timer:** The player has a strict time limit (e.g., 15-30 seconds) to answer. If the timer hits zero, they lose.
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
- Language Toggle: Ukrainian / English.
- Mode Selector: Ukraine / World.

**Game Screen (Chat Interface):**
- **UI:** A scrollable chat-like list showing the history of named cities. The input field is fixed at the bottom with auto-focus.
- **Header Tools:** 
  - "Hint" button (User starts with 3 free hints. Further hints require watching a Rewarded Video Ad).
  - "Surrender / Give Up" button.
- **Timer Visual:** A clear countdown indicator with vidual countdown.
- **Revive Mechanic:** On timeout, present a dialog: "Watch Ad to Continue". If the ad is watched, the game provides a valid city automatically, and the timer resets.

**Leaderboard Screen:**
- Two tabs: "Ukraine Cities Rankings" and "World Cities Rankings".
- Displays the user's Local High Score.
- Fetches Global Top Players from Supabase PostgreSQL database.

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
  String countryCode; // E.g., 'UA', 'FR'. Crucial for future map coloring.
  bool isCapital;     // Crucial for future "Capitals Only" mode.
  String firstLetter; // Indexed for O(1) microsecond lookup during gameplay.
}
```


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
- Multiplayer (PvP): Real-time battles using Supabase Realtime WebSockets. The BLoC structure must be clean enough to swap a "Bot Event" for a "Network Event".
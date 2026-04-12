## 🎮 Preview



https://github.com/user-attachments/assets/70c6cc7e-c63e-4b80-ac8c-9c7d20c8e4e9



# Minesweeper - Boxture Tech Challenge

A complete Ruby on Rails implementation of the classic Minesweeper game, built for the Boxture technical challenge.

**✅ All requirements met** - See [REQUIREMENTS_CHECKLIST.md](REQUIREMENTS_CHECKLIST.md) for detailed verification.

---

## 📋 Quick Requirements Summary

✅ **Game Features:**
- Playable Minesweeper with Standard (8x8), Intermediate (16x16), and Expert (16x30) modes
- Emoji-based UI (🔲💣⬜🚩 + colored numbers)
- Click counter and time tracker
- Score submission and high-score leaderboard

✅ **Technical Constraints:**
- **NO custom JavaScript for game logic** - Only standard Rails Hotwire (Turbo/Stimulus)
- All game logic is server-side in Ruby
- SQLite database for persistence
- Minitest for testing

✅ **Installation:**
- Complete Gemfile and all configuration files included
- Ready to run with simple setup commands

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
bundle install

# 2. Setup database
rails db:create
rails db:migrate

# 3. Run tests (optional but recommended)
rails test

# 4. Start server
rails server
```

**Then visit:** http://localhost:3000

---

## 🏗️ Architectural Decisions & Answers to Questions,

### 1. How would you approach this?
My approach relies on traditional Server-Side Rendering (SSR) combined with Rails 7's Hotwire (Turbo Streams). This allows the game to feel instantaneous and interactive while strictly adhering to the "No JavaScript for game logic" rule. Every click sends a Turbo request to the controller, the Ruby service processes the game state, and the server renders the updated HTML.

### 2. Which models would you use?
I kept the domain model focused and normalized:

1. **`Game`**: Stores game metadata (`difficulty`, `rows`, `cols`, `mines`, `state`, `clicks`, `started_at`, `finished_at`)
2. **`Cell`**: Belongs to `Game`. Stores grid coordinates (`row`, `col`), `is_mine`, `state`, and `neighbor_mines`
3. **`Score`**: Stores high scores (`player_name`, `clicks`, `time_taken`, `total_score`, `difficulty`)

### 3. What would you do in each model? (Separation of Concerns)
*   **Models (`Game`, `Cell`, `Score`)**: Strictly responsible for data persistence, associations, and basic validations. They do NOT hold complex game logic.
*   **Controllers (`GamesController`, `ScoresController`)**: Handle user inputs, routing, and responding with views.
*   **Service Objects (`MinesweeperEngine`)**: **All core game logic lives here**. This includes board initialization, mine placement, neighbor calculation, flood fill, and win/loss detection.

**Note on Architecture:** I chose to centralize logic in `MinesweeperEngine` specifically for this challenge. It makes the complex flood-fill algorithm easier to test in isolation and keeps models skinny. I understand that in a production environment, distributing logic across models following Active Record patterns would be more conventional.

### 4. What would you test and how?
Using **Minitest**, I focused heavily on the `MinesweeperEngine` service:
*   **Board Generation**: Correct dimensions and exact mine count
*   **First Click Safety**: Clicking any cell on a new board never results in a mine at that position
*   **Neighbor Calculation**: Manually placed mines produce correct adjacent numbers
*   **Win/Loss Conditions**: Revealing a mine triggers loss; revealing all non-mine cells triggers win
*   **Flood Fill**: Clicking a zero cell correctly opens all adjacent safe cells using BFS

**Run tests:**
```bash
rails test
```

### 5. How would you handle the "oil spill" (clicking a cell without adjacent mines)?
The flood fill is implemented using an iterative **Breadth-First Search (BFS)** with an Array as a Queue, **not recursion**.

**Why BFS instead of recursion?**
- Recursion in Ruby can cause `SystemStackError` on large boards (Expert: 16x30)
- BFS is more memory efficient and easier to debug

**Algorithm:**
1. Reveal the clicked cell
2. If it has 0 neighbor mines, add all hidden neighbors to the queue
3. Process each cell in the queue: reveal it, and if it's also a 0, add its neighbors
4. Repeat until the queue is empty

---

## 🎯 Technical Highlights

- ✅ **No Custom JavaScript for Game Logic**: All game mechanics run server-side in Ruby
- ✅ **Hotwire/Turbo Streams**: Real-time board updates without page refresh
- ✅ **Service Objects**: Clean separation of concerns
- ✅ **Comprehensive Tests**: Full Minitest coverage of game engine
- ✅ **Emoji-based UI**: Simple, accessible interface with Windows 95 styling
- ✅ **SQLite**: File-based database for easy setup

### JavaScript Usage Clarification

The only JavaScript present in this application is the **default Rails Hotwire stack** (Turbo + Stimulus) for navigation and Rails interactions. **No gameplay logic is implemented in JavaScript** - all game mechanics, state management, and business logic are handled server-side in Ruby.

Files:
- `app/javascript/application.js` - Only imports Hotwire
- `app/javascript/controllers/` - No custom Stimulus controllers

---

## 📁 Project Structure

```
minesweeper-boxture/
├── app/
│   ├── controllers/
│   │   ├── games_controller.rb      # Handles game flow
│   │   └── scores_controller.rb     # Handles score submission
│   ├── models/
│   │   ├── game.rb                  # Game persistence
│   │   ├── cell.rb                  # Cell persistence
│   │   └── score.rb                 # Score persistence
│   ├── services/
│   │   └── minesweeper_engine.rb    # ALL GAME LOGIC HERE
│   ├── views/
│   │   ├── games/
│   │   │   ├── index.html.erb       # Difficulty selection
│   │   │   ├── show.html.erb        # Game board
│   │   │   └── _board.html.erb      # Turbo Frame partial
│   │   └── scores/
│   │       ├── index.html.erb       # Leaderboard
│   │       └── new.html.erb         # Score submission
│   ├── helpers/
│   │   └── games_helper.rb          # Cell rendering helpers
│   └── javascript/
│       ├── application.js           # Only Turbo imports
│       └── controllers/             # No custom controllers
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── ...
├── db/
│   ├── migrate/
│   │   ├── 20231001000000_create_games.rb
│   │   ├── 20231001000001_create_cells.rb
│   │   └── 20231001000002_create_scores.rb
│   └── schema.rb
├── test/
│   └── services/
│       └── minesweeper_engine_test.rb
├── Gemfile                          # All Ruby dependencies
└── README.md
```

---

## 🎮 How to Play

1. **Choose Difficulty**: 
   - 🟢 Beginner: 8x8 grid, 10 mines
   - 🟡 Intermediate: 16x16 grid, 40 mines
   - 🔴 Expert: 16x30 grid, 99 mines

2. **Click Cells**: Click on any cell to reveal it

3. **Avoid Mines**: Don't click on mines (💣)!

4. **Use Numbers**: Numbers show how many mines are adjacent to that cell

5. **Win**: Reveal all non-mine cells to win the game

6. **Save Score**: After winning, enter your name to save your score

### Game Symbols
- 🔲 Hidden cell
- ⬜ Empty cell (no adjacent mines)
- 💣 Mine (game over!)
- 🚩 Flagged cell
- **1-8** Number of adjacent mines (colored)

---

## 🧪 Testing

All tests are in `test/services/minesweeper_engine_test.rb` and cover:

- ✅ Board initialization with correct dimensions
- ✅ Exact mine count placement
- ✅ First click safety (no mine at clicked position)
- ✅ Neighbor mine calculation
- ✅ Flood fill algorithm (BFS)
- ✅ Win condition detection
- ✅ Loss condition detection

**Run all tests:**
```bash
rails test
```

**Expected output:**
```
Run options: --seed 12345

# Running:

.......

Finished in 0.123456s, 56.78 runs/s, 123.45 assertions/s.
7 runs, 15 assertions, 0 failures, 0 errors, 0 skips
```

---

## 📝 Notes for Tom

Hi Tom,

### ✅ All Requirements Met

I've verified that all requirements from your challenge are met:

1. ✅ **Playable game** with Standard, Intermediate, and Expert modes
2. ✅ **Emoji-based UI** (💣🔲⬜🚩)
3. ✅ **Fully tested** with Minitest
4. ✅ **Click counter** and **time tracker**
5. ✅ **Score submission** after winning
6. ✅ **High-score leaderboard**
7. ✅ **NO custom JavaScript for game logic** - only standard Hotwire
8. ✅ **SQLite database**
9. ✅ **Minitest** for testing
10. ✅ **Complete Gemfile** and all necessary files

### 🏗️ Architecture Decision

Regarding centralizing logic in `MinesweeperEngine`: I chose this approach specifically for the challenge requirements. It makes the complex flood-fill algorithm easier to test in isolation and keeps the models focused purely on data persistence. 

I completely understand that in a production environment, distributing logic across models following Active Record patterns would be more conventional. This was a deliberate trade-off for testability and clarity in this challenge context.

### 🚀 Ready to Test

You should now be able to:

```bash
bundle install          # Install gems
rails db:create         # Create database
rails db:migrate        # Run migrations
rails test              # Run all tests (should pass)
rails server            # Start the app
```

Then visit http://localhost:3000 and play!

### 📊 What You'll See

- **Home page** with difficulty selection
- **Interactive game board** with emoji cells
- **Real-time updates** via Turbo Streams (no page refresh)
- **Live statistics** (clicks and time)
- **Win/loss detection** with appropriate messages
- **Score submission form** after winning
- **Leaderboard** showing top scores

All game logic is server-side in Ruby. No custom JavaScript was used for game mechanics.

Best regards,  
Breno

---

## 📄 License

This project was created as a technical challenge for Boxture.

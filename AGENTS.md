# Flash - Project Documentation

## Maintenance

When adding new features, controllers, actions, views, or CSS files, update the relevant sections of this file (file tree, data model, CSS organization, important notes, etc.) to keep it accurate.

## Overview

Flash is a flashcard study application built with Ruby on Rails that uses spaced repetition to help users learn and retain information. The app features a distinctive "Terminal Scholar" design aesthetic and uses Phlex for view rendering instead of ERB.

**Tech Stack:**
- Ruby on Rails 8.1.3
- PostgreSQL database
- Phlex for HTML views
- Creem for payment processing
- Hotwire (Turbo + Stimulus)
- Solid Queue for background jobs (Mission Control dashboard)
- Solid Cable for Action Cable (database-backed, no Redis)
- pnpm for JavaScript package management

## Design Philosophy

### Terminal Scholar Aesthetic

Flash has a **bold, distinctive visual identity** called "Terminal Scholar" that avoids generic web app aesthetics:

**Core Design Principles:**
- **No rounded corners** - Everything uses `border-radius: 0` for an angular, academic feel
- **Offset shadows** - Signature look with layered shadows that give depth without softness
- **Warm earth tones** - Primary color palette based on chocolate browns and warm ambers
- **Bold borders** - 3-4px borders throughout, never subtle 1px borders
- **Striped accents** - Repeating gradient patterns for decorative elements
- **Serif + Sans combination** - DM Serif Display for headings, Manrope for body, JetBrains Mono for code/labels

**Color Palette:**
```css
/* Primary Colors */
--color-primary: #d2691e;        /* Chocolate */
--color-primary-dark: #b8531a;
--color-primary-light: #f5dcc8;
--color-secondary: #2c5f4f;      /* Forest green */
--color-accent: #e6a94e;         /* Amber */

/* Backgrounds */
--color-bg: #fdf8f3;             /* Warm off-white */
--color-bg-subtle: #f5ede2;      /* Cream */
--color-bg-elevated: #fefcfa;    /* Nearly white */

/* Text */
--color-text: #2a2420;           /* Dark brown */
--color-text-secondary: #5a4f47;
--color-text-muted: #8a7f77;

/* Borders */
--color-border: #d4c4b0;
--color-border-medium: #b8a895;
--color-border-dark: #8a7f77;
```

**Typography:**
- **Display/Headings**: 'DM Serif Display' - Elegant serif for titles
- **Body Text**: 'Manrope' - Clean sans-serif for readability
- **Labels/Code**: 'JetBrains Mono' - Monospace for technical elements

### Design Patterns

**Card Pattern:**
```css
.card {
  background: #fefcfa;
  border: 4px solid #d4c4b0;
  border-radius: 0;
  padding: 2.5rem;
  box-shadow:
    8px 8px 0 -2px #fdf8f3,
    8px 8px 0 0 #b8a895,
    0 8px 24px rgba(42, 36, 32, 0.12);
}
```

**Button Pattern:**
```css
.button-primary {
  background: #d2691e;
  border: 3px solid #b8531a;
  border-radius: 0;
  box-shadow:
    5px 5px 0 -2px #fdf8f3,
    5px 5px 0 0 #b8531a,
    0 4px 12px rgba(210, 105, 30, 0.25);
}

.button-primary:hover {
  transform: translate(-2px, -2px);
  box-shadow:
    7px 7px 0 -2px #fdf8f3,
    7px 7px 0 0 #8b4513,
    0 6px 20px rgba(210, 105, 30, 0.35);
}

.button-primary:active {
  transform: translate(2px, 2px);
  box-shadow:
    3px 3px 0 -2px #fdf8f3,
    3px 3px 0 0 #b8531a,
    0 2px 8px rgba(210, 105, 30, 0.2);
}
```

**Striped Accent:**
```css
.accent-stripe {
  background: repeating-linear-gradient(
    90deg,
    #d2691e,
    #d2691e 12px,
    #b8531a 12px,
    #b8531a 24px
  );
}
```

## Architecture

### View Layer - Phlex

Flash uses **Phlex** instead of ERB for all views. Phlex is a Ruby DSL for building HTML components.

**Key Patterns:**

1. **All views inherit from `Views::Base`:**
```ruby
module Views
  module Pages
    class Show < Views::Base
      def view_template
        div(class: "container") do
          h1 { "Title" }
        end
      end
    end
  end
end
```

2. **No CSS classes in markup unless necessary** - We extract styles to dedicated CSS files

3. **Use heredocs for long text blocks:**
```ruby
p do
  <<~TEXT
    This is a long paragraph of text that would be hard to read
    if it was all on one line with plain() calls.
  TEXT
end
```

4. **Use `plain()` only when mixing text with other elements:**
```ruby
# Good
p { "Simple text" }

# Good
p do
  strong { "Bold:" }
  plain(" regular text after")
end

# Bad - unnecessary plain() wrapper
p do
  plain("Simple text")
end
```

5. **Component helpers in base:**
```ruby
# app/components/base.rb
module Components
  class Base < Phlex::HTML
    include Phlex::Rails::Helpers::ButtonTo
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::ImageTag
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::MailTo
    # ... etc

    register_value_helper :current_user
  end
end
```

### Styling Approach

**CSS Organization** (all included via the layout):
- `accent-box.css` - `.accent-box` callouts (round-complete, milestones, empty states)
- `application.css` - Base styles, resets, common patterns, global `a:visited`
- `auth.css` - Authentication pages (sign in / account)
- `button.css` - `.button` base and variants (`button_class` modifiers: compact / primary / ghost / secondary / danger / disabled)
- `card.css` - Generic `.card` container pattern
- `catalog.css` - Public deck catalog + preview (`.catalog-show-*` reused by the share-link preview at `/shared/:token`)
- `custom.css` - Scratch space for ad-hoc overrides
- `decks.css` - Deck listing, deck form, and deck-show page (incl. `.deck-share-*` block)
- `demo-banner.css` - Demo-mode banner
- `dialog.css` - Modal dialog component styles (`.dialog`, `.dialog__header`, etc.)
- `edit-card.css` - Edit card trigger button and form layout within the dialog (also the study-goal dialog's three goal-mode forms, toggled with `:has()`)
- `flash.css` - Study/flashcard core (card front + kebab menu, answers grid, `.card-reading`, the Study | Read `.study-tabs` and `.reading-snippet` on the Read tab, with its lookup popovers; `.reading-snippets--spaced` for languages written with spaces)
- `layout.css` - Header, footer, navigation
- `music-study.css` - Mic-driven music study UI
- `price-display.css` - `.price-display` component
- `pricing.css` - Pricing page
- `subscription.css` - Subscription page
- `table.css` - Generic `.table` pattern (catalog preview, deck cards); `.table__actions` lines up a cell's buttons
- `welcome.css` - Landing page styles

**Key Principles:**
- Separate CSS files per major section
- Include all stylesheets in layout
- Avoid inline styles
- Use CSS custom properties (variables) for colors
- Mobile-first responsive design with media queries

### Data Model

**Two content models, one card table.** Basic and Music decks are **flat**: the card owns its content (`front`, `back`, `category`, `reading`, `example_front`, `example_back`) and its progress counters directly, with `card_distractors` rows for decoys. Language decks still keep content in a shared, neutral **word list** of items and pairings — `LanguageCard` overrides the column readers to go through its `item`. `Deck#flat_cards?` is the switch between them. The language side is slated to leave the item layer too, at which point the item machinery goes away entirely.

**Core Models:**
- `User` - Authentication. Has `username` (unique, `/\A[a-zA-Z0-9_.]+\z/` — letters, digits, `_`, `.`), `role` (`"user"` / `"admin"` / `"guest"`), `study_goal`, `time_zone`. `has_many :word_lists`, `has_many :sources` (through word_lists), `has_many :decks` (**direct** — every deck carries `user_id`), `has_one :subscription`.
- `WordList` - A selection of language study content, reusable across decks. `belongs_to :user`, `has_many :items`, `has_many :decks`, `has_one :source` (and its `snippets`). `name` unique per user. Requires a `language` code. Not STI: Basic and Music left this layer for flat cards, so every word list is language content, and the compendium distinguishes kinds (HSK level, chapter, curated) by column rather than by class.
- `Item` - One neutral term. Has `side` (`"Front"` / `"Back"`), `text`, and (Front-side) `category`, `reading`, `example`, `paired_example`. Belongs to a word list; unique on `[word_list_id, side, text]`. Front↔back meaning is expressed through `Pairing`; distractor candidates through `ItemDistractor`. `#glosses` returns the paired Back texts in authored order.
- `Pairing` - Join between a Front `item` and a Back `paired_item` (one row per gloss).
- `ItemDistractor` - Join marking a Back item as a preset distractor for a Front `item`. The language-side counterpart of `CardDistractor`.
- `CardDistractor` - A wrong-answer option owned directly by a flat card (uploaded presets and remembered study misses). Unique on `[card_id, text]`.
- `Deck` (STI base) - A study form. `belongs_to :user` and `belongs_to :word_list` — required *unless* `flat_cards?`, forbidden *if* it is (the presence/absence pair is what keeps the two content models apart). `has_many :snippets` through the word_list, oldest first (none on flat decks). Flat families own a `name` column (unique per user); language decks delegate `name` to the word_list, and the `ordered` scope COALESCEs the two. Has `visibility` (`"public"` / `"private"`), `round` (default 1, current study round), `distractor_pool` (`"category"` / `"preset"` / `"none"`, NOT NULL — set by the importer), `ordered`, `study_goal`, `last_studied_at`, nullable `share_token`, and `goal_mode` (`"none"` / `"session"` / `"target"`) with its round target (`target_round` + `target_date` — "finish round N by date"; see Round Targets). In `"none"` mode the study page shows a plain "N completed today" count with a "set goal" button instead of the progress bar, and never shows the milestone.
- `Card` (STI base) - `belongs_to :deck`, `belongs_to :item` (nullable — flat cards have none), `belongs_to :source_card` (catalog-copy provenance). `has_many :card_distractors`. Owns the content columns and the progress counters (`correct_count`, `correct_streak`, `view_count`), and holds the score handle (`record_correct!`, `record_miss!`, `record_view!`). `normalizes :back` is the single back-joining rule. Unique on `[deck_id, front]` where `front` is present.
- `StudyDay` - Cards a deck completed on one day (`studied_on`, in the owner's time zone), unique on `[deck_id, studied_on]`. `completed_count` counts the current batch and drives the progress bar; the milestone's "Keep Going" starts a new batch by resetting it to 0 (and, under a round target, sizing the batch to lower tomorrow's goal by one). `goal` holds the day's goal worked out from a round target (nil without one; `#study_goal` falls back to the deck's). `deck.study_days.today` finds or creates the row.
- `Subscription` - Payment/subscription info, belongs to user.
- `Snippet` - One section of a source, feeding the source's word_list (`belongs_to :source`, required; destroyed with it; `word_list` is the source's). Has an optional `heading` (and its `heading_translation`) and a `body`, kept as written; `#title` joins the source's title and the heading for reports. The body is capped at `Snippet::MAX_BODY` characters (processing costs LLM calls per sentence). `has_many :sentences`, ordered by `position`. `#status` is `:new` or `:finished` when every sentence is, and `:in_progress` otherwise. Admins add snippets from a source's page (`/sources/:id/snippets/new`, `SnippetsController`, `Snippets::Create`), in production or locally; processing happens locally.
- `Source` - Where a word_list's snippets come from (an article, a book, a drawer of scraps), one per word_list (`belongs_to :word_list`, unique; `WordList has_one :source`). Holds what its snippets share: `title` (and its optional `title_translation`, which `Deck#name_translation` returns, shown under the deck's name wherever it appears), `author`, `source_url`, and a `license` (a key of `Source::LICENSES`, defaulting to `all_rights_reserved`; `#shareable?` decides who else may read it). `has_many :snippets`, oldest first, and `has_many :readers` (`SourceReader`). `#readable_by?(user)`: the list's owner, a reader let in, or anyone when the license is `shareable?`. `#status` is `:new` or `:finished` when every snippet is, and `:in_progress` otherwise; `#studyable?` once any snippet is finished. Its list must be in a language snippets can be processed in (`Language`: Mandarin or Portuguese, chosen on the sources form), which `#language` returns. Admins add sources at `/sources` (`SourcesController`, `Sources::Create`, which makes the word_list, named after the source's title).
- `SourceReader` - A user an admin has let read a source whatever its license (`source.readers`), unique on `[source_id, user_id]`. Production-only user data: not in the compendium snapshot, and removed with its source or user.
- `SnippetSentence` - One sentence of a snippet, unique on `[snippet_id, position]`. `tokens` (jsonb) holds the pieces it was cut into, in order: each token's `text` as written (traditional stays traditional) and, for a word, the `sense_id` it is studied as; punctuation and other non-words carry no `sense_id`, nor does a word the segmenter skipped, which keeps why as `skip` (a Portuguese text's people's names, `"name"`, and other names and titles left in another language, `"foreign"`). `#status` is `:new` with no tokens, `:finished` once every Han token has a `sense_id` and no token carries other keys, and `:in_progress` between.
**`WordList` languages:** `LANGUAGES` (on `WordList`) maps every individual ISO 639-2 language to its display name, keyed by shortest available code per BCP 47 ("zh", not "zho"; "tlh" works). Nothing in the app creates a word list any more — the deck form has no Language option — so the validation guards what the seed account and catalog copies carry.

**Deck/Card STI subclasses** (deck class names match their UI representation — the future skill tabs within a language section). Both hierarchies have an abstract language intermediate:
- `LanguageDeck < Deck` / `LanguageCard < Card` — never instantiated. `LanguageDeck` delegates `name` and `language` to the word_list and holds `mandarin?` and `hanzi_chars` (font features), and overrides `cards_in_category` / `reading_pairs` to join through items. `LanguageCard` overrides the content readers to read its `item`, requires one, and records a miss as an item-side decoy rather than a `card_distractors` row. The base `Deck#mandarin?` is `false`.
- `ReadingDeck < LanguageDeck` / `ReadingCard < LanguageCard` — forward study: multiple-choice (or fuzzy-find) recognition.
- `BasicDeck < Deck` / `BasicCard < Card` — plain forward flashcards on flat cards.
- `MusicDeck < Deck` / `MusicCard < Card` — microphone-driven music study on flat cards. Each `MusicCard.back` is a **single** note matching `MusicCard::NOTE_REGEXP` (e.g. `C4`, `F#3`), enforced by `Decks::CreateMusic` at import rather than by a model validation; sequences are formed at study time by windowing (see Music Decks). `MusicDeck` defaults `distractor_pool` to `"none"`.

`BasicDeck` and `MusicDeck` answer `flat_cards?` true. `BasicDeck` alone is `replaceable?` (CSV re-import). Card classes mirror the deck classes one-to-one; each deck declares its card class via `card_type` (no base-class default). Behavior lives on the two abstract intermediates; `ReadingCard`, `BasicCard`, and `MusicCard` exist for naming symmetry. In specs there is no `:card` factory — create cards through `:basic_card` / `:reading_card` / `:music_card`, and note that the `:deck` factory builds a `BasicDeck`.

**STI convention — `model_name` override:** each direct subclass of `Deck` / `Card` overrides `self.model_name` to return the parent's, so `form_with(model: reading_deck)` keeps routing to `decks_path` (not `reading_decks_path`). `LanguageDeck` and `LanguageCard` carry it for their own subclasses, which inherit it. Apply this to any new STI subclass of the base.

**`belongs_to` is optional by default** (`config.active_record.belongs_to_required_by_default = false`), so required associations are stated explicitly. `Deck` and `Card` use validations — `validates :deck_id, presence: true` on `Card`, `validates :item, presence: true` on `LanguageCard`, and the `word_list` presence/absence pair on `Deck` — backed by NOT NULL columns where the requirement is absolute.

**Card Progress:**
- A card is "done" at the current round when `correct_streak >= deck.round`
- Wrong answers reset `correct_streak` to 0
- When all cards in a deck are done, the deck advances to the next round
- Round N requires N correct answers in a row per card
- Streaks are cumulative across rounds (no reset on a new round)
- The `Card` model's `.done(round)` and `.not_done(round)` scopes require a round argument

### Keyboard Hotkeys

The app uses a **Stimulus hotkeys controller** (`app/javascript/controllers/hotkeys_controller.ts`) for keyboard shortcuts. It listens for `keydown` events at the document level and clicks the matching target element. It skips a target behind an open dialog or inside a `display: none` ancestor (such as the study frame while the Read tab is showing); a target that is hidden itself still works, which the study page's space-claiming span relies on. Keys typed into a text field are ignored (except `Ctrl` combos), but a focused radio or checkbox doesn't block hotkeys. The `[` / `]` text-size spans sit on the study page outside the frame, so they work on the Read tab.

**Adding a hotkey to any element:**
```ruby
data = { hotkeys_target: "click", hotkey: "a" }
link_to("My Link", some_path, data:)
```

**Current shortcuts:**
- `1`-`5` - Select answer during study
- `Space` - Next card after answering; Next Deck / Reset All Goals on the milestone
- `k` - Keep Going on the milestone (starts a new batch on the same deck; demo too)
- `[` / `]` - Decrease / increase study text size (card-front kebab menu)
- `e` - Open the edit-card dialog during study
- `Ctrl+Enter` - Save the edit-card dialog

**Hint styles:**
- `.hotkey-hint` - Prominent hint (amber background, bordered, used on buttons like "Press Space")
- `.keyboard-hint` - Subtle hint (muted text, used below answer grid for "Press 1-4 to answer")

### Payment Processing

Uses **Creem** (creem.io) for subscription payments:
- $5/month subscription
- Currently no extra features - just support for the project
- Webhook integration for subscription events
- Transparent messaging to users about what they're supporting

### Background Jobs

Jobs run on **Solid Queue**, with its tables in the main database:
- **Worker**: `bin/jobs` runs as its own `worker` process (`Procfile` and `Procfile.dev`). Without it, jobs queue up and never run.
- **Config**: `config/queue.yml` (dispatcher + workers; `JOB_CONCURRENCY` sets the worker process count) and `config/recurring.yml` (production-only schedule).
- **Recurring tasks**: hourly clearing of finished jobs (kept 14 days), and hourly `Demo::CleanupGuestUsers` via `CallableJob`. Schedule a new action the same way — `class: CallableJob` with the action name as the arg — rather than writing a job class per action.
- **Dashboard**: Mission Control is mounted at `/jobs` behind `AdminConstraint`, so it returns 404 for anyone but admins. Its HTTP basic auth is turned off for that reason.
- **Tests** use the `:test` adapter, so specs never touch the queue tables.

### Action Cable

Action Cable runs on **Solid Cable**, with its `solid_cable_messages` table in the main database:
- **Config**: `config/cable.yml` — development and production share the `solid_cable` adapter (polls every 0.1s, keeps messages 1 day). Development uses it too, rather than `async`, so a broadcast from the `worker` process reaches the browser.
- **Trimming**: old messages are cleared by a job, so it relies on the `worker` process running.
- **Tests** use the `test` adapter.
- Nothing subscribes yet, and `ApplicationCable::Connection` does no authentication — add it before streaming anything user-specific.

## Important Conventions

### File Organization

```
app/
├── actions/                      # Service objects (`.call` → Result); see Actions below
│   ├── catalog/
│   │   └── copy_deck.rb          # Duplicates a public deck into a user's account
│   ├── compendium.rb             # Lookup / edit / sync namespace: TABLES (parents first), column helpers, Refused
│   ├── compendium/
│   │   ├── apply.rb              # Snapshot → database: add / update / delete by id, with a Report
│   │   ├── edit.rb               # Sense edits: add / revise / remove / attach / detach (Refused)
│   │   ├── export.rb             # Database → snapshot (COPY TO STDOUT)
│   │   ├── load.rb               # Snapshot → empty database (Apply, then advance id sequences)
│   │   ├── lookup.rb             # `rails compendium:lookup Q=…`: entries for a headword or gloss
│   │   ├── pull.rb               # `unpushed?` check before a pull resets the database
│   │   ├── push.rb               # Push guards, then Apply to production
│   │   ├── snapshot.rb           # One CSV per table; checksum / empty?
│   │   └── staging.rb            # Loads a table's CSV into a temp table for Apply
│   ├── creem/
│   │   ├── cancel_subscription.rb
│   │   ├── client.rb             # Creem HTTP client
│   │   └── create_checkout.rb    # Creates a Creem checkout session
│   ├── sources/
│   │   ├── create.rb             # Saves a source + the Mandarin word_list named after it
│   │   └── grant.rb              # Lets a user (by username) read a source + gives them a ReadingDeck over its list
│   ├── snippets/
│   │   ├── attach.rb             # Appends a snippet's senses to its word_list, in snippet order
│   │   ├── briefing.rb           # Prompt for a list of occurrences: each sentence and word once, occurrences point at them
│   │   ├── categorize.rb         # Files memberships under a part of speech (Sonnet, headword + reading + gloss)
│   │   ├── create.rb             # Saves a snippet + its sentences as a section of a source
│   │   ├── finish.rb             # Closes a reviewed snippet: strip working keys, attach, categorize
│   │   ├── judge.rb              # Opus accepts or rejects proposed new senses
│   │   ├── mandarin.rb           # Mandarin's prompts (`Snippets::Mandarin::PROMPTS`) for each step, and its categories
│   │   ├── mandarin/
│   │   │   └── policy.rb         # Card rules shared by Mandarin's prompts (segmentation, reading, function words)
│   │   ├── occurrence.rb         # One word token: its headword and the compendium's senses for it
│   │   ├── portuguese.rb         # Portuguese's prompts (`Snippets::Portuguese::PROMPTS`): words kept in their form, no readings
│   │   ├── process.rb            # `rails snippets:process`: segments, then resolves, unprocessed sentences in batches
│   │   ├── prompts.rb            # A language's system prompts per step + categories (`Language#prompts`)
│   │   ├── proposal.rb           # A proposer's decision for one occurrence (existing / new / missegmented)
│   │   ├── propose.rb            # Sonnet decides each occurrence
│   │   ├── record.rb             # Turns a standing proposal into a token outcome; creates entry/sense
│   │   ├── recut.rb              # A re-segmented sentence's tokens, unchanged ones keeping their sense
│   │   ├── report.rb             # `rails snippets:review`: a snippet token by token, plus unused senses
│   │   ├── review.rb             # Token edits: repoint / add_sense / resegment
│   │   ├── resolve.rb            # Escalation ladder (RUNGS) over a sentence batch, in slices; re-segments missegmented sentences once
│   │   ├── segment.rb            # Sonnet segmentation, checked by the Han-rejoin test, with fallbacks
│   │   └── split_sentences.rb    # Body → sentences on Chinese terminal punctuation
│   ├── word_lists/
│   │   └── projection.rb         # Builds/replaces/edits items+pairings+cards from content rows
│   ├── decks/
│   │   ├── cards_csv.rb          # Shared CSV parsing/validation for all three create actions
│   │   ├── create_basic.rb       # Basic deck CSV import → flat cards
│   │   ├── create_music.rb       # Music deck CSV import (one note per card) → flat cards
│   │   ├── csv_examples.rb       # Optional example_front/example_back columns
│   │   ├── csv_reading.rb        # Optional `reading` column
│   │   ├── flat_cards.rb         # Card writer for Basic/Music: content lives on card columns
│   │   ├── replace.rb            # Re-import: diff CSV vs deck (add/remove/reset/keep)
│   │   └── result.rb             # Shared Result object for the deck actions
│   ├── demo/
│   │   ├── cleanup_guest_users.rb # Removes expired demo guest users
│   │   └── create_guest_user.rb   # Creates a temporary guest user for the demo
│   ├── llm.rb                    # Model ids, Llm::Error, `Llm.client` (set per environment)
│   └── llm/
│       ├── ask_each.rb           # Ask about a list; answer rows keyed by item index
│       ├── claude_cli.rb         # Development client: `claude -p` on the developer's subscription
│       └── fake.rb               # Spec client: queued answers / responder block, records calls
├── components/                   # Phlex view components
│   ├── base.rb                   # Base component (supporter_badge / music_badge / texts_badge / catalog_badge / translation / with_translation)
│   ├── card_front.rb             # Study card-front box + kebab menu; renders the reading gloss inside it
│   ├── card_menu.rb              # Card-front kebab menu (study text sizes, edit/delete actions)
│   ├── card_preview.rb           # 5-card preview block (shared by catalog and share preview)
│   ├── card_reading.rb           # Pronunciation/pinyin gloss (rendered inside CardFront on reveal)
│   ├── catalog_toggle_button.rb  # Publish / unpublish a deck to the public catalog
│   ├── deck_texts.rb             # "Source" block under the card preview (catalog + share preview): title / author / license, marked not included when unshareable
│   ├── demo_banner.rb            # Demo-mode banner
│   ├── error_explanation.rb      # Styled validation-error box
│   ├── fuzzy_find_answers.rb     # Typed-answer input for fuzzy-find mode (round 3+); optional reading `stage`
│   ├── goal_form.rb              # One study-goal form per goal mode (no goal / daily goal / target date)
│   ├── round_progress.rb         # Deck round indicator (ROUNDS = 3)
│   ├── music_card_body.rb        # Mic-driven music study widget
│   ├── music_csv_instructions.rb # CSV format help block for music decks
│   ├── replace_cards_dialog.rb   # Confirm dialog for re-importing a deck's cards
│   ├── session_milestone.rb      # Study milestone prompt (daily goal reached; Next Deck / Reset All Goals)
│   ├── session_progress.rb       # Study session progress bar
│   ├── study_answers.rb          # Study answer area per presentation mode (buttons / fuzzy find, reading stage)
│   ├── study_example.rb          # Optional example sentence on the answer view
│   ├── study_goal_dialog.rb      # Edit daily study-goal dialog
│   ├── reading_lookup.rb         # A Read-tab word's popover: reading or article + gloss, or why a skipped word has no card
│   ├── snippet_reading.rb        # Read tab text: the source's credit, then finished snippets word by word, each marked by its reading SkillScore (new / missed / done); gaps fade by deck round; lookup popovers
│   ├── source_credit.rb          # A source's link (when it has one) · its license
│   ├── source_license.rb         # A source's license name, linked to its terms when it has them
│   ├── study_tabs.rb             # Study | Read radios (CSS `:has()` toggles study frame vs. text)
│   ├── table.rb                  # `.table` pattern; block fills each row via `table.cell`
│   ├── target_goal_fields.rb     # Round-target fields + today's goal and Recalculate
│   ├── target_prompt.rb          # Missed / reached round-target note under the progress bar
│   ├── text_csv_instructions.rb  # CSV format help block for text decks
│   └── word_states.rb            # An answered card's words as they now stand, for the Read tab (`word_states_controller.ts`)
├── domain/
│   ├── deck_section.rb           # A decks-page section: one per language A–Z, then Basic, then Music; `first_unmet` drives Next Deck
│   ├── language.rb               # What processing a snippet needs per language: sentence ends, word characters, the segmenter's form and its check, readings or none, articles or none, skip reasons, whether words are spaced, prompts (`Language::MANDARIN`, `Language::PORTUGUESE`)
│   ├── study.rb                  # Study engine; `Study.for(deck:)` dispatches by deck type
│   └── music_study.rb            # MusicStudy < Study; windows cards into note sequences
├── helpers/
│   ├── application_helper.rb     # (empty)
│   └── css_helper.rb             # `button_class(*modifiers)` → `.button` class lists (mixed into Components::Base)
├── mailers/
│   └── application_mailer.rb
├── jobs/
│   ├── application_job.rb
│   └── callable_job.rb           # Runs `SomeAction.call` async (e.g. demo guest-user cleanup)
├── controllers/
│   ├── application_controller.rb
│   ├── accounts_controller.rb         # Account create / show / update / destroy
│   ├── cards_controller.rb            # Single-card edit / destroy (turbo streams; via ProjectsCards)
│   ├── catalog_controller.rb          # Public catalog browse / preview / copy / try (the demo)
│   ├── catalog_listings_controller.rb # Publish / unpublish a deck to the catalog
│   ├── concerns/
│   │   ├── demo_session.rb            # Demo guest-session helpers
│   │   └── projects_cards.rb          # save_card/destroy_card → Decks::FlatCards (flat decks only)
│   ├── decks_controller.rb            # `#create` dispatches CreateMusic vs CreateBasic on :deck_type
│   ├── lookups_controller.rb          # Read-tab word lookup: resets the sense's streak
│   ├── milestones_controller.rb       # Updates a deck's study goal
│   ├── pages_controller.rb            # pricing / privacy / terms
│   ├── replacements_controller.rb     # Re-import a deck's cards (Decks::Replace)
│   ├── sessions_controller.rb         # Login / logout
│   ├── shares_controller.rb           # Owner toggle (via :deck_id) + public preview/copy/try (via :token)
│   ├── snippets_controller.rb         # Snippet new / create under a source (admin)
│   ├── source_readers_controller.rb   # Who may read a source whatever its license: list / grant / revoke (admin)
│   ├── source_decks_controller.rb     # "Study this list": find-or-create a ReadingDeck over a source's list (admin)
│   ├── sources_controller.rb          # Source index / show / new / create (admin)
│   ├── studies_controller.rb          # Study show/update; dispatches text vs music views
│   ├── study_goal_resets_controller.rb # Reset today's count on all decks, go to the first deck
│   ├── subscriptions_controller.rb    # Creem subscription show / create / destroy
│   ├── webhooks/
│   │   └── creem_controller.rb        # Creem webhook receiver
│   └── welcome_controller.rb          # Landing page
├── models/
│   ├── application_record.rb
│   ├── user.rb              # has_many :word_lists, :decks (direct); has_one :subscription
│   ├── word_list.rb          # Language content selection decks point at; LANGUAGES lookup
│   ├── item.rb             # Neutral term (side/text + Front-side metadata); glosses/distractors
│   ├── pairing.rb          # Front item ↔ Back paired_item join
│   ├── item_distractor.rb  # Front item ↔ Back distractor_item join (language decoys)
│   ├── card_distractor.rb  # Card-owned decoy text (flat-card decoys)
│   ├── deck.rb             # STI base — user/word_list; flat_cards?/replaceable?
│   ├── language_deck.rb    # Abstract parent of the item-backed decks — mandarin?/hanzi_chars
│   ├── reading_deck.rb     # STI subclass — forward language study
│   ├── basic_deck.rb       # STI subclass — plain flashcards on flat cards; replaceable
│   ├── music_deck.rb       # STI subclass — flat cards; defaults distractor_pool to "none"
│   ├── card.rb             # STI base — owns content columns + progress counters + score handle
│   ├── language_card.rb    # Abstract parent of the item-backed cards — content read from item
│   ├── basic_card.rb       # STI subclass — overrides model_name only
│   ├── reading_card.rb     # STI subclass — no behavior of its own
│   ├── music_card.rb       # STI subclass — NOTE_REGEXP (single note)
│   ├── study_day.rb        # Per-deck, per-day completion count (current batch)
│   ├── subscription.rb
│   ├── snippet.rb          # Source text feeding a word_list
│   ├── source.rb           # Where a word_list's snippets come from; LICENSES
│   ├── source_reader.rb    # A user let read a source whatever its license
│   └── snippet_sentence.rb # Sentence + its tokens, each pointing at a sense
├── nulls/
│   └── null_user.rb          # Null-object User for logged-out / guest requests
├── views/                    # Phlex views (inherit from Views::Base)
│   ├── base.rb               # Base view class (wraps the application layout)
│   ├── layouts/
│   │   ├── application.rb
│   │   ├── mailer.html.erb
│   │   └── mailer.text.erb
│   ├── pwa/
│   │   ├── manifest.json.erb        # PWA manifest (served at /manifest)
│   │   └── service-worker.js        # PWA service worker (served at /service-worker)
│   ├── accounts/
│   │   ├── new.rb
│   │   └── show.rb
│   ├── cards/
│   │   └── edit_form.rb      # In-dialog card edit form (front / back / reading / category / example)
│   ├── catalog/
│   │   ├── index.rb          # Public deck grid (mic badge for music decks, 📖 for decks with shareable texts); Try This Deck for visitors and guests
│   │   └── show.rb           # Deck preview + texts + copy action, or try + log in for visitors and guests (mic badge in header)
│   ├── decks/
│   │   ├── index.rb          # Decks grouped into `DeckSection`s (each language, Basic, Music); each features its first unmet-goal deck, else its most recently studied
│   │   ├── new.rb            # Three-way deck-type radio + language select
│   │   ├── show.rb           # Share-link, replace link, cards table
│   │   └── replacements/
│   │       └── new.rb        # Re-import (replace) a deck's cards form
│   ├── pages/
│   │   ├── pricing.rb
│   │   ├── privacy.rb
│   │   └── terms.rb
│   ├── sessions/
│   │   └── new.rb
│   ├── shares/
│   │   └── show.rb           # Public share-link preview (attributed to owner)
│   ├── studies/
│   │   ├── show.rb           # Text-deck study prompt (answers via StudyAnswers)
│   │   ├── update.rb         # Text-deck answer result (renders CardReading + StudyExample)
│   │   ├── music_show.rb     # Mic-driven music study prompt
│   │   ├── music_update.rb   # Music answer result
│   │   └── study_page_data.rb # Study-page data helper: text-size / font / wake-lock controllers around the frame and the Read tab
│   ├── snippets/
│   │   └── new.rb            # Heading (optional) / body, under a source
│   ├── source_readers/
│   │   └── index.rb          # A source's readers (Remove each) + add-by-username form
│   ├── sources/
│   │   ├── index.rb          # Admin's sources with their status; "Study this list" once one has a finished snippet
│   │   ├── new.rb            # Title / language / author / source URL / license
│   │   └── show.rb           # A source's credit and its snippets with their status; "Add a snippet", "Study this list" and "Share" once a snippet is finished
│   ├── subscriptions/
│   │   └── show.rb
│   └── welcome/
│       └── index.rb
├── javascript/
│   ├── application.ts
│   ├── channels/
│   │   └── consumer.ts
│   ├── helpers/
│   │   ├── assert.ts                 # `assert` / `ensure` runtime guard
│   │   └── word_state.ts             # `setWordState`: a Read-tab word's new / missed / done class
│   ├── controllers/
│   │   ├── application.ts             # Stimulus application bootstrap
│   │   ├── index.ts                  # Controller manifest (register each controller here)
│   │   ├── auto_advance_controller.ts # Auto-advances to the next card after answering
│   │   ├── clipboard_controller.ts   # Copies an input value to the clipboard on click
│   │   ├── confirm_submit_controller.ts # Confirm-before-submit guard
│   │   ├── deck_type_controller.ts   # Toggles CSV instructions + language/music fieldsets on creation form
│   │   ├── dialog_controller.ts
│   │   ├── file_upload_controller.ts
│   │   ├── fuzzy_find_controller.ts  # Typed-answer matching for fuzzy-find study mode
│   │   ├── hotkeys_controller.ts     # Document-level keyboard shortcuts
│   │   ├── lookup_controller.ts      # POSTs a looked-up Read-tab word to reset its streak; marks it missed
│   │   ├── mobile_nav_controller.ts
│   │   ├── music_study_controller.ts # Mic capture + RAF loop + sequence-state-machine glue
│   │   ├── music_study_helpers.ts    # Helpers for music_study_controller
│   │   ├── text_size_controller.ts   # Study text-size kebab menu (persists to localStorage)
│   │   ├── timezone_controller.ts    # Sets the browser time zone on a hidden field
│   │   └── word_states_controller.ts # Marks Read-tab words with the states an answer sent
│   └── music/                        # Pure, framework-free audio modules (100% Vitest coverage)
│       ├── note_utils.ts             # Note ↔ frequency, sequence parsing
│       ├── pitch_detector.ts         # YIN-style pitch detection from Float32Array samples
│       ├── reference_player.ts       # Web Audio sine playback for note sequences
│       └── sequence_session.ts       # Pure state machine: hold-to-classify, advance/reset/complete
└── assets/
    └── stylesheets/                  # See CSS Organization above
        ├── accent-box.css
        ├── application.css
        ├── auth.css
        ├── button.css
        ├── card.css
        ├── catalog.css
        ├── custom.css
        ├── decks.css
        ├── demo-banner.css
        ├── dialog.css
        ├── edit-card.css
        ├── flash.css
        ├── layout.css
        ├── music-study.css
        ├── price-display.css
        ├── pricing.css
        ├── subscription.css
        ├── table.css
        └── welcome.css

db/
├── seeds.rb             # Entry point (loads db/seeds/*)
└── seeds/
    ├── admin.rb         # Local admin (admin / password); development and test only
    └── music_decks.rb   # Seeds starter music decks, owned by the admin

lib/
├── route_constraints/
│   └── admin_constraint.rb  # Routes inside `constraints AdminConstraint.new` 404 for non-admins
└── tasks/
    ├── compendium.rake      # compendium:pull / compendium:push / compendium:lookup (see Compendium Sync)
    └── snippets.rake        # snippets:process / snippets:review (see Snippet Processing)
```

### Actions

Business logic lives in **action modules** under `app/actions/`. Each action is a module with a `.call` class method that returns a `Result` object:

```ruby
module Catalog
  module CopyDeck
    def self.call(user:, deck:)
      # ... perform work ...
      Result.new(success: true, record: new_deck)
    end

    class Result
      attr_accessor :success, :record
      def initialize(success:, record:) = ...
      def success? = success
    end
  end
end
```

Controllers call actions and branch on `result.success?`.

### Card writers

**`Decks::FlatCards`** (`app/actions/decks/flat_cards.rb`) is the only card writer. It serves Basic and Music, whose cards own their content: rows become card columns plus `card_distractors` rows, with no indirection to reconcile. A "row" is a hash of the shape a CSV row or the edit form produces, `{ front:, back:, category:, distractors:, reading:, example_front:, example_back:, source_card_id? }`. Its entry points are `build` / `replace` / `project` / `remove_card` / `front_taken?`, and callers (`Decks::CreateBasic`, `Decks::CreateMusic`, `Decks::Replace`, the `ProjectsCards` concern, `Catalog::CopyDeck`) name it directly.

`replace` matches rows to existing cards by `front`, preserves the progress of any card whose `back` survives unchanged (a changed back zeroes the counters), and carries over `PRESERVED` fields (`reading`, `example_front`, `example_back`) when the CSV omits those columns.

There used to be a second writer behind a `Deck#card_writer` seam, because language decks wrote through `WordLists::Projection` instead. Language content is frozen now — no upload, edit, delete, or re-import — so the seam had one implementation and was removed.

**`WordLists::Projection`** (`app/actions/word_lists/projection.rb`) is what remains of the language write path. It creates nothing in the item graph; both entry points work over content that already exists:
- `build_cards(deck, limit:)` — one card per paired Front item in the deck's word_list. Runs when a deck is created over existing content, i.e. a catalog copy. Unpaired items (accreted decoys) get no card.
- `add_distractor(card, text)` — a wrong guess accretes the guessed text as an unpaired Back item + `ItemDistractor` (never spawns a card). The flat families write `card_distractors` from `Card#record_distractor` instead.

Sibling-deck reconciliation used to live here: forward and reverse decks shared a word list, so every content change had to propagate between them. Writing decks are gone and nothing reshapes an existing word_list's items, so that machinery went with them.

### Authentication

- Custom authentication (no Devise)
- `current_user` helper available in all views
- `current_user.logged_in?` to check authentication status
- Skip authentication on public pages with `skip_before_action :authenticate_user`

### Environment Configuration

Environment variables are managed through `.env` files:

- **`.env.local`** - Development environment variables (not committed to git)
- **`.env.test`** - Test environment variables (committed to git)
- **`.env.example`** - Template showing required variables (committed to git)

Common variables:
- `CREEM_API_KEY` - Creem payment API key
- `CREEM_WEBHOOK_SECRET` - Secret for validating Creem webhooks
- `COMPENDIUM_USERNAME` - Your production admin username; `compendium:push` gives new word lists to this user (`.env.local` only)

**Important:** Never commit `.env.local` or any file containing real API keys.

### Testing

The project uses **RSpec** for automated testing with a comprehensive local testing skill:

- **Test Skill Location:** `.claude/skills/rspec-testing.md`
- **Running Tests:** `bundle exec rspec` or `RAILS_ENV=test bundle exec rspec`
- **Test Organization:** Tests live in `spec/` with subdirectories for models, requests, actions, etc.

**Key Testing Conventions:**
- No `let` blocks - use inline setup
- One assertion per test (avoid linter warnings)
- Use `change_record` matcher for database changes
- WebMock for HTTP requests (don't stub client classes)
- `Llm::Fake` for LLM calls: every example gets a fresh one as `Llm.client` (`llm` in specs); queue answers with `llm.answer(...)` / `llm.fail(...)`, or answer from the prompt with `llm.respond { |call| ... }`, and check `llm.calls`
- Environment variables in `.env.test` (don't stub in specs)
- Create focused, behavior-driven tests

See `.claude/skills/rspec-testing.md` for detailed guidelines and examples.

### JavaScript Testing

The project uses **Vitest** with **jsdom** for JavaScript/TypeScript tests:

- **Running Tests:** `pnpm vitest` (or `pnpm test` which also runs `tscheck` and `eslint`)
- **Config:** `vitest.config.ts`
- **Test Files:** `spec/javascript/**/*_spec.ts`
- **Stimulus Helper:** `spec/javascript/support/stimulus.ts` provides `bootStimulus()` and `getController()`

**Key Conventions:**
- Use `vitest` imports (`describe`, `expect`, `it`, `vi`) — not globals
- Follow the same one-assertion-per-test pattern as RSpec
- Use top-level `describe` blocks per method/behavior (not one nested `describe`)
- Keep describe arrow functions under 50 lines (split into multiple top-level describes)
- Use named helper functions for DOM setup, element lookups, and test data
- `DataTransfer` is not available in jsdom — use `Object.defineProperty` to set `files` on file inputs

**Coverage Thresholds (enforced):**
- 100% branch coverage
- 100% function coverage

**Linting:**
- `pnpm eslint` — strict max-len of 80 chars (`@stylistic`) / 84 chars (base), URLs excluded
- `pnpm stylelint` — for CSS files
- `pnpm tscheck` — TypeScript type checking with `--noEmit`

### Forms

**Use `form_with` for all forms:**
```ruby
form_with(model: deck, class: "deck-form") do |form|
  div(class: "form-field") do
    form.label(:name, "Deck Name", class: "form-label")
    form.text_field(:name, required: true, class: "form-input")
  end

  form.submit("Create Deck", class: "btn-submit")
end
```

### Error Handling

**Display errors with icon and styled container:**
```ruby
errors = deck.errors
if errors.any?
  div(class: "error-explanation") do
    div(class: "error-icon") { "⚠" }
    div(class: "error-content") do
      h2 { "#{pluralize(errors.count, "problem")}:" }
      ul do
        errors.full_messages.each do |message|
          li { message }
        end
      end
    end
  end
end
```

### Animations

**Use subtle, meaningful animations:**
- Fade in on page load
- Staggered animations for lists/grids
- Hover lifts with shadow changes
- Active state "press down" effect
- Respect `prefers-reduced-motion`

```css
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Important Notes

### Deck Catalog

Users can browse and copy public decks at `/catalog`:
- **Browse**: `/catalog` — grid of all public decks (no auth required)
- **Preview**: `/catalog/:id` — card preview (first 5 cards), deck info, and the source the deck's words came from (`Components::DeckTexts`, also on the share-link preview, once a snippet is finished: the source's title, author and license, or "Not included — words only" when its license keeps it from sharing) (no auth required)
- **Texts badge**: a deck whose list has a finished snippet and a shareable source (`Deck#shares_texts?`) gets a 📖 on its catalog grid card
- **Copy**: `POST /catalog/:id/copy` — adds the deck to the current user's account (auth required). A **Basic or Music** deck is duplicated, cards and all. A **language** deck is added *by reference*: the new deck points at the source's `word_list`, and only its cards (the progress anchors) are new — the words themselves are canonical and shared. A `Deck` validation blocks a second deck over the same word_list for one user, so adding twice errors instead of silently duplicating.
- **Try (the demo)**: `POST /catalog/:id/try` → `CatalogController#try` — logged-out visitors and guests get "Try This Deck" on the grid and the preview. It always starts a fresh guest user (`Demo::CreateGuestUser`, capped at `Deck::GUEST_CARD_LIMIT` cards) over the deck and goes to its study page; a guest who tries another deck leaves the old one to the hourly cleanup. `/demo` redirects here.
- Deck visibility is controlled by `deck.visibility` (`"public"` / `"private"`)
- **Admins** publish/unpublish a deck to the catalog from the deck-show page (`Components::CatalogToggleButton` → `CatalogListingsController#create`/`#destroy`, which flips `visibility`). Non-admins have no visibility UI.

### Deck Sharing (revocable link)

Private decks can be shared with a friend via a revocable token. The `decks.share_token` column is nullable and uniquely indexed; presence = link active.
- **Generate / revoke**: owner POSTs to `/decks/:deck_id/share` (sets a fresh `urlsafe_base64(16)` token) or DELETEs to revoke. Both handled by `SharesController#create` / `#destroy`; backed by `Deck#generate_share_token!` / `#revoke_share_token!` / `#shared?` on the model.
- **Public preview**: `GET /shared/:token` → `SharesController#show` renders `Views::Shares::Show` with no auth (`skip_before_action :authenticate_user, only: [:show]`). Attributes the deck to its owner ("shared by [username]"). Returns 404 if the token doesn't match a current deck (revocation just nullifies the column).
- **Add to my decks**: `POST /shared/:token/copy` → `SharesController#copy` reuses `Catalog::CopyDeck` to fork the deck into `current_user`'s account.
- **Try without an account**: `POST /shared/:token/try` → `SharesController#try` spins up a guest user (`Demo::CreateGuestUser`) over the shared deck and redirects into a study session (no auth, like the catalog's Try).
- **Share UI on deck show page** uses a Stimulus `clipboard` controller for copy-to-clipboard on the share-link input.
- Sharing is orthogonal to `visibility` — a `"private"` deck can have a token without being listed in the catalog.

### CSV Import

Decks are created by uploading CSV files. The deck-creation form has a two-way "Deck Type" radio (Basic / Music), with a create action each: `Decks::CreateBasic` and `Decks::CreateMusic`. Both share `Decks::CardsCsv` for parsing and validation, and both land their rows on flat cards via `Decks::FlatCards.build`.

**Language decks are not creatable.** There is no Language option on the form, and anything that still submits `deck_type=language` (a stale form, a hand-rolled POST) falls through to Basic — a freeform front/back CSV is exactly what a Basic deck is for. Language decks arrive only from the catalog. `Decks::CreateLanguage` is gone; `WordLists::Projection.build` is now reached solely through `Catalog::CopyDeck`.

**Text decks (`Decks::CreateBasic`):**
- Required columns: `front`, `back`; optional: `category`, `distractors`, `reading`, `example_front`/`example_back`
- `front` must be unique within the file; multiple `back` answers separated by `;`
- Presence of a `distractors` column sets the deck's `distractor_pool` to `"preset"` (each row must then supply distractors); otherwise it's `"category"`
- `reading` populates the card's (or Front item's) `reading` — the pronunciation gloss shown on reveal; see Reading below

**Music decks (`Decks::CreateMusic`):** see Music Decks section below.

### Music Decks

Microphone-driven music study (target: guitar / ukulele). Public music decks appear in the catalog with a 🎤 badge (rendered via `Components::Base#music_badge`).

**Card data model:**
- `front` = label, **hidden during attempt**, revealed on success (e.g. `"E string, 3rd fret"`)
- `back` = a **single** note matching `MusicCard::NOTE_REGEXP` (`/\A[A-G]#?[1-8]\z/` — sharps only, octaves 1–8, e.g. `C4`, `F#3`), checked by `Decks::CreateMusic` at import
- Multi-note **sequences are formed at study time**, not stored per card — `MusicStudy` windows several cards together (see dispatch below).

**CSV format:** same headers as text decks (`front,back,category`), one note per `back`. The `ordered` flag on the deck (a checkbox on the new-deck form) controls whether study windows are drawn in file order.

**Domain dispatch:** `Study.for(deck:)` returns `MusicStudy` for music decks. `MusicStudy` overrides card selection to build a **window** of `deck.round` cards (consecutive from an anchor if `deck.ordered?`, else the anchor plus random others) and studies them as one note sequence. It answers the whole window (`answer_window`, permitting `card_ids: []`): the JS POSTs the played sequence and the expected value is the cards' `back`s joined with `,`. Progress is bumped per card in the window; the deck moves to the next round when no cards remain not-done — so higher rounds study longer sequences.

**Study UI:** `StudiesController#show`/`#update` dispatches to `Views::Studies::MusicShow`/`MusicUpdate` (vs `Show`/`Update`) when `deck.music?`. The MusicShow view renders `Components::MusicCardBody`, which is the mic-driven widget — Start Microphone gate, Play Reference button, hidden card front, progress counter, and a hidden form the JS POSTs through on completion. Music decks have **no study goal**: the music views show only the round indicator (no session progress bar, goal dialog, or milestone), so practice runs on without a stopping point. `decks.study_goal` still holds a value (NOT NULL) but is unused.

**JS modules** (under `app/javascript/music/`) — pure, framework-free, 100% Vitest coverage:
- `note_utils.ts` — `noteToFrequency("A4") → 440`, `frequencyToNote(440) → {note: "A4", cents: 0}`, `parseSequence("C4,E4,G4") → ["C4", "E4", "G4"]`. Equal-temperament from MIDI; sharps only, no flats.
- `pitch_detector.ts` — `detectPitch(samples, sampleRate, options?) → Hz | null`. Simplified YIN (cumulative-mean-normalized difference function + first-below-threshold + local-min walk). No parabolic interpolation — accuracy is sufficient for the ±50¢ tolerance, and skipping it keeps branch coverage tractable. Defaults: threshold 0.15, search range 60–2000 Hz.
- `reference_player.ts` — `playSequence(ctx, notes, options?) → Promise<void>`. Schedules each note as a sine fundamental + sine partial one octave up so low notes (e.g. guitar E2 = 82 Hz) stay audible on laptop speakers. Uses an injected `AudioContextLike` with **method shorthand** signatures so real DOM `AudioContext` is bivariantly compatible — see the file's eslint-disable comment for why this matters.
- `sequence_session.ts` — `step(state, input) → {state, event}`. Pure state machine that consumes one detected pitch per frame, holds candidate notes for `holdMs` ms before classifying. Tracks an `attemptCount`; when it reaches `notes.length` without completing the sequence, emits `needs_replay` and resets so the controller can re-play the reference. Events: `advanced` / `completed` / `reset` / `needs_replay` / `noop`.

**Stimulus controller:** `app/javascript/controllers/music_study_controller.ts` is the thin glue layer — `getUserMedia`, `AudioContext`, `AnalyserNode`, RAF loop, calling into `sequence_session.step` per frame, and `form.requestSubmit()` on completion. Spec mocks are in `spec/javascript/support/music_study_harness.ts`.

**Mic & audio constraints:**
- `getUserMedia` and `AudioContext` require HTTPS. Rails dev (`bin/dev`) defaults to plain HTTP — use a self-signed cert or staging to actually exercise the mic flow.
- `AudioContext` autoplay policy: create/resume inside a user-gesture handler. The controller honors this by gating creation behind the explicit "Start Microphone" button.

### Reading (pronunciation gloss)

Cards can carry an optional pronunciation/gloss (e.g. Mandarin pinyin) kept separate from `back`. Keeping it out of `back` keeps the multiple-choice options clean — the gloss is revealed with the card rather than baked into every answer string.
- **Data**: `cards.reading` for the flat families; `items.reading` on the Front item for language decks, which `LanguageCard` delegates through. Imported via an optional `reading` CSV column (`Decks::CsvReading`, wired through the create actions / `Decks::Replace` / `Catalog::CopyDeck`) and editable in the card edit form on flat decks (the card view is kept in sync by a `card-reading` turbo-stream replace from `CardsController`).
- **Display**: `Components::CardFront` takes an optional `reading:` and renders `Components::CardReading` *inside* the card-front box, directly under the character, so the two read as one unit. The answer (update) view passes `reading:`, and so does the question view when it re-renders after a passed reading stage (the confirmed reading stays visible while the translation is answered — see Study Algorithm). The initial pre-answer and music views omit it, so nothing shows before answering and the gloss never lands on the distractor options.
- **Study**: the reading also powers the **reading stage** from round 2 up — answer the reading, then the translation (see Study Algorithm). The box border/stripe/shadow live on `.card-front-wrapper` (not the `.card-front` `<h2>`) so the character and reading share one frame. There is no show/hide configuration; a deck that shouldn't show readings simply omits the `reading` column.

### Study Algorithm

The study engine (`app/domain/study.rb`) manages card selection and answer processing:
- **Active window**: the not-done cards (at the current round) capped at `2^(round-1) × 20` — the pool of cards in play grows as the deck moves through rounds. Within it, the first card never viewed (`view_count` 0; card order on flat decks, list order on language decks, where it is the entry's lowest `skill_scores.view_count`) comes first; once every card has been seen, it picks at random
- **Presentation mode**: multiple-choice below round 3, **fuzzy-find** (typed-answer) at round 3+ (`FUZZY_FIND_ROUND`); from round 2 (`READING_ROUND`) up, a card with a `reading` gets a **reading stage** first (see below) — `:reading` (multiple choice) at round 2, `:fuzzy_reading` at 3+. `possible_answers` branches on the mode, and `Components::StudyAnswers` renders it
- **Multiple choice**: 4 distractors + the answer, shuffled. Distractors come from the card's own preset `distractors` (`card_distractors` rows for flat families, `ItemDistractor`s for language); a `"category"`-pool deck tops up from same-category then any sibling cards via `deck.cards_in_category`
- On correct answer: increments `correct_count` and `correct_streak`; if the last not-done card at the round is completed, advances `deck.round`
- On incorrect answer: `Card#record_miss!` resets `correct_streak` and records the wrong guess as a decoy via `record_distractor` — a `card_distractors` row on flat cards, an item-side decoy through `WordLists::Projection.add_distractor` on language cards
- Round advancement happens in `Study#answer_card`, not in the controller

**Reading stage (round 2+)**: on a text deck at round 2 or above, a card with a `reading` is asked in two parts — the reading, then the translation. At round 2 the reading is multiple choice; at round 3+ it is fuzzy find over every distinct reading in the deck (minus homograph twins' readings, as below). The fuzzy matcher ignores tone marks, so tones are only tested when the deck holds readings that differ just by tone. It gates the translation question but never scores it:
- The stage is stateless — answer buttons (and the fuzzy-find form's hidden field) carry `stage: "reading"` in their params and `Study#record_answer` routes those to `answer_reading`
- A **miss** resets `correct_streak` and bumps `view_count`, but does **not** call `add_distractor` (a wrong pinyin pick must not pollute the translation distractor pool); the regular result view renders it
- A **pass** writes nothing; the controller re-renders the question view pinned to the same card (`Study.for(deck:, card_id:)` forces the translation stage, and the confirmed reading stays visible under the character). The translation answer then flows through `answer_card` as usual
- **Multiple-choice decoys (round 2) are computed, not stored**: sibling (front, reading) pairs from `deck.reading_pairs(except:)`, ranked by how close each sibling front's **character count** is to the prompt's — the learner predicts phoneme count by counting the prompt's characters, so a wrong-count option is a free elimination. Two slots prefer siblings that share the prompt's first or last character *and* match its character count exactly (knowing one character's reading then can't eliminate them). Sibling readings equal to the card's own (homophones) are excluded
- Cards without a `reading` skip the stage at every round

### Milestone: Next Deck

When a deck reaches its goal for the day, the milestone's main button moves on to another deck:
- **Next Deck** links to `User#next_unmet_deck` — the first deck in decks-page order (`DeckSection.for`: language sections A–Z by display name, then Basic, then Music, each by deck name) that `Deck.goal_unmet_today` returns, taking each section's `first_unmet` in turn. That query left-joins `Deck#todays_study_day` (a `has_one` scoped to `Date.current`): a deck with no row today counts as unmet, and otherwise its count is compared against the goal by a SQL copy of `StudyDay#study_goal` (keep the two in sync). Decks in no-goal mode and music decks never count as unmet.
- **Reset All Goals** shows instead when every deck has met its goal. It POSTs to `StudyGoalResetsController#create`, which starts a new batch on all the user's decks (`StudyDay#keep_going!`, as Keep Going does) and redirects to the first deck in that order.
- Hidden in demo mode.

### Round Targets

A deck can aim to finish a round by a date, and the daily goal is worked out from it instead of set by hand:
- **Set** in the study-goal dialog (`Components::StudyGoalDialog` → `MilestonesController#update`). It holds three whole forms (`Components::GoalForm`, one per `deck.goal_mode`, each with a hidden `goal_mode` field and a `namespace:` for unique ids; the "none" form has no fields) and a "No goal" / "Daily goal" / "Target date" radio set outside the forms. A `:has()` rule in `edit-card.css` shows the form matching the checked radio, so no JS is involved and the hidden form never submits. The target form's fields are `Components::TargetGoalFields` ("Finish round", "By date", and today's goal with a Recalculate button once a target is saved).
- **Validation**: `target_round` and `target_date` are required in `"target"` mode, and a `before_validation` clears them in the other modes. Their bounds (round ≥ the deck's, date not past) are checked only when they change, so a deck can still move on past its target or outlive its date.
- **Maths** (`Deck#target_goal`): work left = for each round from the current one to the target, the cards below it (`not_done_count`, overridden by `LanguageDeck` to read skill_scores), divided by the days left including today, rounded up. A passed date puts all the work left on today.
- **Saved** on `StudyDay#goal` when today's row is created, and again (with the count reset to 0) by `StudyDay#recalculate!` when the goal mode or target changes or the dialog's "Recalculate" button is pressed.
- **Lowering the goal**: a new batch (the milestone's Keep Going, or Reset All Goals) goes through `StudyDay#keep_going!` instead, which sizes the batch to `Deck#cards_to_lower_goal` — one card per day after today, which always lowers tomorrow's goal (`Deck#next_target_goal`: work left over the days *after* today, rounded up) by one, so every batch is the same size. With no day after today, or less work left than that, the batch is all the work left. The milestone shows "Your daily goal is now N cards" from `next_target_goal`, so each extra batch ends on a visibly lower goal; nothing new is stored.
- **Prompts** (`Components::TargetPrompt`, rendered inside `SessionProgress` on the study page so its buttons can open the goal dialog). Both states are worked out from the deck's columns; nothing is recorded.
  - **Missed** (`Deck#target_missed?`: still active, date before today): "Pick a new date". Saving a new date (or switching to a daily goal) clears it. Until then, today's goal covers all the work left.
  - **Reached** (`Deck#target_reached?`: round past the target round): "Set next target" opens the dialog; "Not now" switches the deck back to its daily goal. A reached target is no longer active, so `StudyDay#study_goal` falls back to the hand-set goal straight away.
- **Not on music decks**: they have no study goal at all (see Music Decks). `MusicDeck` still rejects `goal_mode: "target"` as a guard.

### LLM Client

The content pipeline asks Claude structured questions through `Llm.client.call(model:, system:, prompt:, schema:)`, which returns a hash fitting the JSON schema or raises `Llm::Error`. The client is set per environment: `Llm::ClaudeCli` in development (`config.to_prepare` in `config/environments/development.rb`), `Llm::Fake` in specs (`spec/support/llm.rb`), and none in production, where `Llm.client` raises — production never calls an LLM.
- **`Llm::ClaudeCli`** runs `claude -p` with `--json-schema`, from the temp directory with setting sources off (so no project CLAUDE.md or memory reaches the prompt) and with `ANTHROPIC_API_KEY` removed from its environment (so it bills the subscription, not the API). Its spec drives a stand-in executable, `spec/fixtures/files/fake_claude`; `.env.test` sets a dummy `ANTHROPIC_API_KEY` so the spec can see it removed.

### Snippet Processing

Snippets are added in the app (see `Snippet`) and processed locally with `rails snippets:process`, which asks Claude through `Llm.client` and so only runs in development. It segments every unsegmented sentence (`SnippetSentence.unsegmented`, batches of `SEGMENT_BATCH`), then resolves every sentence still `awaiting_senses?` (batches of `RESOLVE_BATCH`, in snippet and position order so later batches see the senses earlier ones created). A batch holds one language, since its prompts are that language's. Each batch is saved as it finishes, so a run that dies picks up where it stopped. `Snippets::Process` yields a report line per batch (and per sentence sent back to the segmenter), which the task prints.
- **Segment** (`Snippets::Segment`): Sonnet splits each sentence into words under the language's segmentation prompt (`Snippets::Mandarin::Policy::SEGMENTATION` for Mandarin), giving each word's simplified form too (kept on the token as `headword` only where it differs from `text`). The answer is checked mechanically (`SnippetSentence#partitioned_by?`: the words must rejoin to the sentence's word characters (`Language#word_chars`; Han for Mandarin), and each simplified form must be as long as its word); a sentence that fails, or comes back with no words, is asked again on its own, then falls back to the language's pieces (one per character for Mandarin, one per word or punctuation mark for Portuguese). A Portuguese word studies under its own form, lower-cased unless it is a name or a title before one (`headword` must match `text` but for case), and its senses carry no reading (`Language#readings`). The segmenter may mark a word `skip` with one of the language's `Language#skips` (Portuguese: `"name"`, `"foreign"`); a title before a name (D., Sr.) is a word of its own and gets a card; a skipped word gets no sense or card, stays on the token after finishing, and on the Read tab opens a popover saying why ("name", "title in another language"), with no state colour and no lookup recorded. `Segment.call(sentences, feedback:)` passes a complaint about an earlier segmentation along with the sentence and that segmentation's words (`previous`), and the model is told to change only the words the complaint names. `Snippets::Recut` then carries each unchanged token's sense over to the new cut (same text and headword after the same word characters), and resolving asks only about tokens without a sense (`Occurrence.for` skips the rest).
- **Resolve** (`Snippets::Resolve`): every Han token is its own question (`Snippets::Occurrence`), marked 【…】 among its neighbours, so one word can take two senses even within a sentence. They are asked about in slices of `OCCURRENCE_BATCH` through `Snippets::Briefing` (each sentence and word once, for cost). Sonnet decides each (`Snippets::Propose`): an **existing** sense, a **new** one (headword, reading, gloss, and for a Portuguese noun the `article` from `Language#articles` that fits its form, with the gloss leaving out "the"), or **missegmented**. An article outside the language's list is a rejection; whether a word should have one is the judge's call. Only new senses go to Opus (`Snippets::Judge`); `Snippets::Record` writes the result onto the token as `outcome` (`matched` / `created` / `unresolved`) plus `sense_id` or `note`. Tokens without a Han character are left as they are.
- **Escalation ladder** (`Resolve::RUNGS`): Sonnet proposes → Opus judges, then Opus proposes → Opus judges. An occurrence whose proposal did not stand (rejected, or a decision that broke the rules) goes up a rung with the reason in its prompt (`rejection`); still rejected at the top, it is left `unresolved` with that reason.
- **Missegmented tokens**: a sentence with a token called missegmented is segmented again straight away, with the complaints as feedback, and resolved afresh with them in view (the briefing's sentence carries `resegmented`, and the proposer and judge are told not to undo what it asked for); a second complaint leaves the token `unresolved` with its note. The once-only guard is just the inner call's `resegmented:` complaints (`Snippets::Review.resegment` passes the reviewer's), so nothing is stored. `Resolve.call` returns the complaints for the report. Senses the sentence's other tokens created on the first pass stay in the compendium, unused unless a token picks them.
- **Traditional text**: the compendium is keyed by simplified headwords, so an occurrence looks up and creates senses under its token's `headword` (`Occurrence#headword`). The segmenter chooses it with the sentence in view, so a character that simplifies more than one way is settled by meaning (著 as a particle → 着, 乾 "dry" → 干); the judge can still reject a wrong headword. `Briefing` lists a word once per text-and-headword pair (`Occurrence#spelling`). An entry is matched on the reading's letters only, since seed readings carry the HSK syllabus's punctuation.
- Until review strips them, the `outcome` / `note` / `headword` keys (and any word without a `sense_id`) keep a sentence and its snippet `:in_progress`, which blocks `compendium:push`.
- **Review**: `rails snippets:review ID=…` (or without `ID`, every unfinished snippet) prints `Snippets::Report`: a summary line, the source title's and snippet heading's translations (flagged `missing` when unset; they don't block Finish, and are set with a plain `update!`), the unresolved words with their reasons, the senses the snippet created, the skipped words with their reasons, then every sentence token by token with the sentence ids, token indexes and sense ids the edits take; it ends with the compendium's unused senses (no list holds them, no token points at them, such as leftovers from re-segmenting). Token edits are `Snippets::Review` actions, called through `bin/rails runner`:
  - `repoint(sentence, index, sense)` / `add_sense(sentence, index, reading:, gloss:, article: nil)`: give a token a sense (an existing one, or a new one under its headword, made by `Compendium::Edit.add`); either clears the token's note and any skip.
  - `resegment(sentence, feedback)`: segment one sentence again with a complaint and resolve the tokens that changed; tokens it left as they were keep their sense.
  - Edits to senses themselves (fixing wording, deleting leftovers) are `Compendium::Edit`'s; see Compendium Review.
- **Study**: a source with a finished snippet has "Study this list" on `/sources` and its own page (`SourceDecksController#create`), which finds or creates the admin's `ReadingDeck` over the source's word_list (`User#reading_deck_over`) and goes to its study page. Publishing that deck to the catalog (the existing admin toggle) lets others add the list by reference, like any language deck.
- **Share**: a source's "Share" (on its page, once a snippet is finished) goes to `/sources/:id/readers` (`SourceReadersController`), which lists the source's readers and adds one by username (`Sources::Grant`, which also finds or creates their `ReadingDeck` over the list; guests can't be added). Removing a reader takes away the text but leaves their deck and progress.
- **Read**: the study page of a deck whose word_list has snippets shows "Study | Read" radios (`Components::StudyTabs`) and renders every finished snippet the user may read (`Source#readable_by?`: the list's owner and readers let in read them all, and so does anyone else when the source's license is `shareable?` — public domain and CC BY-SA), oldest first, below the study frame (`Components::SnippetReading`: the source's title, author and credit once, then each snippet's heading, when it has one, and paragraphs from `Snippet#paragraphs`: each line as written with its sentences, whose `Snippet::Paragraph#tokens` puts back what falls between the tokens, such as spaces and punctuation the segmenter left out). Each word shows the user's reading `SkillScore` for its sense: grey (`reading-snippet__word--new`) while it has no views, green (`--done`) once its streak reaches the deck's round, and with its reading in a `<ruby>` above it only while its streak is zero (`--new` or `--missed`; the `<rt>` is always rendered and CSS hides the rest). Readings show only in a language with `Language#readings`; Portuguese shows none, and its popovers only the gloss (under a noun with its article, "a casa"). The deck's round sets the spacing: words spaced apart at rounds 1–2 (margins around words in Mandarin, widened spaces in a language written with `Language#spaces`, so a phrase stays tight), and plain running text from round 3. Unfinished and unreadable snippets are left out, and with none left the radios don't show. A `:has()` rule in `flash.css` shows the frame or the text to match the checked radio, so switching keeps both the current card and the reading position; there is no JS and no separate route. Frame requests (each next card) leave the radios and text out, since Turbo keeps only the frame.
- **Look up**: each word on the Read tab is a button that opens a native popover (`popovertarget`) with the word's reading (or a noun with its article) and gloss; the popovers follow their paragraph in the markup and sit under the word via CSS anchor positioning where supported. Every click also POSTs the word's `sense_id` (`lookup_controller.ts`) to `LookupsController#create` (`/decks/:deck_id/lookups`, the user's own deck only), which records a miss on the user's reading `SkillScore` for that sense, so its card comes back in study; the script also marks the word `--missed` on the spot, so its reading shows without a reload. Answers update the Read tab the same way: the answer view (on a language deck) renders `Components::WordStates`, the answered card's senses and their `SkillScore#state`, and `word_states_controller.ts` marks every copy of those words. A new round's "Continue to Round N" loads the whole page, so the Read tab picks up the new round.
- **Finish** (`Snippets::Finish.call(snippet)`, run through `bin/rails runner` once a snippet is reviewed): refuses (`Finish::Unfinished`) while a word that isn't skipped has no `sense_id`; otherwise strips every token to `text` + `sense_id` (+ `skip`) (so the snippet reads `:finished` and can be pushed), appends the snippet's senses to its word_list after the ones it holds (`Snippets::Attach`), and files the list's uncategorized memberships by part of speech in batches of `CATEGORIZE_BATCH` (`Snippets::Categorize`; a row the model leaves out is filed `other`). A list therefore only ever holds reviewed senses. Running it again on a finished snippet only categorizes whatever a failed run left undone.

### Compendium Review

The compendium can be reviewed directly, not only through snippets. Both tools run locally; the results reach production through `compendium:push`. A Claude Code skill, `.claude/skills/compendium-review/SKILL.md`, walks a session through both kinds of review (a processed snippet, or any word), finishing and pushing; keep it in step with the commands here.
- **Look up**: `rails compendium:lookup Q=花` lists every Mandarin entry with that headword or a gloss containing the query (`IN=pt` for Portuguese): each sense with its id, the lists that hold it (with the category there) and how many snippet sentences point at it.
- **Edit** (`Compendium::Edit`, through `bin/rails runner`):
  - `add(language:, headword:, reading:, gloss:, article: nil)`: a sense, under the entry for that reading and article (the reading matched on its letters, as the pipeline does).
  - `revise(sense, gloss:, reading:, article:)`: fix a sense's wording; a new reading or article moves it to the entry that has it.
  - `remove(sense)`: delete a sense, refused (`Edit::Refused`) while any token, list or learner uses it. `revise` and `remove` delete an entry they leave without senses.
  - `attach(sense, word_list, category:)` / `detach(sense, word_list)`: put a sense into a list (after the senses it holds) or take it out.
- **Articles**: an entry is a headword plus its reading and its `article`. A Portuguese noun carries its definite article ("o", "a", "os", "as", matching its gender and number), so *o capital* and *a capital* are two entries and two cards. `Entry#term` ("a casa") is what the card front, the Read-tab popover, `compendium:lookup` and `snippets:review` show.
- Splitting a seed sense that merges two meanings (花 "to spend / flower") is `revise` to narrow it, `add` for the other meaning, `attach` where the new sense belongs, and `Snippets::Review.repoint` for tokens; learners keep their progress on the narrowed sense.
- **Learner data never comes down**, so locally `remove` cannot see progress on a sense and nothing shows what a `revise` changes for learners. The dry-run push is the check: it counts the progress and distractor history any deletes would take.

### Compendium Sync

The compendium tables (`Compendium::TABLES`: entries, senses, sense_examples, word_lists, sense_memberships, sources, snippets, snippet_sentences) move between a local database and production as a **snapshot**: one CSV per table under `tmp/compendium/`, streamed with `COPY`. Users, decks, cards and learner data never leave production. Production carries no sync code; both tasks run locally and fetch production's `DATABASE_URL` from `heroku` each run.
- **`rails compendium:pull`**: refuses if the local compendium differs from what the last pull or push left (`FORCE=true` discards it), then exports production, runs `db:reset`, and loads the snapshot with every word list given to the seed admin. A plain `db:reset` never touches production.
- **`rails compendium:push`**: refuses while any snippet is `:in_progress` (a `:new` one travels untouched), both databases have the same `schema_migrations`, `COMPENDIUM_USERNAME` names a production admin, and production still matches the last pull's checksum. Then it applies the local snapshot to production in one transaction and prints the adds / updates / deletes per table plus the learner data the deletes take (`Apply::LOSSES`: skill_scores, sense_distractors, source_readers). It rolls back unless `DRY_RUN=false`.
- **Owners**: `word_lists.user_id` is never in a snapshot. Apply never changes an existing list's owner, and gives new lists to `COMPENDIUM_USERNAME`.
- **Checksum**: kept under `compendium_checksum` in `ar_internal_metadata`, updated by every pull and committed push.
- **Specs** run Export / Load / Apply / Push against the one test database; only the rake glue in `lib/tasks/compendium.rake` is unspecced.

### Subscription Transparency

**Important:** Subscribers get a single cosmetic perk — a supporter heart (`.supporter-badge`) rendered next to their username via `supporter_badge` on `Components::Base`, gated by `User#supporter?`. The subscription and pricing pages should still emphasize that the main reason to subscribe is to help cover hosting costs, not the badge itself:
- "$5/month" pricing
- Mention the supporter heart as the included perk
- Frame the bigger "why" as supporting the project and hosting costs
- Honest, upfront communication builds trust

### Mobile Responsiveness

All pages must be fully responsive:
- Single column layouts on mobile (< 768px)
- Touch-friendly button sizes (min 44px)
- Readable font sizes (min 16px to prevent zoom)
- Proper viewport meta tags
- Test on small screens regularly

## Development Workflow

### Adding New Pages

1. Create controller action
2. Create Phlex view in `app/views/[controller]/[action].rb`
3. Inherit from `Views::Base`
4. Create dedicated CSS file if needed
5. Add stylesheet to layout if created
6. Add route in `config/routes.rb`

### Styling Guidelines

1. Use existing color variables from `flash.css`
2. Follow the offset shadow pattern for cards
3. Use 3-4px borders, never 1px
4. No rounded corners (border-radius: 0)
5. Add striped accents for visual interest
6. Include hover and active states
7. Mobile breakpoints at 768px and 1024px
8. Test with real content, not lorem ipsum
9. **Button-styled links must include `:visited` in their selector** - The global `a:visited` rule in `application.css` overrides text color on visited links. Any `<a>` styled as a button needs `.btn-foo, .btn-foo:visited { color: ...; }` to prevent low-contrast text after the link has been visited.

### UI/UX Testing Checklist

Manual testing checklist for new features:

- [ ] Works on mobile (< 768px width)
- [ ] Works on tablet (768-1024px)
- [ ] Keyboard navigation works
- [ ] Focus states visible
- [ ] Animations respect prefers-reduced-motion
- [ ] Colors have sufficient contrast
- [ ] Works with long content/names
- [ ] Empty states handled gracefully
- [ ] Automated tests written (see Testing section above)

## Contact & Support

- Support email: support+flash@boon.gl
- GitHub: https://github.com/mockdeep/flash

## Future Considerations

Things to keep in mind for future development:

1. **Subscription Features** - If adding paid features, update subscription messaging
2. **Catalog Enhancements** - search/filter, categories, self-serve (non-admin) publishing
3. **Mobile App** - Progressive Web App (a manifest + service worker are already served at `/manifest` and `/service-worker`)
4. **Bulk Operations** - Edit/delete multiple cards at once
5. **Study Statistics** - More detailed progress tracking and visualizations
6. **Accessibility** - Continue improving screen reader support
7. **Internationalization** - Multi-language support for UI (not just study content)
8. **Language skill tabs** - The decks index groups by language; once writing decks exist, a language section will tab its decks by skill (Reading / Writing)

## Resources

- Phlex Documentation: https://www.phlex.fun/
- Rails Guides: https://guides.rubyonrails.org/
- Creem Docs: https://docs.creem.io/

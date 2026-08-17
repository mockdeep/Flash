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
- `accent-box.css` - `.accent-box` callouts (level-complete, milestones, empty states)
- `application.css` - Base styles, resets, common patterns, global `a:visited`
- `auth.css` - Authentication pages (sign in / account)
- `button.css` - `.button` base and variants (`button_class` modifiers: compact / primary / ghost / secondary / danger / disabled)
- `card.css` - Generic `.card` container pattern
- `catalog.css` - Public deck catalog + preview (`.catalog-show-*` reused by the share-link preview at `/shared/:token`)
- `custom.css` - Scratch space for ad-hoc overrides
- `decks.css` - Deck listing, deck form, and deck-show page (incl. `.deck-share-*` block)
- `demo-banner.css` - Demo-mode banner
- `dialog.css` - Modal dialog component styles (`.dialog`, `.dialog__header`, etc.)
- `edit-card.css` - Edit card trigger button and form layout within the dialog
- `flash.css` - Study/flashcard core (card front + kebab menu, answers grid, `.card-reading`)
- `layout.css` - Header, footer, navigation
- `music-study.css` - Mic-driven music study UI
- `price-display.css` - `.price-display` component
- `pricing.css` - Pricing page
- `subscription.css` - Subscription page
- `welcome.css` - Landing page styles

**Key Principles:**
- Separate CSS files per major section
- Include all stylesheets in layout
- Avoid inline styles
- Use CSS custom properties (variables) for colors
- Mobile-first responsive design with media queries

### Data Model

**Two content models, one card table.** Basic and Music decks are **flat**: the card owns its content (`front`, `back`, `category`, `reading`, `example_front`, `example_back`) and its progress counters directly, with `card_distractors` rows for decoys. Language decks still keep content in a shared, neutral **data set** of items and pairings — `LanguageCard` overrides the column readers to go through its `item`. `Deck#flat_cards?` is the switch between them, and `Deck#card_writer` selects the matching write path (`Decks::FlatCards` vs `DataSets::Projection`). The language side is slated to leave the item layer too, at which point the data_set machinery goes away entirely.

**Core Models:**
- `User` - Authentication. Has `username` (unique, `/\A[a-zA-Z0-9_.]+\z/` — letters, digits, `_`, `.`), `role` (`"user"` / `"admin"` / `"guest"`), `study_goal`, `time_zone`. `has_many :data_sets`, `has_many :decks` (**direct** — every deck carries `user_id`), `has_many :topics`, `has_one :subscription`.
- `DataSet` (STI base) - A set of language study content, reusable across decks. `belongs_to :user`, `has_many :items`, `has_many :decks`. `name` unique per user. `LanguageDataSet` is the **only** subclass — Basic and Music left this layer for flat cards, so "data set" now means "language content".
- `Topic` - User-created container grouping **decks** (e.g. "Mandarin", "Music") so related decks collect together on the decks index. `name` unique per user; destroying a topic nullifies its decks. Assigned per deck from the deck show page (type-or-pick datalist input → `TopicAssignmentsController`, `find_or_create_by` name).
- `Item` - One neutral term. Has `side` (`"Front"` / `"Back"`), `text`, and (Front-side) `category`, `reading`, `example`, `paired_example`. Belongs to a data set; unique on `[data_set_id, side, text]`. Front↔back meaning is expressed through `Pairing`; distractor candidates through `ItemDistractor`. `#glosses` returns the paired Back texts in authored order.
- `Pairing` - Join between a Front `item` and a Back `paired_item` (one row per gloss).
- `ItemDistractor` - Join marking a Back item as a preset distractor for a Front `item`. The language-side counterpart of `CardDistractor`.
- `CardDistractor` - A wrong-answer option owned directly by a flat card (uploaded presets and remembered study misses). Unique on `[card_id, text]`.
- `Deck` (STI base) - A study form. `belongs_to :user`, `belongs_to :topic` (optional), and `belongs_to :data_set` — required *unless* `flat_cards?`, forbidden *if* it is (the presence/absence pair is what keeps the two content models apart). Flat families own a `name` column (unique per user); language decks delegate `name` to the data_set, and the `ordered` scope COALESCEs the two. Has `visibility` (`"public"` / `"private"`), `level` (default 1, current study level), `distractor_pool` (`"category"` / `"preset"` / `"none"`, NOT NULL — set by the importer), `ordered`, `study_goal`, `last_studied_at`, and nullable `share_token`.
- `Card` (STI base) - `belongs_to :deck`, `belongs_to :item` (nullable — flat cards have none), `belongs_to :source_card` (catalog-copy provenance). `has_many :card_distractors`. Owns the content columns and the progress counters (`correct_count`, `correct_streak`, `view_count`), and holds the score handle (`record_correct!`, `record_miss!`, `record_view!`). `normalizes :back` is the single back-joining rule. Unique on `[deck_id, front]` where `front` is present.
- `Subscription` - Payment/subscription info, belongs to user.

**DataSet STI:** `LanguageDataSet` is the only subclass. It requires a `language` code; `LANGUAGES` (on this class) maps every individual ISO 639-2 language to its display name, keyed by shortest available code per BCP 47 ("zh", not "zho"; "tlh" works). Nothing in the app creates one any more — the deck form has no Language option — so the validation guards what the seed account and catalog copies carry.

**Deck/Card STI subclasses** (deck class names match their UI representation — the future topic-page tabs). Both hierarchies have an abstract language intermediate:
- `LanguageDeck < Deck` / `LanguageCard < Card` — never instantiated. `LanguageDeck` delegates `name` and `language` to the data_set, points `card_writer` at `DataSets::Projection`, holds `mandarin?` and `hanzi_chars` (font features), and overrides `cards_in_category` / `reading_pairs` to join through items. `LanguageCard` overrides the content readers to read its `item`, requires one, and records a miss as an item-side decoy rather than a `card_distractors` row. The base `Deck#mandarin?` is `false`.
- `ReadingDeck < LanguageDeck` / `ReadingCard < LanguageCard` — forward study: multiple-choice (or fuzzy-find) recognition.
- `BasicDeck < Deck` / `BasicCard < Card` — plain forward flashcards on flat cards.
- `MusicDeck < Deck` / `MusicCard < Card` — microphone-driven music study on flat cards. Each `MusicCard.back` is a **single** note matching `MusicCard::NOTE_REGEXP` (e.g. `C4`, `F#3`), enforced by `Decks::CreateMusic` at import rather than by a model validation; sequences are formed at study time by windowing (see Music Decks). `MusicDeck` defaults `distractor_pool` to `"none"`.

`BasicDeck` and `MusicDeck` answer `flat_cards?` true. `BasicDeck` alone is `replaceable?` (CSV re-import). Card classes mirror the deck classes one-to-one; each deck declares its card class via `card_type` (no base-class default). Behavior lives on the two abstract intermediates; `ReadingCard`, `BasicCard`, and `MusicCard` exist for naming symmetry. In specs there is no `:card` factory — create cards through `:basic_card` / `:reading_card` / `:music_card`, and note that the `:deck` factory builds a `BasicDeck`.

**STI convention — `model_name` override:** each direct subclass of `Deck` / `Card` overrides `self.model_name` to return the parent's, so `form_with(model: reading_deck)` keeps routing to `decks_path` (not `reading_decks_path`). `LanguageDeck` and `LanguageCard` carry it for their own subclasses, which inherit it. Apply this to any new STI subclass of the base.

**`belongs_to` is optional by default** (`config.active_record.belongs_to_required_by_default = false`), so required associations are stated explicitly. `Topic` marks `user` with `optional: false`; `Deck` and `Card` use validations instead — `validates :deck_id, presence: true` on `Card`, `validates :item, presence: true` on `LanguageCard`, and the `data_set` presence/absence pair on `Deck` — backed by NOT NULL columns where the requirement is absolute.

**Card Progress:**
- A card is "done" at the current level when `correct_streak >= deck.level`
- Wrong answers reset `correct_streak` to 0
- When all cards in a deck are done, the deck advances to the next level
- Level N requires N correct answers in a row per card
- Streaks are cumulative across levels (no reset on level-up)
- The `Card` model's `.done(level)` and `.not_done(level)` scopes require a level argument

### Keyboard Hotkeys

The app uses a **Stimulus hotkeys controller** (`app/javascript/controllers/hotkeys_controller.ts`) for keyboard shortcuts. It listens for `keydown` events at the document level and clicks the matching target element.

**Adding a hotkey to any element:**
```ruby
data = { hotkeys_target: "click", hotkey: "a" }
link_to("My Link", some_path, data:)
```

**Current shortcuts:**
- `1`-`5` - Select answer during study
- `Space` - Next card after answering
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

## Important Conventions

### File Organization

```
app/
├── actions/                      # Service objects (`.call` → Result); see Actions below
│   ├── catalog/
│   │   └── copy_deck.rb          # Duplicates a public deck into a user's account
│   ├── creem/
│   │   ├── cancel_subscription.rb
│   │   ├── client.rb             # Creem HTTP client
│   │   └── create_checkout.rb    # Creates a Creem checkout session
│   ├── data_sets/
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
│   └── demo/
│       ├── cleanup_guest_users.rb # Removes expired demo guest users
│       └── create_guest_user.rb   # Creates a temporary guest user for the demo
├── components/                   # Phlex view components
│   ├── base.rb                   # Base component (supporter_badge / music_badge / catalog_badge)
│   ├── card_front.rb             # Study card-front box + kebab menu; renders the reading gloss inside it
│   ├── card_menu.rb              # Card-front kebab menu (study text sizes, edit/delete actions)
│   ├── card_preview.rb           # 5-card preview block (shared by catalog and share preview)
│   ├── card_reading.rb           # Pronunciation/pinyin gloss (rendered inside CardFront on reveal)
│   ├── catalog_toggle_button.rb  # Publish / unpublish a deck to the public catalog
│   ├── demo_banner.rb            # Demo-mode banner
│   ├── error_explanation.rb      # Styled validation-error box
│   ├── fuzzy_find_answers.rb     # Typed-answer input for fuzzy-find mode (level 3+)
│   ├── level_progress.rb         # Deck level indicator (LEVELS = 3)
│   ├── music_card_body.rb        # Mic-driven music study widget
│   ├── music_csv_instructions.rb # CSV format help block for music decks
│   ├── replace_cards_dialog.rb   # Confirm dialog for re-importing a deck's cards
│   ├── session_milestone.rb      # Study milestone prompt (daily goal reached)
│   ├── session_progress.rb       # Study session progress bar
│   ├── study_example.rb          # Optional example sentence on the answer view
│   ├── study_goal_dialog.rb      # Edit daily study-goal dialog
│   └── text_csv_instructions.rb  # CSV format help block for text decks
├── domain/
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
│   ├── catalog_controller.rb          # Public catalog browse / preview / copy
│   ├── catalog_listings_controller.rb # Publish / unpublish a deck to the catalog
│   ├── concerns/
│   │   ├── demo_session.rb            # Demo guest-session helpers
│   │   └── projects_cards.rb          # save_card/destroy_card → deck.card_writer (flat decks only)
│   ├── decks_controller.rb            # `#create` dispatches CreateMusic vs CreateBasic on :deck_type
│   ├── demo_controller.rb             # Starts a guest demo study session
│   ├── milestones_controller.rb       # Updates a deck's study goal
│   ├── pages_controller.rb            # pricing / privacy / terms
│   ├── replacements_controller.rb     # Re-import a deck's cards (Decks::Replace)
│   ├── sessions_controller.rb         # Login / logout
│   ├── shares_controller.rb           # Owner toggle (via :deck_id) + public preview/copy/try (via :token)
│   ├── studies_controller.rb          # Study show/update; dispatches text vs music views
│   ├── subscriptions_controller.rb    # Creem subscription show / create / destroy
│   ├── topic_assignments_controller.rb # Assign/release a deck to a topic
│   ├── webhooks/
│   │   └── creem_controller.rb        # Creem webhook receiver
│   └── welcome_controller.rb          # Landing page
├── models/
│   ├── application_record.rb
│   ├── user.rb              # has_many :data_sets, :decks (direct), :topics; has_one :subscription
│   ├── data_set.rb          # STI base — language content set; LanguageDataSet is the only subclass
│   ├── language_data_set.rb # STI subclass — requires language; LANGUAGES lookup
│   ├── topic.rb            # User-created container grouping decks
│   ├── item.rb             # Neutral term (side/text + Front-side metadata); glosses/distractors
│   ├── pairing.rb          # Front item ↔ Back paired_item join
│   ├── item_distractor.rb  # Front item ↔ Back distractor_item join (language decoys)
│   ├── card_distractor.rb  # Card-owned decoy text (flat-card decoys)
│   ├── deck.rb             # STI base — user/topic/data_set; flat_cards?/card_writer
│   ├── language_deck.rb    # Abstract parent of the item-backed decks — mandarin?/hanzi_chars
│   ├── reading_deck.rb     # STI subclass — forward language study
│   ├── basic_deck.rb       # STI subclass — plain flashcards on flat cards; replaceable
│   ├── music_deck.rb       # STI subclass — flat cards; defaults distractor_pool to "none"
│   ├── card.rb             # STI base — owns content columns + progress counters + score handle
│   ├── language_card.rb    # Abstract parent of the item-backed cards — content read from item
│   ├── basic_card.rb       # STI subclass — overrides model_name only
│   ├── reading_card.rb     # STI subclass — no behavior of its own
│   ├── music_card.rb       # STI subclass — NOTE_REGEXP (single note)
│   └── subscription.rb
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
│   │   ├── index.rb          # Public deck grid (mic badge for music decks)
│   │   └── show.rb           # Deck preview + copy action (mic badge in header)
│   ├── decks/
│   │   ├── index.rb          # Decks grouped into topic sections + "Other Decks"
│   │   ├── new.rb            # Three-way deck-type radio + language select
│   │   ├── show.rb           # Share-link, topic assignment, replace link, cards table
│   │   └── replacements/
│   │       └── new.rb        # Re-import (replace) a deck's cards form
│   ├── demo/
│   │   └── show.rb
│   ├── pages/
│   │   ├── pricing.rb
│   │   ├── privacy.rb
│   │   └── terms.rb
│   ├── sessions/
│   │   └── new.rb
│   ├── shares/
│   │   └── show.rb           # Public share-link preview (attributed to owner)
│   ├── studies/
│   │   ├── show.rb           # Text-deck study prompt (multiple-choice / fuzzy-find)
│   │   ├── update.rb         # Text-deck answer result (renders CardReading + StudyExample)
│   │   ├── music_show.rb     # Mic-driven music study prompt
│   │   ├── music_update.rb   # Music answer result
│   │   └── study_frame_data.rb # Shared study-frame data helper (wires the text-size controller)
│   ├── subscriptions/
│   │   └── show.rb
│   └── welcome/
│       └── index.rb
├── javascript/
│   ├── application.ts
│   ├── channels/
│   │   └── consumer.ts
│   ├── helpers/
│   │   └── assert.ts                 # `assert` / `ensure` runtime guard
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
│   │   ├── mobile_nav_controller.ts
│   │   ├── music_study_controller.ts # Mic capture + RAF loop + sequence-state-machine glue
│   │   ├── music_study_helpers.ts    # Helpers for music_study_controller
│   │   ├── text_size_controller.ts   # Study text-size kebab menu (persists to localStorage)
│   │   └── timezone_controller.ts    # Sets the browser time zone on a hidden field
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
        └── welcome.css

db/
├── seeds.rb             # Entry point (loads db/seeds/*)
└── seeds/
    └── music_decks.rb   # Seeds starter music decks
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

Two writers exist, and a deck picks between them with `Deck#card_writer`. Both consume the same "row": a hash of the shape a CSV row or the edit form produces, `{ front:, back:, category:, distractors:, reading:, example_front:, example_back:, source_card_id? }`. Callers (`Decks::Replace`, the `ProjectsCards` controller concern, `Catalog::CopyDeck`) go through `deck.card_writer` and never name a writer directly.

`build` is the only entry point both share. `replace` / `project` / `remove_card` / `front_taken?` are **flat-only**: language decks support neither per-card editing nor CSV re-import, so `CardsController` and `ReplacementsController` turn them away, the study view hides the edit button, and `ReadingDeck` is no longer `replaceable?`. Once a language deck exists, the only thing that still touches its content is a miss-recorded decoy.

**`Decks::FlatCards`** (`app/actions/decks/flat_cards.rb`) — the writer for Basic and Music. Rows become card columns plus `card_distractors` rows; there is no indirection to reconcile. `replace` matches rows to existing cards by `front`, preserves the progress of any card whose `back` survives unchanged (a changed back zeroes the counters), and carries over `PRESERVED` fields (`reading`, `example_front`, `example_back`) when the CSV omits those columns.

**`DataSets::Projection`** (`app/actions/data_sets/projection.rb`) — the writer for language decks. It translates rows into the item/pairing/distractor graph plus the thin cards that anchor to it; items are the source of truth and the card is just `item_id` + progress. Two entry points remain:
- `build(deck, rows)` — reached only from `Catalog::CopyDeck`, the last thing that creates language content.
- `add_distractor(card, text)` — a wrong guess accretes the guessed text as an unpaired decoy item + `ItemDistractor` (never spawns a card). The flat families write `card_distractors` from `Card#record_distractor` instead.

Sibling-deck reconciliation used to live here: forward and reverse decks shared a data set, so every content change had to propagate between them. Writing decks are gone and nothing reshapes an existing data_set's items, so that machinery went with them.

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
- **Preview**: `/catalog/:id` — card preview (first 5 cards), deck info (no auth required)
- **Copy**: `POST /catalog/:id/copy` — duplicates deck + cards into current user's account (auth required)
- Deck visibility is controlled by `deck.visibility` (`"public"` / `"private"`)
- **Admins** publish/unpublish a deck to the catalog from the deck-show page (`Components::CatalogToggleButton` → `CatalogListingsController#create`/`#destroy`, which flips `visibility`). Non-admins have no visibility UI.

### Deck Sharing (revocable link)

Private decks can be shared with a friend via a revocable token. The `decks.share_token` column is nullable and uniquely indexed; presence = link active.
- **Generate / revoke**: owner POSTs to `/decks/:deck_id/share` (sets a fresh `urlsafe_base64(16)` token) or DELETEs to revoke. Both handled by `SharesController#create` / `#destroy`; backed by `Deck#generate_share_token!` / `#revoke_share_token!` / `#shared?` on the model.
- **Public preview**: `GET /shared/:token` → `SharesController#show` renders `Views::Shares::Show` with no auth (`skip_before_action :authenticate_user, only: [:show]`). Attributes the deck to its owner ("shared by [username]"). Returns 404 if the token doesn't match a current deck (revocation just nullifies the column).
- **Add to my decks**: `POST /shared/:token/copy` → `SharesController#copy` reuses `Catalog::CopyDeck` to fork the deck into `current_user`'s account.
- **Try without an account**: `POST /shared/:token/try` → `SharesController#try` spins up a guest user (`Demo::CreateGuestUser`) over the shared deck and redirects into a study session (no auth, like the demo).
- **Share UI on deck show page** uses a Stimulus `clipboard` controller for copy-to-clipboard on the share-link input.
- Sharing is orthogonal to `visibility` — a `"private"` deck can have a token without being listed in the catalog.

### CSV Import

Decks are created by uploading CSV files. The deck-creation form has a two-way "Deck Type" radio (Basic / Music), with a create action each: `Decks::CreateBasic` and `Decks::CreateMusic`. Both share `Decks::CardsCsv` for parsing and validation, and both land their rows on flat cards via `Decks::FlatCards.build`.

**Language decks are not creatable.** There is no Language option on the form, and anything that still submits `deck_type=language` (a stale form, a hand-rolled POST) falls through to Basic — a freeform front/back CSV is exactly what a Basic deck is for. Language decks arrive only from the catalog. `Decks::CreateLanguage` is gone; `DataSets::Projection.build` is now reached solely through `Catalog::CopyDeck`.

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

**Domain dispatch:** `Study.for(deck:)` returns `MusicStudy` for music decks. `MusicStudy` overrides card selection to build a **window** of `deck.level` cards (consecutive from an anchor if `deck.ordered?`, else the anchor plus random others) and studies them as one note sequence. It answers the whole window (`answer_window`, permitting `card_ids: []`): the JS POSTs the played sequence and the expected value is the cards' `back`s joined with `,`. Progress is bumped per card in the window; the deck levels up when no cards remain not-done — so higher levels study longer sequences.

**Study UI:** `StudiesController#show`/`#update` dispatches to `Views::Studies::MusicShow`/`MusicUpdate` (vs `Show`/`Update`) when `deck.music?`. The MusicShow view renders `Components::MusicCardBody`, which is the mic-driven widget — Start Microphone gate, Play Reference button, hidden card front, progress counter, and a hidden form the JS POSTs through on completion.

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
- **Study**: the reading also powers the level-2 **reading stage** — pick the reading, then the translation (see Study Algorithm). The box border/stripe/shadow live on `.card-front-wrapper` (not the `.card-front` `<h2>`) so the character and reading share one frame. There is no show/hide configuration; a deck that shouldn't show readings simply omits the `reading` column.

### Study Algorithm

The study engine (`app/domain/study.rb`) manages card selection and answer processing:
- **Active window**: picks randomly from the not-done cards (at the current level) capped at `2^(level-1) × 20` — the pool of cards in play grows as the deck levels up
- **Presentation mode**: multiple-choice below level 3, **fuzzy-find** (typed-answer) at level 3+ (`FUZZY_FIND_LEVEL`); at level 2 (`READING_LEVEL`) a card with a `reading` on a forward deck gets a **reading stage** first (see below). `possible_answers` branches on the mode
- **Multiple choice**: 4 distractors + the answer, shuffled. Distractors come from the card's own preset `distractors` (`card_distractors` rows for flat families, `ItemDistractor`s for language); a `"category"`-pool deck tops up from same-category then any sibling cards via `deck.cards_in_category`
- On correct answer: increments `correct_count` and `correct_streak`; if the last not-done card at the level is completed, advances `deck.level`
- On incorrect answer: `Card#record_miss!` resets `correct_streak` and records the wrong guess as a decoy via `record_distractor` — a `card_distractors` row on flat cards, an item-side decoy through `DataSets::Projection.add_distractor` on language cards
- Level advancement happens in `Study#answer_card`, not in the controller

**Reading stage (level 2)**: on a forward text deck at level 2, a card with a `reading` is asked in two parts — pick the reading (multiple choice), then pick the translation. It gates the translation question but never scores it:
- The stage is stateless — answer buttons carry `stage: "reading"` in their params and `Study#record_answer` routes those to `answer_reading`
- A **miss** resets `correct_streak` and bumps `view_count`, but does **not** call `add_distractor` (a wrong pinyin pick must not pollute the translation distractor pool); the regular result view renders it
- A **pass** writes nothing; the controller re-renders the question view pinned to the same card (`Study.for(deck:, card_id:)` forces the translation stage, and the confirmed reading stays visible under the character). The translation answer then flows through `answer_card` as usual
- **Decoys are computed, not stored**: sibling (front, reading) pairs from `deck.reading_pairs(except:)`, ranked by how close each sibling front's **character count** is to the prompt's — the learner predicts phoneme count by counting the prompt's characters, so a wrong-count option is a free elimination. Two slots prefer siblings that share the prompt's first or last character *and* match its character count exactly (knowing one character's reading then can't eliminate them). Sibling readings equal to the card's own (homophones) are excluded
- Cards without a `reading` behave exactly as before, even at level 2

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
8. **Topic pages** - The decks index groups by topic; a topic show page with per-deck-type tabs is the planned next step, then Card STI renames to match the deck names (see NOTES.md)

## Resources

- Phlex Documentation: https://www.phlex.fun/
- Rails Guides: https://guides.rubyonrails.org/
- Creem Docs: https://docs.creem.io/

# Flash - Project Documentation

## Maintenance

When adding new features, controllers, actions, views, or CSS files, update the relevant sections of this file (file tree, data model, CSS organization, important notes, etc.) to keep it accurate.

## Overview

Flash is a flashcard study application built with Ruby on Rails that uses spaced repetition to help users learn and retain information. The app features a distinctive "Terminal Scholar" design aesthetic and uses Phlex for view rendering instead of ERB.

**Tech Stack:**
- Ruby on Rails 8.1.1
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

**CSS Organization:**
- `application.css` - Base styles, resets, common patterns
- `catalog.css` - Public deck catalog browsing and preview
- `decks.css` - Deck listing and form styles
- `dialog.css` - Modal dialog component styles (`.dialog`, `.dialog__header`, etc.)
- `edit-card.css` - Edit card trigger button and form layout within the dialog
- `flash.css` - Study/flashcard specific styles (the core app)
- `layout.css` - Header, footer, navigation
- `welcome.css` - Landing page styles

**Key Principles:**
- Separate CSS files per major section
- Include all stylesheets in layout
- Avoid inline styles
- Use CSS custom properties (variables) for colors
- Mobile-first responsive design with media queries

### Data Model

**Core Models:**
- `User` - Authentication, has many decks. Has `username` (unique, alphanumeric + underscores)
- `Deck` (STI base) - Collection of flashcards, belongs to user. Has `visibility` (`"public"`, `"private"`, `"demo"`), `level` (default 1, current study level), `distractor_pool` (`"category"`, `"preset"`, or `"none"`).
- `Card` (STI base) - Individual flashcard, belongs to deck
- `Subscription` - Payment/subscription info, belongs to user

**STI subclasses:**
- `TextDeck < Deck` / `TextCard < Card` — the original "question/answer" flashcard flow with multiple-choice study. Validates `back` and `category` presence.
- `MusicDeck < Deck` / `MusicCard < Card` — microphone-driven music study. `MusicCard` validates `back` against `MusicCard::SEQUENCE_REGEXP` (note sequences like `E3` or `C4,E4,G4`). `MusicDeck` defaults `distractor_pool` to `"none"`.

**STI convention — `model_name` override:** every Deck/Card subclass overrides `self.model_name` to return the parent's so `form_with(model: text_deck)` keeps routing to `decks_path` (not `text_decks_path`). Apply this to any new STI subclass.

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
├── actions/             # Service objects for complex operations
│   ├── catalog/
│   │   └── copy_deck.rb     # Duplicates a public deck into a user's account
│   ├── decks/
│   │   ├── create.rb        # Text deck CSV import
│   │   └── create_music.rb  # Music deck CSV import (note-sequence backs)
│   └── creem/
│       ├── cancel_subscription.rb
│       └── client.rb
├── components/
│   ├── base.rb                    # Base component (supporter_badge, music_badge helpers)
│   └── music_csv_instructions.rb  # CSV format help block for music decks
├── domain/
│   ├── study.rb         # Study engine; `Study.for(deck:)` dispatches by deck type
│   └── music_study.rb   # MusicStudy < Study; overrides `possible_answers` to []
├── controllers/
│   ├── application_controller.rb
│   ├── cards_controller.rb
│   ├── catalog_controller.rb
│   ├── decks_controller.rb     # `#create` dispatches Decks::Create vs Decks::CreateMusic on :deck_type
│   ├── pages_controller.rb
│   └── subscriptions_controller.rb
├── models/
│   ├── user.rb
│   ├── deck.rb          # STI base
│   ├── text_deck.rb     # STI subclass — overrides model_name
│   ├── music_deck.rb    # STI subclass — defaults distractor_pool to "none"
│   ├── card.rb          # STI base
│   ├── text_card.rb     # STI subclass — validates back + category presence
│   ├── music_card.rb    # STI subclass — validates back against SEQUENCE_REGEXP
│   └── subscription.rb
├── views/
│   ├── base.rb           # Base view class
│   ├── layouts/
│   │   └── application.rb
│   ├── catalog/
│   │   ├── index.rb      # Public deck grid (mic badge for music decks)
│   │   └── show.rb       # Deck preview + copy action (mic badge in header)
│   ├── welcome/
│   │   └── index.rb
│   ├── decks/
│   │   ├── index.rb
│   │   ├── new.rb        # Includes deck-type toggle (text vs music)
│   │   └── show.rb
│   ├── pages/
│   │   ├── privacy.rb
│   │   └── terms.rb
│   ├── cards/
│   │   └── edit_form.rb
│   ├── studies/
│   │   ├── show.rb
│   │   └── update.rb
│   └── subscriptions/
│       └── show.rb
├── javascript/
│   ├── controllers/
│   │   ├── deck_type_controller.ts  # Toggles CSV instructions block on creation form
│   │   ├── dialog_controller.ts
│   │   ├── file_upload_controller.ts
│   │   ├── hotkeys_controller.ts
│   │   └── mobile_nav_controller.ts
│   └── music/
│       ├── note_utils.ts        # Note ↔ frequency, sequence parsing
│       ├── pitch_detector.ts    # YIN-style pitch detection from Float32Array samples
│       └── reference_player.ts  # Web Audio sine playback for note sequences
└── assets/
    └── stylesheets/
        ├── application.css
        ├── catalog.css
        ├── dialog.css
        ├── edit-card.css
        ├── flash.css
        ├── layout.css
        ├── welcome.css
        └── decks.css

db/
└── seeds/
    └── music_decks.rb   # Seeds starter music decks (called from db/seeds.rb)
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
- `SAMPLE_CSV_URL` - URL to sample CSV file for deck import

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
- Visibility is currently set via Rails console; there is no UI for changing it yet

### CSV Import

Decks are created by uploading CSV files. The deck-creation form has a "Deck Type" toggle (text vs music) that picks the importer.

**Text decks (`Decks::Create`):**
- Columns: `front`, `back`, `category` (`distractors` optional)
- Multiple answers separated by `;`
- Sample CSV available via environment variable `SAMPLE_CSV_URL`

**Music decks (`Decks::CreateMusic`):** see Music Decks section below.

### Music Decks

Microphone-driven music study (target: guitar / ukulele). Public music decks appear in the catalog with a 🎤 badge (rendered via `Components::Base#music_badge`).

**Card data model:**
- `front` = label, **hidden during attempt**, revealed on success (e.g. `"C Major Chord"`)
- `back` = comma-separated note sequence — both played as the audio reference and what the user must play back (e.g. `"C4,E4,G4"`). Validated against `MusicCard::SEQUENCE_REGEXP` (sharps only, octaves 1–8).

**CSV format:** same headers as text decks (`front,back,category`). Multi-note backs **must be quoted** (`"C4,E4,G4"`) so commas don't split the cell. Music CSVs reject space-separated notes — the format is one canonical comma-only shape.

**Domain dispatch:** `Study.for(deck:)` returns `MusicStudy` for music decks (overrides `possible_answers` to `[]`). The base `Study#answer_card` works for music as-is — the JS POSTs `answer = card.back` so the existing `card.back == answer` comparison is the right check.

**Study UI:** the in-browser music-study experience (mic capture, sequence state machine, Phlex view) is on its own track and not yet shipped. Currently `StudiesController` renders the text study view for all deck types; music decks exist in the catalog and creation flow but the play experience for them is not wired up yet.

**JS modules** (under `app/javascript/music/`) — pure, framework-free, 100% Vitest coverage:
- `note_utils.ts` — `noteToFrequency("A4") → 440`, `frequencyToNote(440) → {note: "A4", cents: 0}`, `parseSequence("C4,E4,G4") → ["C4", "E4", "G4"]`. Equal-temperament from MIDI; sharps only, no flats.
- `pitch_detector.ts` — `detectPitch(samples, sampleRate, options?) → Hz | null`. Simplified YIN (cumulative-mean-normalized difference function + first-below-threshold + local-min walk). No parabolic interpolation — accuracy is sufficient for the ±50¢ tolerance, and skipping it keeps branch coverage tractable. Defaults: threshold 0.15, search range 60–2000 Hz.
- `reference_player.ts` — `playSequence(ctx, notes, options?) → Promise<void>`. Schedules sine oscillators on an injected `AudioContextLike` (narrow structural interface so jsdom mocks satisfy the type without `as` casts). Defaults: 500ms note + 100ms gap.

**Mic & audio constraints (for the upcoming Stimulus integration):**
- `getUserMedia` and `AudioContext` require HTTPS. Rails dev (`bin/dev`) defaults to plain HTTP — use a self-signed cert or staging.
- `AudioContext` autoplay policy: create/resume inside a user-gesture handler, never on page load.

### Study Algorithm

The study engine (`app/domain/study.rb`) manages card selection and answer processing:
- Selects from the first 20 not-done cards (at the current deck level), randomized
- Generates 5 multiple-choice answers (prioritizing previous wrong answers, then same-category cards)
- On correct answer: increments `correct_count` and `correct_streak`; if the last card at the level is completed, advances `deck.level`
- On incorrect answer: resets `correct_streak` to 0, records the wrong answer
- Level advancement happens in `Study#answer_card`, not in the controller

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
2. **Catalog Enhancements** - UI for setting deck visibility, search/filter, categories
3. **Mobile App** - Progressive Web App capabilities
4. **Bulk Operations** - Edit/delete multiple cards at once
5. **Study Statistics** - More detailed progress tracking and visualizations
6. **Accessibility** - Continue improving screen reader support
7. **Internationalization** - Multi-language support for UI (not just study content)

## Resources

- Phlex Documentation: https://www.phlex.fun/
- Rails Guides: https://guides.rubyonrails.org/
- Creem Docs: https://docs.creem.io/

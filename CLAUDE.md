# Flash - Project Documentation

## Overview

Flash is a flashcard study application built with Ruby on Rails that uses spaced repetition to help users learn and retain information. The app features a distinctive "Terminal Scholar" design aesthetic and uses Phlex for view rendering instead of ERB.

**Tech Stack:**
- Ruby on Rails 8.1.1
- PostgreSQL database
- Phlex for HTML views
- Creem for payment processing
- Hotwire (Turbo + Stimulus)

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
- `flash.css` - Study/flashcard specific styles (the core app)
- `layout.css` - Header, footer, navigation
- `welcome.css` - Landing page styles
- `decks.css` - Deck listing and form styles

**Key Principles:**
- Separate CSS files per major section
- Include all stylesheets in layout
- Avoid inline styles
- Use CSS custom properties (variables) for colors
- Mobile-first responsive design with media queries

### Data Model

**Core Models:**
- `User` - Authentication, has many decks
- `Deck` - Collection of flashcards, belongs to user
- `Card` - Individual flashcard with front/back, belongs to deck
- `Subscription` - Payment/subscription info, belongs to user

**Card Statuses:**
- `pending` - Not yet studied
- `active` - Currently being studied
- `done` - Mastered (high streak)

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
│   └── creem/
│       ├── cancel_subscription.rb
│       └── client.rb
├── components/
│   └── base.rb           # Base component with Rails helpers
├── controllers/
│   ├── application_controller.rb
│   ├── decks_controller.rb
│   ├── pages_controller.rb
│   └── subscriptions_controller.rb
├── models/
│   ├── user.rb
│   ├── deck.rb
│   ├── card.rb
│   └── subscription.rb
├── views/
│   ├── base.rb           # Base view class
│   ├── layouts/
│   │   └── application.rb
│   ├── welcome/
│   │   └── index.rb
│   ├── decks/
│   │   ├── index.rb
│   │   ├── new.rb
│   │   └── show.rb
│   ├── pages/
│   │   ├── privacy.rb
│   │   └── terms.rb
│   └── subscriptions/
│       └── show.rb
└── assets/
    └── stylesheets/
        ├── application.css
        ├── flash.css
        ├── layout.css
        ├── welcome.css
        └── decks.css
```

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

### CSV Import

Decks are created by uploading CSV files with this format:
- Columns: `front`, `back`, `category`
- Multiple answers separated by `;`
- Sample CSV available via environment variable `SAMPLE_CSV_URL`

### Spaced Repetition Algorithm

The app tracks:
- `correct_count` - Total correct answers
- `correct_streak` - Current streak
- `view_count` - Times card has been shown
- `status` - pending/active/done

Cards progress based on performance and are shown at optimal intervals.

### Subscription Transparency

**Important:** Be transparent that subscriptions currently offer no extra features. The subscription page prominently displays:
- "$5/month" pricing
- Clear notice that there are no extra benefits
- Messaging that it's for project support and hosting costs
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
2. **Deck Sharing** - Consider public deck library
3. **Mobile App** - Progressive Web App capabilities
4. **Bulk Operations** - Edit/delete multiple cards at once
5. **Study Statistics** - More detailed progress tracking and visualizations
6. **Accessibility** - Continue improving screen reader support
7. **Internationalization** - Multi-language support for UI (not just study content)

## Resources

- Phlex Documentation: https://www.phlex.fun/
- Rails Guides: https://guides.rubyonrails.org/
- Creem Docs: https://docs.creem.io/

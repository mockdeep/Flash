# RSpec Testing Skill

## Overview

Guidelines and patterns for writing RSpec tests in this Rails application.

## File Structure

### No Explicit Rails Helper Require

**Don't include `require "rails_helper"` in spec files.** It's automatically loaded via `.rspec` configuration.

```ruby
# Bad
require "rails_helper"

RSpec.describe DecksController do
  # ...
end

# Good
RSpec.describe DecksController do
  # ...
end
```

## Core Conventions

### Avoid `let` Blocks

**Don't use `let` or `let!` blocks.** Use inline setup or helper methods instead for better readability and explicit test setup.

```ruby
# Bad
let(:deck) { create(:deck) }
let(:card) { create(:card, deck: deck) }

# Good - inline setup
it "does something" do
  deck = create(:deck)
  card = create(:card, deck: deck)

  expect(card.deck).to eq(deck)
end

# Good - helper method for complex setup
def answer_params(card:, answer:)
  {
    answer: {
      card_id: card.id,
      answer: answer,
    },
  }
end
```

### Factory Usage

**Use factory defaults where possible:**

```ruby
# Bad - redundant parameters
create(:subscription, user: default_user, status: "active")

# Good - factory provides defaults
create(:subscription)
```

**Use traits for different states:**

```ruby
# Bad
create(:card, status: "active")

# Good
create(:card, :active)

# Traits must come before keyword arguments
create(:card, :active, deck: my_deck)  # Correct
create(:card, deck: my_deck, :active)  # Syntax error!
```

**Factory Caching Pattern:**

For factories that use `default_user` or `default_deck`, ensure the cache checks persistence:

```ruby
module FactoryCache
  extend self

  def user
    return @user if @user&.persisted?

    @user = FactoryBot.create(:user)
  end

  def deck
    return @deck if @deck&.persisted?

    @deck = FactoryBot.create(:deck)
  end
end
```

This prevents issues with factory linting where transactions get rolled back.

## Test Structure and Formatting

### Test Size Limits

**Keep tests concise and focused:**
- **5 lines or fewer** per test body (not counting blank lines or the `it`/`end` lines)
- **80 characters or fewer** per line
- If a test exceeds these limits, look for opportunities to extract helpers or simplify

### Arrange-Act-Assert Pattern

**Always separate test sections with blank lines:**

```ruby
# Good - clear separation
it "updates status to canceled" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription, status: 200)

  result = described_class.call(subscription:)

  expect(result.success?).to be(true)
end

# Also good - when exercise and verify are combined in expect block
it "creates a subscription" do
  create(:user, email: "subscriber@example.com")
  payload = subscription_created_payload

  expect { post_webhook(payload:, signature: generate_signature(payload)) }
    .to change(Subscription, :count).by(1)
end
```

### Ruby Hash Shorthand

**Use Ruby 3.1+ hash value shorthand syntax:**

```ruby
# Good - hash shorthand
described_class.call(subscription:)
post_webhook(payload:, signature:)

# Bad - redundant
described_class.call(subscription: subscription)
post_webhook(payload: payload, signature: signature)
```

### Helper Methods for Test Data

**Extract common setup into helpers with sensible defaults:**

```ruby
# Good - helpers with defaults
def subscription_created_payload(
  subscription_id: "sub_test",
  status: "active",
  customer_email: "subscriber@example.com"
)
  {
    type: "subscription.created",
    data: {
      id: subscription_id,
      status: status,
      customer: { email: customer_email },
      current_period_start: 1.month.ago.to_i,
      current_period_end: 1.month.from_now.to_i,
      plan: { name: "Flash Supporter" },
    }
  }
end

# Usage - only override what you need
it "stores subscription status" do
  create(:user, email: "subscriber@example.com")
  payload = subscription_created_payload(status: "trialing")

  post_webhook(payload:, signature: generate_signature(payload))

  expect(Subscription.last.status).to eq("trialing")
end
```

**Extract URLs into helper methods:**

```ruby
# Good - URL helpers keep lines short
def cancel_url(subscription)
  subscription_id = subscription.creem_subscription_id
  "https://test-api.creem.io/v1/subscriptions/#{subscription_id}/cancel"
end

def stub_creem_cancel(subscription, status:, body: {})
  stub_request(:post, cancel_url(subscription))
    .to_return(status: status, body: body.to_json)
end

# Usage
it "sends immediate cancellation mode" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription, status: 200)

  described_class.call(subscription:)

  expect(WebMock).to have_requested(:post, cancel_url(subscription))
    .with(body: hash_including(mode: "immediate"))
end
```

**Helpers should accept domain objects, not IDs:**

```ruby
# Good - accepts subscription object
def cancel_url(subscription)
  sub_id = subscription.creem_subscription_id
  "https://test-api.creem.io/v1/subscriptions/#{sub_id}/cancel"
end

# Bad - requires ID extraction in every test
def cancel_url(subscription_id)
  "https://test-api.creem.io/v1/subscriptions/#{subscription_id}/cancel"
end
```

### No Abbreviations

**Use full, descriptive variable names:**

```ruby
# Good
subscription = create(:subscription)
result = described_class.call(subscription:)

# Bad
sub = create(:subscription)
res = described_class.call(subscription: sub)
```

## Test Types

### Model Specs

Use shoulda-matchers for validations and associations:

```ruby
RSpec.describe Subscription do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:status) }

  it do
    create(:subscription)

    expect(described_class.new)
      .to validate_uniqueness_of(:creem_subscription_id)
  end

  describe "#active?" do
    it "returns true when status is active" do
      subscription = build(:subscription)

      expect(subscription.active?).to be(true)
    end
  end
end
```

**Don't use organizational comments** - No `# Associations`, `# Validations`, `# Methods` headers. Let the test structure speak for itself.

**Don't test database columns** - that's testing ActiveRecord, not your application.

### Request Specs (Controllers)

**Use method names in describe blocks:**

```ruby
# Good - use method name
describe "#pricing" do
  it "renders the pricing page" do
    get(pricing_path)

    expect(rendered).to have_content("Pricing")
  end
end

# Bad - don't use HTTP verb + path
describe "GET /pricing" do
  # ...
end
```

**Test rendered content, not just HTTP status:**

```ruby
# Good - test actual content using rendered helper
it "renders the pricing page" do
  get(pricing_path)

  expect(rendered).to have_content("Pricing")
end

# Bad - only testing status
it "renders the pricing page" do
  get(pricing_path)

  expect(response).to have_http_status(:ok)
end
```

**The `rendered` helper** is available in request specs (defined in `spec/support/helpers/request_spec_helpers.rb`):

```ruby
def rendered
  Capybara.string(response.body)
end
```

**Use HTTP status checks, not exception expectations:**

```ruby
# Bad - doesn't work in request specs
expect { get(deck_path(other_deck)) }
  .to raise_error(ActiveRecord::RecordNotFound)

# Good - check HTTP status
get(deck_path(other_deck))
expect(response).to have_http_status(:not_found)
```

**Test authorization boundaries:**

```ruby
context "when user is not logged in" do
  it "redirects to log in page" do
    deck = create(:deck)

    get(deck_path(deck))

    expect(response).to redirect_to(new_session_path)
  end
end

context "when user is logged in" do
  it "does not allow viewing another user's deck" do
    other_user = create(:user)
    other_deck = create(:deck, user: other_user)

    login_as(default_user)
    get(deck_path(other_deck))

    expect(response).to have_http_status(:not_found)
  end
end
```

**Helper methods for params:**

```ruby
def answer_params(card:, answer:)
  {
    answer: {
      card_id: card.id,
      answer: answer,
    },
  }
end

# Usage
put(deck_study_path(deck), params: answer_params(card: card, answer: "Answer"))
```

### Action/Service Object Specs

**Focus on database changes and side effects:**

```ruby
RSpec.describe Creem::CancelSubscription do
  def cancel_url(subscription)
    sub_id = subscription.creem_subscription_id
    "https://test-api.creem.io/v1/subscriptions/#{sub_id}/cancel"
  end

  def stub_creem_cancel(subscription, status:, body: {})
    stub_request(:post, cancel_url(subscription))
      .to_return(status: status, body: body.to_json)
  end

  describe ".call" do
    context "when Creem API returns success" do
      it "updates status to canceled" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)

        expect { described_class.call(subscription:) }
          .to change_record(subscription, :status).from("active").to("canceled")
      end

      it "returns success result" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)

        result = described_class.call(subscription:)

        expect(result.success?).to be(true)
      end
    end

    context "when Creem API returns failure" do
      it "returns failure result" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 400)

        result = described_class.call(subscription:)

        expect(result.success?).to be(false)
      end

      it "does not update subscription status" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 500)

        expect { described_class.call(subscription:) }
          .not_to change_record(subscription, :status)
      end
    end
  end
end
```

**Test file operations and complex data:**

```ruby
RSpec.describe Decks::Create do
  describe ".call" do
    it "creates cards from CSV" do
      user = default_user
      csv_file = fixture_file_upload("decks/basic.csv", "text/csv")

      result = described_class.call(user:, file: csv_file, name: "Test Deck")

      expect(result.success?).to be(true)
      expect(result.deck.cards.count).to eq(3)
    end

    it "returns failure when CSV is invalid" do
      user = default_user
      csv_file = fixture_file_upload("decks/invalid.csv", "text/csv")

      result = described_class.call(user:, file: csv_file, name: "Test Deck")

      expect(result.success?).to be(false)
      expect(result.error).to include("Invalid CSV")
    end
  end
end
```

### Valid Object Specs

Test initialization, state transitions, and business logic:

```ruby
RSpec.describe Study do
  describe "#initialize" do
    it "picks the next card" do
      deck = create(:deck)
      create(:card, :active, deck: deck)

      study = described_class.new(deck: deck)

      expect(study.next_card).to be_a(Card)
    end
  end

  describe "#answer_card" do
    context "when answer is correct" do
      it "increments correct_count" do
        deck = create(:deck)
        card = create(:card, deck: deck, back: "Correct")

        study = described_class.new(deck: deck)
        study.answer_card(card_id: card.id, answer: "Correct")

        expect(card.reload.correct_count).to eq(1)
      end
    end
  end
end
```

## Test Focus and Granularity

### Keep Tests Focused

Each test should verify one specific behavior. If you see linter warnings about multiple assertions in a test, split it into separate tests:

```ruby
# Good - separate focused tests
it "updates status to canceled" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription.creem_subscription_id, status: 200)

  expect { described_class.call(subscription: subscription) }
    .to change_record(subscription, :status).from("active").to("canceled")
end

it "sets canceled_at" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription.creem_subscription_id, status: 200)

  expect { described_class.call(subscription: subscription) }
    .to change_record(subscription, :canceled_at).from(nil)
end

# Bad - testing too many things at once (linter will warn)
it "returns failure result without updating subscription" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription.creem_subscription_id, status: 400)

  result = described_class.call(subscription: subscription)

  expect(result.success?).to be(false)      # First assertion
  expect(subscription.reload.status).to eq("active")  # Second assertion - split this!
end

# Good - split into two focused tests
it "returns failure result" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription.creem_subscription_id, status: 400)

  result = described_class.call(subscription: subscription)

  expect(result.success?).to be(false)
end

it "does not update subscription status" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription.creem_subscription_id, status: 400)

  expect { described_class.call(subscription: subscription) }
    .not_to change_record(subscription, :status)
end
```

### Avoid Over-Testing

**Don't test implementation details or things that don't matter:**

```ruby
# Good - just verify it changed from nil
expect { described_class.call(subscription: subscription) }
  .to change_record(subscription, :canceled_at).from(nil)

# Bad - over-specific timestamp testing
freeze_time do
  current_time = Time.current
  described_class.call(subscription: subscription)
  expect(subscription.reload.canceled_at).to eq(current_time)
end
```

**Focus on behavior, not return values that aren't used:**

```ruby
# Good - database change is what matters
expect { described_class.call(subscription: subscription) }
  .to change_record(subscription, :status).to("canceled")

# Often unnecessary - if you're already testing the database change
result = described_class.call(subscription: subscription)
expect(result.success?).to be(true)  # May not need this
```

## Common Patterns

### Environment Variables

**Prefer `.env.test` over stubbing in individual specs:**

```ruby
# .env.test
CREEM_API_KEY=test_api_key
CREEM_WEBHOOK_SECRET=test_webhook_secret
```

This approach:
- Keeps all test environment configuration in one place
- Avoids repetitive `stub_const("ENV", ...)` blocks in multiple spec files
- Makes it easier to see what environment variables are needed for tests
- Follows the same pattern as `.env.local` for development

Only use `stub_const` if a specific test needs to override the default value:

```ruby
# Only when you need to test different values in specific tests
it "handles missing API key" do
  stub_const("ENV", ENV.to_hash.merge("CREEM_API_KEY" => ""))
  # ...
end
```

### Webhook Testing

**Use helpers with defaults for webhook payloads:**

```ruby
def generate_signature(payload)
  payload_json = payload.to_json
  OpenSSL::HMAC.hexdigest(
    "sha256",
    ENV.fetch("CREEM_WEBHOOK_SECRET"),
    payload_json
  )
end

def post_webhook(payload:, signature:)
  payload_json = payload.to_json

  post(
    webhooks_creem_path,
    params: payload_json,
    headers: {
      "CONTENT_TYPE" => "application/json",
      "creem-signature" => signature,
    }
  )
end

def subscription_created_payload(
  subscription_id: "sub_test",
  status: "active",
  customer_email: "subscriber@example.com"
)
  {
    type: "subscription.created",
    data: {
      id: subscription_id,
      status: status,
      customer: { email: customer_email },
      current_period_start: 1.month.ago.to_i,
      current_period_end: 1.month.from_now.to_i,
      plan: { name: "Flash Supporter" },
    }
  }
end

# Usage - only override what you need
it "stores subscription status" do
  create(:user, email: "subscriber@example.com")
  payload = subscription_created_payload(status: "trialing")

  post_webhook(payload:, signature: generate_signature(payload))

  expect(Subscription.last.status).to eq("trialing")
end
```

### Testing Database Changes

**Use `change_record` matcher for testing attribute changes:**

```ruby
# Good - uses change_record to automatically reload
expect { described_class.call(subscription:) }
  .to change_record(subscription, :status).from("active").to("canceled")

# Also good - verify it changes from nil without specifying final value
expect { described_class.call(subscription:) }
  .to change_record(subscription, :canceled_at).from(nil)

# Good - verify it does NOT change
expect { described_class.call(subscription:) }
  .not_to change_record(subscription, :status)

# Bad - manual reload
result = described_class.call(subscription:)
expect(subscription.reload.status).to eq("canceled")
```

### WebMock for HTTP Testing

**Prefer webmock over stubbing client classes** - it tests more of the actual code path:

```ruby
# Good - tests the full HTTP stack including JSON parsing
def cancel_url(subscription)
  sub_id = subscription.creem_subscription_id
  "https://test-api.creem.io/v1/subscriptions/#{sub_id}/cancel"
end

def stub_creem_cancel(subscription, status:, body: {})
  stub_request(:post, cancel_url(subscription))
    .to_return(status: status, body: body.to_json)
end

it "updates status to canceled" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription, status: 200)

  expect { described_class.call(subscription:) }
    .to change_record(subscription, :status).from("active").to("canceled")
end

# Bad - stubbing the client class directly
allow(Creem::Client).to receive(:post).and_return({ success: true })
```

**Create helper methods to reduce webmock verbosity:**

```ruby
# At the top of the spec file
def stub_creem_cancel(subscription_id, status:, body: {})
  stub_request(:post, "https://test-api.creem.io/v1/subscriptions/#{subscription_id}/cancel")
    .to_return(status: status, body: body.to_json)
end

# Usage - omit body when the code doesn't use response data
stub_creem_cancel(subscription.creem_subscription_id, status: 200)

# Only include body when testing error logging or response parsing
stub_creem_cancel(subscription.creem_subscription_id, status: 400, body: { error: "Failed" })
```

**Note on response bodies:** Only specify the `body` parameter when:
- The code being tested actually uses the response data
- You're testing error logging that includes the response body
- The test asserts on specific values from the response

If the code only checks success/failure based on HTTP status, the default empty `{}` is sufficient. This keeps tests focused on what matters.

**WebMock header matching:** Use plain hashes, not RSpec matchers:

```ruby
# Good - plain hash for WebMock
expect(WebMock).to have_requested(:post, url)
  .with(headers: { "x-api-key" => "test_key" })

# Bad - RSpec matcher doesn't work with WebMock
expect(WebMock).to have_requested(:post, url)
  .with(headers: hash_including("x-api-key" => "test_key"))
```

## Factory Best Practices

### Define Required Attributes

Only set attributes that don't have database defaults:

```ruby
FactoryBot.define do
  factory(:card) do
    deck { default_deck }

    sequence(:front, 100) { |n| "Card Front #{n}" }
    sequence(:back, 100) { |n| "Card Back #{n}" }
    category { "General" }
    status { "pending" }

    # Don't set these - they have database defaults
    # correct_count { 0 }
    # correct_streak { 0 }
    # view_count { 0 }
    # wrong_answers { [] }

    trait(:active) do
      status { "active" }
    end
  end
end
```

### Sequence Starting Numbers

Start sequences at 100 to avoid conflicts with seed data:

```ruby
sequence(:front, 100) { |n| "Card Front #{n}" }
```

## Running Tests

### Full Suite
```bash
bundle exec rspec --format progress
```

### Specific Files
```bash
bundle exec rspec spec/models/user_spec.rb --format documentation
```

### Factory Linting
```bash
bundle exec rspec spec/general/factory_bot_spec.rb
```

## Common Pitfalls

1. **Trait Syntax Error**: Traits must come before keyword arguments
   - Wrong: `create(:card, deck: my_deck, :active)`
   - Right: `create(:card, :active, deck: my_deck)`

2. **Testing RecordNotFound in Request Specs**: Don't use `raise_error`, check HTTP status
   - Wrong: `expect { get(...) }.to raise_error(ActiveRecord::RecordNotFound)`
   - Right: `get(...); expect(response).to have_http_status(:not_found)`

3. **Factory Circular Dependencies**: Ensure default_user/default_deck check persistence
   - Add `return @user if @user&.persisted?` before creating

4. **Redundant Factory Parameters**: Use factory defaults instead
   - Wrong: `create(:subscription, user: default_user, status: "active")`
   - Right: `create(:subscription)`

5. **Testing Database Columns**: Don't test that ActiveRecord works
   - Don't: `it "stores creem_subscription_id"`
   - Do: Test validations and business logic

6. **Stubbing HTTP Clients**: Prefer webmock over stubbing client classes
   - Wrong: `allow(Creem::Client).to receive(:post).and_return({ success: true })`
   - Right: `stub_request(:post, "https://test-api.creem.io/v1/...").to_return(status: 200, body: {}.to_json)`

7. **Over-Testing Timestamps**: Don't test exact timestamps unless precision matters
   - Wrong: `freeze_time { expect(record.reload.created_at).to eq(Time.current) }`
   - Right: `expect { action }.to change_record(record, :created_at).from(nil)`

8. **Testing Too Many Things**: Keep each test focused on one behavior (linter will warn about multiple assertions)
   - Wrong: One test checking status, timestamps, return values, and side effects
   - Right: Separate tests for each behavior

9. **Environment Variable Management**: Use `.env.test` instead of stubbing in every spec
   - Wrong: Adding `stub_const("ENV", ...)` blocks to multiple spec files
   - Right: Define test values in `.env.test` file once

10. **Unnecessary WebMock Body Data**: Only specify response body when code uses it
   - Wrong: Always including `body: { success: true }` or detailed error data
   - Right: Omit body parameter when code only checks HTTP status; default `{}` is sufficient

11. **Not Using Hash Shorthand**: Use Ruby 3.1+ shorthand syntax
   - Wrong: `described_class.call(subscription: subscription)`
   - Right: `described_class.call(subscription:)`

12. **Tests Exceeding Size Limits**: Tests should be concise and focused
   - Wrong: Tests with more than 5 body lines or lines longer than 80 characters
   - Right: Extract helpers, use defaults, keep tests focused on one behavior

13. **Missing Arrange-Act-Assert Separation**: Tests should have clear visual sections
   - Wrong: No blank lines between setup, exercise, and verify
   - Right: Blank line after setup, blank line before verify (when separate from exercise)

14. **Helpers with Too Many Required Parameters**: Make tests verbose and hard to maintain
   - Wrong: `subscription_payload(subscription_id:, status:, customer_email:)` - all required
   - Right: `subscription_payload(subscription_id: "default", status: "active", customer_email: "test@example.com")` - use defaults

15. **Helpers Accepting IDs Instead of Objects**: Forces ID extraction in every test
   - Wrong: `def cancel_url(subscription_id)` - requires `subscription.creem_subscription_id` in every call
   - Right: `def cancel_url(subscription)` - extract ID inside helper

16. **Using Abbreviations**: Makes tests harder to read
   - Wrong: `sub = create(:subscription)`, `res = call_action`
   - Right: `subscription = create(:subscription)`, `result = call_action`

17. **Organizational Comments**: Don't use section headers in specs
   - Wrong: `# Associations`, `# Validations`, `# Methods`
   - Right: Let the test structure (describe blocks, it statements) provide organization

## Test Organization

```
spec/
├── actions/           # Service objects
├── channels/          # Action Cable channels
├── factories/         # FactoryBot factories
├── fixtures/          # Test data files (CSV, etc)
├── general/           # General tests (factory linting)
├── helpers/           # View helpers
├── jobs/              # ActiveJob jobs
├── lib/               # Library code (route constraints, etc)
├── mailers/           # ActionMailer mailers
├── models/            # ActiveRecord models
├── requests/          # Controller integration tests
├── support/           # Test support files
├── system/            # Full-stack system tests
└── valid_objects/     # Plain Ruby objects (not ActiveRecord)
```

## Quick Reference

### Test Structure Checklist

When writing a test, ensure:

- [ ] **5 body lines or fewer** (not counting blank lines)
- [ ] **All lines under 80 characters**
- [ ] **Arrange-Act-Assert separation** with blank lines
- [ ] **Ruby hash shorthand** (`user:` not `user: user`)
- [ ] **No abbreviations** (use `subscription` not `sub`)
- [ ] **No organizational comments** (no `# Associations`, `# Validations`, etc.)
- [ ] **Helper methods** for URLs and common setup
- [ ] **Default parameters** in helpers (override only what's needed)
- [ ] **Semantic helpers** that accept objects, not IDs
- [ ] **WebMock** over client stubbing
- [ ] **No unnecessary body data** in stubs

### Example Perfect Test

```ruby
# Helper with defaults
def cancel_url(subscription)
  sub_id = subscription.creem_subscription_id
  "https://test-api.creem.io/v1/subscriptions/#{sub_id}/cancel"
end

def stub_creem_cancel(subscription, status:, body: {})
  stub_request(:post, cancel_url(subscription))
    .to_return(status: status, body: body.to_json)
end

# Test: 4 body lines, clear sections, hash shorthand
it "updates status to canceled" do
  subscription = create(:subscription)
  stub_creem_cancel(subscription, status: 200)

  expect { described_class.call(subscription:) }
    .to change_record(subscription, :status).from("active").to("canceled")
end
```

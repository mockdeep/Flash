# Flash

Flash is a flashcard study app that uses spaced repetition to help you learn
and retain information. It's built with Ruby on Rails, renders its views with
[Phlex](https://www.phlex.fun/) instead of ERB, and wears a distinctive
"Terminal Scholar" look.

One upload becomes reusable content: a **data set** of terms that can be
studied as several deck "forms" — the original front→back text deck, a reverse
deck (answers become prompts, no re-upload), or a microphone-driven music deck.
Public decks can be browsed and copied from a catalog, or shared privately via a
revocable link.

For architecture, conventions, and the data model in depth, see
[`AGENTS.md`](AGENTS.md).

## Tech stack

- Ruby 4.0.5 / Ruby on Rails 8.1.3
- PostgreSQL
- Hotwire (Turbo + Stimulus), TypeScript bundled with esbuild
- Phlex for views
- [Creem](https://creem.io) for subscription payments
- Node 26.3.1, managed with pnpm 10.26.1

## Getting started

### Prerequisites

- Ruby 4.0.5 (see `.ruby-version`)
- PostgreSQL, running locally
- Node 26.3.1 and pnpm 10.26.1

### Setup

```sh
bin/setup
```

This installs Ruby and JS dependencies, prepares the database, and starts the
development server. To set up without booting the server, run
`bin/setup --skip-server`. To drop and recreate the database, use
`bin/setup --reset`.

### Running the app

```sh
bin/dev
```

`bin/dev` uses [foreman](https://github.com/ddollar/foreman) and `Procfile.dev`
to run the Puma web server (port 3000) alongside the JS and CSS watch/build
processes. The app is then available at http://localhost:3000.

## Configuration

Environment variables are loaded from `.env` files:

- `.env.local` — development values, **not** committed
- `.env.test` — test values, committed
- `.env.example` — template of required variables, committed

Variables used by the app:

- `CREEM_API_KEY` — Creem payment API key
- `CREEM_PRODUCT_ID` — Creem product ID for the subscription checkout
- `CREEM_WEBHOOK_SECRET` — secret for validating Creem webhooks

`HONEYBADGER_API_KEY` configures error reporting when set.

**Never commit `.env.local` or any file containing real API keys.**

## Testing

Ruby tests use RSpec:

```sh
bundle exec rspec        # full suite
bundle exec rspec path/to/spec.rb
```

JavaScript/TypeScript tests use Vitest. `pnpm test` runs type-checking and
linting first, then the suite (100% branch and function coverage is enforced):

```sh
pnpm test                # tscheck + eslint + vitest
pnpm vitest              # vitest only
```

## Linting & security

```sh
bin/rubocop              # Ruby style
pnpm eslint              # JS/TS style
pnpm stylelint           # CSS style
pnpm tscheck             # TypeScript type check

bin/brakeman             # static security analysis
bin/bundler-audit        # gem vulnerability audit
```

## Contact

- Support: support+flash@boon.gl
- GitHub: https://github.com/mockdeep/flash

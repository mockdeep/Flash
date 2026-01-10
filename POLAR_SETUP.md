# Polar.sh Subscription Integration

This application integrates with [Polar.sh](https://polar.sh) for subscription management.

## Setup Instructions

### 1. Create a Polar.sh Account

1. Visit [https://polar.sh](https://polar.sh) and create an account
2. Complete your organization setup

### 2. Create Your Subscription Product

1. Go to your Polar.sh dashboard
2. Navigate to Products → Create Product
3. Set up your subscription with pricing
4. Copy the Product ID - you'll need this for `POLAR_PRODUCT_ID`

### 3. Get API Credentials

#### Access Token
1. Go to Settings → API
2. Click "Create Access Token"
3. Give it a descriptive name (e.g., "Flash App Production")
4. Copy the token and save it as `POLAR_ACCESS_TOKEN`

#### Webhook Secret
1. Go to Settings → Webhooks
2. Click "Create Endpoint"
3. Set the URL to: `https://your-domain.com/webhooks/polar`
4. Select the following events:
   - `subscription.created`
   - `subscription.updated`
   - `subscription.canceled`
   - `subscription.revoked`
5. Copy the webhook secret and save it as `POLAR_WEBHOOK_SECRET`

### 4. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```bash
POLAR_ACCESS_TOKEN=polar_at_xxxxxxxxxxxxx
POLAR_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
POLAR_PRODUCT_ID=prod_xxxxxxxxxxxxx
POLAR_API_URL=https://api.polar.sh
```

**For development/testing**, use the sandbox environment:
```bash
POLAR_API_URL=https://sandbox-api.polar.sh
```

### 5. Run Database Migrations

```bash
bundle exec rails db:migrate
```

This will create the `subscriptions` table.

### 6. Test the Integration

#### Testing Webhooks Locally

Use a tool like [ngrok](https://ngrok.com) to expose your local server:

```bash
ngrok http 3000
```

Update your Polar.sh webhook URL to: `https://your-ngrok-url.ngrok.io/webhooks/polar`

#### Test Subscription Flow

1. Start your Rails server: `bin/rails server`
2. Navigate to `/subscriptions/new`
3. Click "Subscribe Now" and complete checkout
4. Verify the subscription appears in `/subscriptions`

## Usage

### For Users

- **View subscriptions**: Visit `/subscriptions`
- **Subscribe to a plan**: Visit `/subscriptions/new`
- **Cancel subscription**: Click "Cancel Subscription" on `/subscriptions`

### For Developers

#### Check subscription status

```ruby
user = User.find(1)
user.subscribed? # => true/false
user.subscription # => Subscription instance or nil
```

#### Access Polar.sh API

```ruby
polar = PolarService.new

# List products
products = polar.list_products

# Get subscription details
subscription = polar.get_subscription(subscription_id)

# Cancel subscription
polar.cancel_subscription(subscription_id)
```

## Webhook Events

The application handles the following webhook events:

- `subscription.created` - Creates a new subscription record
- `subscription.updated` - Updates subscription status and expiration
- `subscription.canceled` - Marks subscription as canceled
- `subscription.revoked` - Marks subscription as revoked

## Security

- Webhook signatures are verified using HMAC-SHA256
- All API requests require authentication with the access token
- Sensitive credentials are stored in environment variables

## Troubleshooting

### Webhooks not working

1. Check that `POLAR_WEBHOOK_SECRET` is correctly set
2. Verify the webhook URL in Polar.sh dashboard matches your app's URL
3. Check Rails logs for webhook processing errors: `tail -f log/development.log`

### API calls failing

1. Verify `POLAR_ACCESS_TOKEN` is correctly set
2. Check that the token has the required permissions
3. Ensure you're using the correct API URL (sandbox vs production)

### Subscription not showing up

1. Verify the webhook was received (check logs)
2. Ensure the customer email in Polar.sh matches the user email in your app
3. Check the subscriptions table: `rails console` → `Subscription.all`

## Documentation

- [Polar.sh Documentation](https://polar.sh/docs)
- [Polar.sh API Reference](https://polar.sh/docs/api-reference)
- [Polar.sh Webhooks](https://polar.sh/docs/integrate/webhooks/endpoints)

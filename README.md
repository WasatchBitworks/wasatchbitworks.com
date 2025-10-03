# Wasatch Bitworks Website

Professional web development services based in Sandy, Utah. This is the official website for Wasatch Bitworks LLC.

## About

Wasatch Bitworks builds fast, modern websites tailored to small businesses. We offer custom web development, hosting solutions, and ongoing maintenance services.

**Live Site:** [wasatchbitworks.com](https://wasatchbitworks.com)

## Tech Stack

- **Backend:** Ruby 3.x + Sinatra
- **Templating:** ERB (Erubi)
- **Styling:** Tailwind CSS (via CDN)
- **Email:** Mailgun SMTP
- **Analytics:** Plausible (self-hosted)
- **Deployment:** Heroku

## Getting Started

### Prerequisites

- Ruby 3.0 or higher
- Bundler gem
- Mailgun account (for contact form functionality)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Website
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment variables**

   Create a `.env` file or set the following environment variable:
   ```bash
   export MAILGUN_SMTP_PASSWORD="your_mailgun_smtp_password"
   ```

4. **Run the application**
   ```bash
   ruby bitworks.rb
   ```

   Or with Rack:
   ```bash
   rackup config.ru
   ```

5. **Visit the site**

   Open your browser to [http://localhost:4567](http://localhost:4567)

## Development

### Project Structure

```
.
├── bitworks.rb              # Main application file
├── config.ru                # Rack configuration
├── views/                   # ERB templates
│   ├── layout.erb          # Main layout
│   ├── home.erb            # Homepage
│   ├── services.erb        # Services & pricing
│   ├── about.erb           # About page
│   └── contact.erb         # Contact form
├── public/                  # Static assets
│   ├── images/             # Image files
│   └── favicon.ico         # Site favicon
├── Gemfile                  # Ruby dependencies
└── Procfile                 # Heroku process file
```

### Running in Development Mode

The application uses `sinatra/reloader` in development mode for automatic code reloading:

```bash
ruby bitworks.rb
```

Changes to `.rb` and `.erb` files will be automatically picked up.

### Testing the Contact Form

A test email endpoint is available at `/test-email` to verify Mailgun configuration:

```
GET http://localhost:4567/test-email
```

## Features

### Contact Form
- Honeypot field for bot protection
- Email notifications via Mailgun
- Auto-reply to submitters
- Form validation
- Session-based flash messages

### Pages
- **Home:** Hero section with brand messaging
- **Services:** Three-tier pricing with hosting plans
- **About:** Team info, tech stack, and company values
- **Contact:** Professional contact form

### Security
- CSRF protection via Sinatra sessions
- HTML escaping enabled by default
- Honeypot spam protection
- Environment variable for sensitive credentials

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MAILGUN_SMTP_PASSWORD` | Mailgun SMTP password for sending emails | Yes |

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

Copyright © 2025 Wasatch Bitworks LLC. All rights reserved.

## Contact

- **Email:** zach@wasatchbitworks.com
- **Website:** [wasatchbitworks.com](https://wasatchbitworks.com)
- **GitHub:** [@WasatchBitworks](https://github.com/WasatchBitworks)

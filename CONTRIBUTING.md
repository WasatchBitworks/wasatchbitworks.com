# Contributing Guide

Thank you for your interest in contributing to the Wasatch Bitworks website! This guide will help you get started with development.

## Development Setup

### Prerequisites

- Ruby 3.0+
- Bundler
- Git
- Text editor (VS Code, Sublime, etc.)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Website
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Mailgun credentials
   ```

4. **Run the development server**
   ```bash
   ruby bitworks.rb
   ```

5. **Visit** http://localhost:4567

## Development Workflow

### Branch Strategy

- `main` - Production-ready code
- Feature branches - `feature/description` or `fix/description`

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Edit code
   - Test locally
   - Ensure no errors

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

4. **Push to repository**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** (if applicable)

## Code Style Guidelines

### Ruby

- Use 2 spaces for indentation
- Follow Ruby style guide conventions
- Keep methods small and focused
- Use meaningful variable names

**Example:**
```ruby
# Good
def send_contact_email(name, email, message)
  Pony.mail(
    to: 'zach@wasatchbitworks.com',
    from: 'no-reply@mail.wasatchbitworks.com',
    reply_to: email,
    subject: "Contact from #{name}",
    body: message
  )
end

# Avoid
def sce(n,e,m)
  Pony.mail(to:'zach@wasatchbitworks.com',from:'no-reply@mail.wasatchbitworks.com',reply_to:e,subject:"Contact from #{n}",body:m)
end
```

### ERB Templates

- Maintain consistent indentation
- Use semantic HTML5 elements
- Keep templates focused on presentation
- Extract complex logic to helpers

**Example:**
```erb
<!-- Good -->
<section class="bg-gray-900 py-16">
  <div class="max-w-7xl mx-auto">
    <h1 class="text-4xl font-bold"><%= @title %></h1>
  </div>
</section>

<!-- Avoid inline Ruby logic -->
```

### Tailwind CSS

- Use Tailwind utility classes
- Follow mobile-first approach
- Group related classes logically
- Use consistent spacing scale

**Class order:**
1. Layout (flex, grid, block)
2. Positioning (relative, absolute)
3. Sizing (w-, h-, max-w-)
4. Spacing (p-, m-)
5. Typography (text-, font-)
6. Visual (bg-, border-, shadow-)
7. Interactive (hover:, focus:)

**Example:**
```html
<button class="flex items-center px-6 py-3 text-sm font-semibold text-white bg-indigo-600 rounded-lg shadow-lg hover:bg-indigo-700 transition">
  Click Me
</button>
```

## Project Structure

```
.
├── bitworks.rb              # Main application file
│   ├── Configuration        # Sinatra settings, Pony setup
│   ├── Helpers             # View helpers
│   ├── Routes              # URL endpoints
│   └── Email handlers      # Contact form logic
│
├── views/
│   ├── layout.erb          # Main layout wrapper
│   ├── home.erb            # Homepage
│   ├── services.erb        # Services & pricing
│   ├── about.erb           # About page
│   └── contact.erb         # Contact form
│
├── public/                 # Static assets
│   ├── images/            # Site images
│   └── favicon.ico        # Site favicon
│
└── config.ru              # Rack configuration
```

## Adding New Features

### Adding a New Page

1. **Create route in `bitworks.rb`**
   ```ruby
   get "/new-page" do
     erb :new_page, layout: :layout
   end
   ```

2. **Create view template**
   ```bash
   touch views/new_page.erb
   ```

3. **Add navigation link** in `views/layout.erb`
   ```erb
   <a href="/new-page" class="text-sm font-semibold text-white">New Page</a>
   ```

### Adding a Helper Method

Add to helpers block in `bitworks.rb`:

```ruby
helpers do
  def format_date(date)
    date.strftime("%B %d, %Y")
  end

  def current_page?(path)
    request.path_info == path
  end
end
```

### Modifying the Contact Form

The contact form logic is in `bitworks.rb` (lines 74-130):

1. **Add new field** to `views/contact.erb`
2. **Update validation** in POST `/contact` route
3. **Include field** in email body
4. **Test** locally before deploying

## Testing

### Manual Testing Checklist

Before pushing changes:

- [ ] All pages load without errors
- [ ] Contact form submits successfully
- [ ] Email notifications work
- [ ] Responsive design works on mobile/tablet/desktop
- [ ] No console errors in browser
- [ ] Links navigate correctly
- [ ] Flash messages display properly

### Testing Contact Form

1. **Test locally:**
   ```bash
   # Visit http://localhost:4567/test-email
   # Check that test email arrives
   ```

2. **Test form submission:**
   - Fill out contact form
   - Submit
   - Verify email received
   - Verify auto-reply sent
   - Check flash message displays

3. **Test honeypot:**
   ```bash
   curl -X POST http://localhost:4567/contact \
     -d "first-name=Bot" \
     -d "last-name=Test" \
     -d "email=bot@test.com" \
     -d "phone-number=1234567890" \
     -d "nickname=gotcha" \
     -d "message=spam"
   # Should return 400 Bad Request
   ```

## Common Tasks

### Update Pricing

Edit `views/services.erb`:
- Starter Site: Line 11
- Growth Site: Line 25
- Custom Solution: Line 39
- Setup services: Lines 70, 82
- Hosting plans: Lines 120, 132, 144

### Update Contact Email

Edit `bitworks.rb`:
- Line 107: Recipient email
- Line 134: Test email recipient

### Add New Technology Logo

1. Add image to `public/images/`
2. Update `views/about.erb` (lines 72-79):
   ```erb
   <img class="max-h-12 w-full object-contain"
        src="/images/your-logo.png"
        alt="Technology Name">
   ```

### Modify Email Templates

Email body templates are in `bitworks.rb`:
- Contact notification: Lines 93-102
- Auto-reply: Lines 118-119

## Environment Variables

Always use environment variables for sensitive data:

```ruby
# Good
password: ENV['MAILGUN_SMTP_PASSWORD']

# Bad - Never commit passwords
password: 'actual_password_here'
```

See `.env.example` for required variables.

## Debugging

### View Logs

**Development:**
```bash
ruby bitworks.rb
# Logs appear in terminal
```

**Production (Heroku):**
```bash
heroku logs --tail
```

### Common Issues

**Port already in use:**
```bash
lsof -ti:4567 | xargs kill
```

**Bundle issues:**
```bash
bundle clean --force
bundle install
```

**Email not sending:**
- Check `MAILGUN_SMTP_PASSWORD` is set
- Verify Mailgun domain is verified
- Check Mailgun logs in dashboard

## Deployment

Before deploying to production:

1. **Test thoroughly** on localhost
2. **Review changes** - no debug code or credentials
3. **Update README** if needed
4. **Commit with clear message**
5. **Push to Heroku** (see DEPLOYMENT.md)

```bash
git push heroku main
```

## Git Commit Messages

Write clear, concise commit messages:

**Good:**
- `Add testimonials section to home page`
- `Fix contact form validation for phone numbers`
- `Update pricing on Growth Site plan`

**Avoid:**
- `updates`
- `fix stuff`
- `changes`

## Getting Help

- **Email:** zach@wasatchbitworks.com
- **Issues:** GitHub Issues (if available)
- **Documentation:** See README.md and DEPLOYMENT.md

## Code of Conduct

- Be respectful and professional
- Write clean, maintainable code
- Document complex logic
- Test before pushing
- Ask questions when unsure

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project.

---

Thank you for contributing to Wasatch Bitworks! 🚀

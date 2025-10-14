require "sinatra"
require "sinatra/content_for"
require 'tilt/erubi'
require "date"
require "pony"
require "securerandom"
require "rack/protection"

# Load .env in development
require 'dotenv/load' if ENV['RACK_ENV'] == 'development' || (!ENV['RACK_ENV'] && !ENV['DYNO'])

Pony.options = {
  via: :smtp,
  via_options: {
    address: ENV.fetch('MAILGUN_SMTP_SERVER', 'smtp.mailgun.org'),
    port: ENV.fetch('MAILGUN_SMTP_PORT', '587'),
    enable_starttls_auto: true,
    user_name: ENV.fetch('MAILGUN_SMTP_LOGIN', 'postmaster@mail.wasatchbitworks.com'),
    password: ENV.fetch('MAILGUN_SMTP_PASSWORD', 'dev-placeholder-password'),
    authentication: :plain,
    domain: ENV.fetch('MAILGUN_DOMAIN', 'mail.wasatchbitworks.com')
  }
}

configure do
  set :sessions, key: 'wb.session',
                 httponly: true,
                 same_site: :lax,
                 secure: settings.environment == :production
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(32) }
  set :erb, escape_html: true
  set :protection, true
end

configure(:development) do
  require "sinatra/reloader"
end

use Rack::Protection

helpers do
  def production?
    settings.environment == :production
  end

  def valid_email?(value)
    /
      \A
      [A-Z0-9._%+-]+    # local
      @
      [A-Z0-9.-]+       # domain
      \.[A-Z]{2,}       # tld
      \z
    /ix.match?(value.to_s)
  end
end

before do
  # Force HTTPS in production (trusting X-Forwarded-Proto from proxy/CDN)
  if production?
    scheme = request.env['HTTP_X_FORWARDED_PROTO'] || request.scheme
    if scheme == 'http'
      redirect to("https://#{request.host}#{request.fullpath}"), 301
    end
  end

  # Basic CSP
  csp_directives = [
    "default-src 'self'",
    "img-src 'self' data: https://upload.wikimedia.org https://github.githubassets.com",
    "style-src 'self' 'unsafe-inline'",
    "script-src 'self' https://analytics.wasatchbitworks.com",
    "connect-src 'self' https://analytics.wasatchbitworks.com",
    "form-action 'self'",
    "base-uri 'self'",
    "frame-ancestors 'none'",
    "object-src 'none'"
  ]
  # Only upgrade to HTTPS in production
  csp_directives << "upgrade-insecure-requests" if production?
  headers['Content-Security-Policy'] = csp_directives.join('; ')

  # Flash messages
  @flash_success = session.delete(:success)
  @flash_error   = session.delete(:error)
end

get "/" do
  redirect "/home"
end

get "/home" do
  

  erb :home, layout: :layout
end

get "/services" do
  
  erb :services, layout: :layout
end

get "/about" do
  
  erb :about, layout: :layout
end

get "/contact" do


  erb :contact, layout: :layout
end

post '/contact' do
  # honeypot check for bots
  # If the nickname field is filled, it's likely a bot
  halt 400 if params[:nickname] && !params[:nickname].empty?
  
  # Step 1: Grab form input from params
  first_name = params[:'first-name'].to_s.strip
  last_name = params[:'last-name'].to_s.strip
  email = params[:email].to_s.strip
  unless valid_email?(email)
    status 422
    return "Please enter a valid email address."
  end
  phone_number = params[:'phone-number'].to_s.strip
  message = params[:message].to_s.strip

  # Step 2: (Optional) Basic form validation
  if [first_name, last_name, email, message].any? { |field| field.nil? || field.strip.empty? }
    status 422
    return "Please fill in all required fields."
  end

  session[:last_contact_submit] ||= 0
  if Time.now.to_i - session[:last_contact_submit] < 20
    status 429
    return "Please wait a few seconds before trying again."
  end

  # Step 3: Compose the email body
  email_body = <<~BODY
    New Contact Form Submission:

    Name: #{first_name} #{last_name}
    Email: #{email}
    Phone: #{phone_number}

    Message:
    #{message}
  BODY

  # Step 4: Try sending the email
  begin
    Pony.mail(
      to: 'zach@wasatchbitworks.com',
      from: 'no-reply@mail.wasatchbitworks.com',    # Must match your verified Mailgun domain
      reply_to: email,                              # <-- User's email for replying
      subject: "New Contact Form Submission",
      body: email_body
    )

    Pony.mail(
      to: email,
      from: 'no-reply@mail.wasatchbitworks.com',
      subject: "Thanks for reaching out!",
      body: "Hi #{params[:'first-name']},\n\nThanks for contacting Wasatch Bitworks!
        We'll get back to you shortly.\n\n- Zach"
    )

    session[:last_contact_submit] = Time.now.to_i
    session[:success] = "Thanks for getting in touch, we will contact you soon!"
    redirect '/contact'
  rescue => e
    puts "Email failed: #{e.message}"
    session[:error] = "Sorry, there was a problem sending your message. Please try again or email
     me at zach@wasatchbitworks.com"
    redirect "/contact"
  end
end

get '/test-email' do
  Pony.mail(
    to: 'zach@wasatchbitworks.com',   # Replace this with your own receiving email
    from: 'no-reply@mail.wasatchbitworks.com', # Must match Mailgun domain
    subject: 'Test Email from Wasatch Bitworks!',
    body: 'This is a successful test email from Pony + Mailgun in production mode!'
  )
  "Test email sent! Check your inbox!"
end

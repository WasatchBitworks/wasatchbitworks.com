require "sinatra"
require "sinatra/content_for"
require 'tilt/erubi'
require "date"
require "pony"


#require_relative "database_persistence"

Pony.options = {
  via: :smtp,
  via_options: {
    address: 'smtp.mailgun.org',
    port: '587',
    enable_starttls_auto: true,
    user_name: 'postmaster@mail.wasatchbitworks.com',
    password: ENV['MAILGUN_SMTP_PASSWORD'], # <<< fixed here
    authentication: :plain,
    domain: 'wasatchbitworks.com'             # <<< and here
  }
}

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  #also_reload "database_persistence.rb"
end

helpers do
  def help
    puts "help"
  end
end

before do
  #@storage = DatabasePersistence.new(logger)
end

after do
  #@storage.disconnect
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
  # Step 1: Grab form input from params
  first_name = params[:'first-name']
  last_name = params[:'last-name']
  email = params[:email]
  phone_number = params[:'phone-number']
  message = params[:message]

  # Step 2: (Optional) Basic form validation
  if [first_name, last_name, email, message].any? { |field| field.nil? || field.strip.empty? }
    status 422
    return "Please fill in all required fields."
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
      from: 'no-reply@wasatchbitworks.com',
      subject: "Thanks for reaching out!",
      body: "Hi #{params[:'first-name']},\n\nThanks for contacting Wasatch Bitworks!
        We'll get back to you shortly.\n\n- Zach"
    )

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

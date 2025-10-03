# Deployment Guide

This guide covers deploying the Wasatch Bitworks website to production.

## Current Deployment: Heroku

The site is currently deployed on Heroku. Here's how to deploy updates:

### Prerequisites

- Heroku CLI installed
- Access to the Heroku app
- Git repository configured

### Initial Heroku Setup

1. **Login to Heroku**
   ```bash
   heroku login
   ```

2. **Add Heroku remote** (if not already added)
   ```bash
   heroku git:remote -a your-app-name
   ```

3. **Set environment variables**
   ```bash
   heroku config:set MAILGUN_SMTP_PASSWORD="your_password"
   ```

### Deploying Updates

1. **Commit your changes**
   ```bash
   git add .
   git commit -m "Your commit message"
   ```

2. **Push to Heroku**
   ```bash
   git push heroku main
   ```

3. **View logs** (if needed)
   ```bash
   heroku logs --tail
   ```

### Heroku Configuration

**Buildpack:**
```bash
heroku buildpacks:set heroku/ruby
```

**Procfile:**
The `Procfile` is already configured:
```
web: bundle exec rackup config.ru -p $PORT
```

**Environment Variables:**
```bash
# View all config vars
heroku config

# Set a config var
heroku config:set VARIABLE_NAME="value"
```

## Alternative Deployment Options

### Option 1: Render.com

1. **Create new Web Service**
   - Connect your GitHub repository
   - Build Command: `bundle install`
   - Start Command: `bundle exec rackup config.ru -p $PORT`

2. **Environment Variables**
   - Add `MAILGUN_SMTP_PASSWORD` in Render dashboard

3. **Custom Domain**
   - Add your domain in Render settings
   - Update DNS records as instructed

### Option 2: Railway.app

1. **Create new project from GitHub**
2. **Configure environment**
   ```bash
   MAILGUN_SMTP_PASSWORD=your_password
   ```
3. **Deploy automatically on push**

### Option 3: DigitalOcean App Platform

1. **Create new App**
   - Link GitHub repository
   - Select branch (main)

2. **Configure build**
   - Build Command: `bundle install`
   - Run Command: `bundle exec rackup config.ru -p $PORT`

3. **Add environment variables**
   - `MAILGUN_SMTP_PASSWORD`

### Option 4: Self-Hosted (VPS)

For a VPS like DigitalOcean Droplet or AWS EC2:

1. **Install dependencies**
   ```bash
   sudo apt update
   sudo apt install ruby-full build-essential nginx
   gem install bundler
   ```

2. **Clone and setup**
   ```bash
   cd /var/www
   git clone <repo-url> wasatchbitworks
   cd wasatchbitworks
   bundle install
   ```

3. **Configure systemd service**

   Create `/etc/systemd/system/wasatchbitworks.service`:
   ```ini
   [Unit]
   Description=Wasatch Bitworks Website
   After=network.target

   [Service]
   Type=simple
   User=www-data
   WorkingDirectory=/var/www/wasatchbitworks
   Environment="MAILGUN_SMTP_PASSWORD=your_password"
   ExecStart=/usr/local/bin/bundle exec rackup config.ru -p 9292
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

4. **Configure Nginx reverse proxy**

   Create `/etc/nginx/sites-available/wasatchbitworks`:
   ```nginx
   server {
       listen 80;
       server_name wasatchbitworks.com www.wasatchbitworks.com;

       location / {
           proxy_pass http://localhost:9292;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

5. **Enable and start**
   ```bash
   sudo ln -s /etc/nginx/sites-available/wasatchbitworks /etc/nginx/sites-enabled/
   sudo systemctl enable wasatchbitworks
   sudo systemctl start wasatchbitworks
   sudo systemctl restart nginx
   ```

6. **Setup SSL with Certbot**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d wasatchbitworks.com -d www.wasatchbitworks.com
   ```

## DNS Configuration

### Cloudflare Setup (Recommended)

1. **Add site to Cloudflare**
   - Go to Cloudflare dashboard
   - Add wasatchbitworks.com

2. **DNS Records**
   ```
   Type    Name    Content              Proxy Status
   A       @       <server-ip>          Proxied
   A       www     <server-ip>          Proxied
   ```

3. **SSL/TLS Settings**
   - Set to "Full (strict)" or "Flexible" depending on your backend

4. **Page Rules** (optional)
   - Always Use HTTPS
   - Cache Level: Standard

### Without Cloudflare

Point your domain's DNS A records to your server IP:
```
A     @       <server-ip>
A     www     <server-ip>
```

## Mailgun Configuration

### Setup Domain

1. **Add domain in Mailgun**
   - Domain: `mail.wasatchbitworks.com` (or your preference)

2. **Configure DNS Records**

   Add these records to your DNS:
   ```
   TXT   mail.wasatchbitworks.com   v=spf1 include:mailgun.org ~all
   TXT   smtp._domainkey.mail        k=rsa; p=<your-public-key>
   CNAME email.mail                  mailgun.org
   ```

3. **Verify domain** in Mailgun dashboard

4. **Update environment variable** with SMTP password

### Test Email Functionality

```bash
# Production test
curl https://wasatchbitworks.com/test-email
```

## Monitoring & Maintenance

### Health Checks

Add a health check endpoint (optional):

```ruby
get '/health' do
  status 200
  "OK"
end
```

### Log Monitoring

**Heroku:**
```bash
heroku logs --tail
```

**Self-hosted:**
```bash
sudo journalctl -u wasatchbitworks -f
```

### Uptime Monitoring

Consider using:
- UptimeRobot (free)
- Pingdom
- StatusCake
- Built-in Heroku/Render monitoring

## Rollback Procedure

### Heroku Rollback

```bash
# View recent releases
heroku releases

# Rollback to previous release
heroku rollback

# Rollback to specific version
heroku rollback v123
```

### Manual Rollback

```bash
git revert <commit-hash>
git push origin main
git push heroku main
```

## Backup Strategy

### Database Backup

Currently no database is used. If you add PostgreSQL:

```bash
# Heroku
heroku pg:backups:capture
heroku pg:backups:download

# Manual
pg_dump -U postgres database_name > backup.sql
```

### Code Backup

- Primary: GitHub repository
- Heroku maintains release history
- Optional: Regular exports to S3 or similar

## Performance Optimization

### CDN Configuration

Currently using Cloudflare for:
- Global CDN
- DDoS protection
- SSL/TLS
- Caching static assets

### Application Optimization

1. **Static assets:** Served via CDN
2. **Tailwind CSS:** Using CDN (consider building custom CSS for production)
3. **Images:** Already optimized, consider WebP format
4. **Gzip compression:** Enabled by default on most platforms

## Troubleshooting

### Common Issues

**Site not loading:**
```bash
heroku ps              # Check dyno status
heroku logs --tail     # Check logs
```

**Email not sending:**
```bash
# Verify Mailgun credentials
heroku config | grep MAILGUN

# Test endpoint
curl https://wasatchbitworks.com/test-email
```

**SSL Issues:**
```bash
# Heroku automatically handles SSL
# For self-hosted, renew Let's Encrypt:
sudo certbot renew
```

## Security Checklist

- [ ] HTTPS enabled
- [ ] Environment variables secure (not in code)
- [ ] Session secret set
- [ ] HTML escaping enabled
- [ ] Honeypot spam protection active
- [ ] Firewall configured (if self-hosted)
- [ ] Regular dependency updates
- [ ] Log monitoring enabled

## Contact

For deployment issues or questions:
- Email: zach@wasatchbitworks.com
- GitHub: [@WasatchBitworks](https://github.com/WasatchBitworks)

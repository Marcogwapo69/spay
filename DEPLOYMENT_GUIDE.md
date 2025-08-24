# GiyaPay Transaction Manager - Web Server Deployment Guide

## 📋 Prerequisites

Before deploying to your web server, ensure you have:

1. **Node.js** (version 14 or higher)
2. **npm** (comes with Node.js)
3. **Web server access** (VPS, shared hosting with Node.js support, or cloud platform)
4. **Domain/subdomain** (optional but recommended)

## 🚀 Deployment Options

### Option 1: VPS/Cloud Server (Recommended)

#### Step 1: Install Node.js on Your Server
```bash
# For Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# For CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version
```

#### Step 2: Upload Your Files
Upload all these files to your server:
```
server.js
package.json
GiyaPayButtonTest.html
GiyaPayStatusFrontend.html
success.html
error.html
cancel.html
giyapay-backend.js
```

#### Step 3: Install Dependencies
```bash
cd /path/to/your/app
npm install
```

#### Step 4: Run the Application
```bash
# Development mode
npm start

# Production mode with PM2 (recommended)
npm install -g pm2
pm2 start server.js --name "giyapay-manager"
pm2 startup
pm2 save
```

#### Step 5: Configure Firewall/Port
```bash
# Allow port 3000 (or your chosen port)
sudo ufw allow 3000
```

### Option 2: Shared Hosting with Node.js Support

1. **Upload files** via FTP/cPanel File Manager
2. **Install dependencies** through hosting control panel or SSH
3. **Configure start script** in hosting control panel
4. **Set environment variables** if needed

### Option 3: Cloud Platforms

#### Heroku Deployment
1. Create `Procfile`:
```
web: node server.js
```

2. Deploy:
```bash
git init
git add .
git commit -m "Initial commit"
heroku create your-app-name
git push heroku main
```

#### Vercel Deployment
1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Deploy:
```bash
vercel
```

## ⚙️ Configuration Changes for Production

### 1. Update Port Configuration
Edit `server.js` to use environment port:

```javascript
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

### 2. Update Callback URLs
In `GiyaPayButtonTest.html`, change localhost URLs to your domain:

```javascript
const fields = {
    success_callback: "https://yourdomain.com/success",
    error_callback: "https://yourdomain.com/error",
    cancel_callback: "https://yourdomain.com/cancel",
    // ... other fields
};
```

### 3. Environment Variables
Create `.env` file for sensitive data:
```
MERCHANT_ID=your_merchant_id
SECRET_KEY=your_secret_key
DB_PATH=./transactions.db
```

Update `GiyaPayButtonTest.html` to use environment variables or secure configuration.

### 4. Database Considerations
For production, consider upgrading from SQLite to PostgreSQL or MySQL:

```javascript
// Example for PostgreSQL
const { Pool } = require('pg');
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});
```

## 🔒 Security Recommendations

### 1. HTTPS Configuration
Always use HTTPS in production. Configure SSL certificate:

```javascript
const https = require('https');
const fs = require('fs');

const options = {
    key: fs.readFileSync('path/to/private-key.pem'),
    cert: fs.readFileSync('path/to/certificate.pem')
};

https.createServer(options, app).listen(443);
```

### 2. Environment Variables
Never commit sensitive data. Use environment variables:

```javascript
const merchantId = process.env.MERCHANT_ID || "mmmda";
const secretKey = process.env.SECRET_KEY || "your_secret_key";
```

### 3. CORS Configuration
Update CORS for production:

```javascript
app.use(cors({
    origin: ['https://yourdomain.com', 'https://pay.giyapay.com'],
    credentials: true
}));
```

## 📊 Monitoring & Maintenance

### 1. Process Management with PM2
```bash
# Start application
pm2 start server.js --name "giyapay-manager"

# Monitor
pm2 monit

# View logs
pm2 logs giyapay-manager

# Restart
pm2 restart giyapay-manager
```

### 2. Database Backup
```bash
# Create backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
cp transactions.db "backups/transactions_backup_$DATE.db"
```

### 3. Log Rotation
Configure log rotation to prevent disk space issues:

```javascript
const winston = require('winston');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' })
    ]
});
```

## 🌐 Domain & DNS Setup

### 1. Point Domain to Server
```
A Record: yourdomain.com → Your_Server_IP
CNAME: www → yourdomain.com
```

### 2. Reverse Proxy with Nginx
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📝 Quick Commands Reference

```bash
# Check if app is running
curl http://localhost:3000

# View application logs
tail -f /path/to/app/logs/app.log

# Restart application
pm2 restart giyapay-manager

# Check server resources
htop
df -h

# Test database
sqlite3 transactions.db ".tables"
```

## 🆘 Troubleshooting

### Common Issues:

1. **Port already in use**
   ```bash
   sudo lsof -i :3000
   sudo kill -9 PID
   ```

2. **Permission denied**
   ```bash
   sudo chown -R $USER:$USER /path/to/app
   chmod +x server.js
   ```

3. **Database locked**
   ```bash
   sudo fuser transactions.db
   sudo kill PID
   ```

4. **npm install fails**
   ```bash
   rm -rf node_modules
   rm package-lock.json
   npm cache clean --force
   npm install
   ```

## 📞 Support

For additional help:
- Check server logs: `pm2 logs`
- Monitor resources: `pm2 monit`
- Test locally first: `npm start`
- Verify all callback URLs are updated

---

**Note**: Always test your deployment in a staging environment before going live!

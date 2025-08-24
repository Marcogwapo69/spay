# GiyaPay Transaction Manager - cPanel Deployment Guide

## 📋 Prerequisites

Before deploying to cPanel, ensure your hosting provider supports:

1. **Node.js** (most modern cPanel hosts support this)
2. **File Manager** or **FTP access**
3. **Terminal/SSH access** (recommended but not always required)
4. **Subdomain creation** (optional)

## 🔍 Check Node.js Support

### Step 1: Verify Node.js is Available
1. Login to **cPanel**
2. Look for **"Node.js"** or **"Node.js Selector"** in the Software section
3. If not available, contact your hosting provider

### Step 2: Check Node.js Version
1. Go to **cPanel → Node.js**
2. Check available versions (preferably 14+ or 18+)

## 📁 File Upload Methods

### Method 1: Using cPanel File Manager (Recommended)

#### Step 1: Create Application Directory
1. Go to **cPanel → File Manager**
2. Navigate to **public_html** (for main domain) or **public_html/subdomain** (for subdomain)
3. Create a new folder: **"giyapay-manager"** or your preferred name
4. Enter the folder

#### Step 2: Upload Files
Upload these files to your application directory:
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

**How to upload:**
1. Click **"Upload"** in File Manager
2. Select all your files
3. Wait for upload to complete
4. Click **"Go Back to [folder]"**

### Method 2: Using FTP Client (FileZilla, WinSCP)

#### FTP Settings:
- **Host**: Your domain or server IP
- **Username**: Your cPanel username
- **Password**: Your cPanel password
- **Port**: 21 (or 22 for SFTP)

1. Connect via FTP
2. Navigate to **public_html/your-app-folder**
3. Upload all files

## ⚙️ Configure Node.js in cPanel

### Step 1: Create Node.js App
1. Go to **cPanel → Node.js**
2. Click **"Create Application"**
3. Fill in details:
   - **Node.js Version**: Select latest (18.x recommended)
   - **Application Mode**: Production
   - **Application Root**: `/public_html/giyapay-manager` (or your folder path)
   - **Application URL**: Choose your domain/subdomain
   - **Application Startup File**: `server.js`

### Step 2: Configure Environment Variables (Optional)
1. In Node.js app settings, scroll to **"Environment Variables"**
2. Add variables:
   ```
   PORT=3000
   NODE_ENV=production
   ```

## 📦 Install Dependencies

### Method 1: Using cPanel Node.js Interface
1. Go to **cPanel → Node.js**
2. Click on your application name
3. In **"Package Installation"** section:
   - Enter package names one by one:
     - `express`
     - `cors`
     - `sqlite3`
   - Click **"Install"** for each

### Method 2: Using Terminal (if available)
1. Go to **cPanel → Terminal** (if available)
2. Navigate to your app directory:
   ```bash
   cd public_html/giyapay-manager
   ```
3. Install dependencies:
   ```bash
   npm install
   ```

### Method 3: Upload node_modules (if no terminal access)
1. On your local computer, run `npm install`
2. Zip the entire `node_modules` folder
3. Upload and extract in cPanel File Manager

## 🔧 Update Configuration for cPanel

### Step 1: Update server.js for cPanel
Edit `server.js` to work with cPanel environment:

```javascript
// At the top of server.js, update the port configuration
const PORT = process.env.PORT || 3000;

// Change the listen function at the bottom
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Application URL: ${process.env.APPLICATION_URL || 'http://localhost:' + PORT}`);
});
```

### Step 2: Update Callback URLs
Edit `GiyaPayButtonTest.html` and replace localhost URLs:

**Change from:**
```javascript
const fields = {
    success_callback: "http://localhost:3000/success",
    error_callback: "http://localhost:3000/error",
    cancel_callback: "http://localhost:3000/cancel",
    // ...
};
```

**Change to:**
```javascript
const fields = {
    success_callback: "https://yourdomain.com/success",
    error_callback: "https://yourdomain.com/error",
    cancel_callback: "https://yourdomain.com/cancel",
    // ...
};
```

## 🚀 Start the Application

### Method 1: Using cPanel Node.js Interface
1. Go to **cPanel → Node.js**
2. Find your application
3. Click **"Start"** button
4. Wait for status to show **"Running"**

### Method 2: Using Terminal
```bash
cd public_html/giyapay-manager
node server.js
```

## 🌐 Domain/Subdomain Setup

### Option 1: Main Domain
- Application will be accessible at: `https://yourdomain.com`
- Upload files to: `public_html/`

### Option 2: Subdomain (Recommended)
1. Go to **cPanel → Subdomains**
2. Create subdomain: `pay.yourdomain.com`
3. Set document root: `public_html/giyapay-manager`
4. Application accessible at: `https://pay.yourdomain.com`

### Option 3: Directory
- Application accessible at: `https://yourdomain.com/giyapay-manager`
- Upload files to: `public_html/giyapay-manager/`

## 🔒 Security Configuration

### Step 1: File Permissions
Set correct permissions via File Manager:
- **Folders**: 755
- **Files**: 644
- **server.js**: 755 (executable)

### Step 2: Hide Sensitive Files
Create `.htaccess` file in your app directory:
```apache
# Deny access to sensitive files
<Files "package.json">
    Order allow,deny
    Deny from all
</Files>

<Files "server.js">
    Order allow,deny
    Deny from all
</Files>

<Files "*.db">
    Order allow,deny
    Deny from all
</Files>
```

### Step 3: Force HTTPS
Add to `.htaccess`:
```apache
# Force HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

## 📊 Monitoring & Maintenance

### Check Application Status
1. Go to **cPanel → Node.js**
2. View application status and logs
3. Use **"Restart"** if needed

### View Logs
1. In Node.js app settings
2. Click **"View Logs"** or **"Error Logs"**
3. Check for any errors

### Database Management
1. Access via **cPanel → File Manager**
2. Navigate to `transactions.db`
3. Download for backup regularly

## 🆘 Common cPanel Issues & Solutions

### Issue 1: "Application failed to start"
**Solution:**
1. Check Node.js logs in cPanel
2. Verify all dependencies are installed
3. Check file permissions
4. Ensure `server.js` path is correct

### Issue 2: "npm command not found"
**Solution:**
1. Use cPanel's Node.js package installer instead
2. Or contact hosting provider for npm access

### Issue 3: "Port already in use"
**Solution:**
1. cPanel automatically assigns ports
2. Don't specify a fixed port, use `process.env.PORT`

### Issue 4: "Cannot access application"
**Solution:**
1. Check if app is running in cPanel → Node.js
2. Verify domain/subdomain configuration
3. Check .htaccess rules

### Issue 5: "Database permission denied"
**Solution:**
1. Set database file permissions to 664
2. Set app folder permissions to 755

## 📝 cPanel Deployment Checklist

- [ ] Verify Node.js support with hosting provider
- [ ] Upload all application files
- [ ] Create Node.js application in cPanel
- [ ] Install dependencies (express, cors, sqlite3)
- [ ] Update callback URLs from localhost to your domain
- [ ] Configure file permissions
- [ ] Start the application
- [ ] Test all features (payment generation, transaction list)
- [ ] Set up regular database backups
- [ ] Configure HTTPS (usually automatic with cPanel)

## 📞 Support Resources

### If you encounter issues:
1. **Check cPanel documentation** for your hosting provider
2. **Contact hosting support** - they can help with Node.js setup
3. **Check application logs** in cPanel → Node.js
4. **Test locally first** before deploying

### Hosting Providers with Good cPanel + Node.js Support:
- **A2 Hosting**
- **SiteGround**
- **InMotion Hosting**
- **Bluehost** (newer plans)
- **Hostinger**

---

**Important**: Not all cPanel hosts support Node.js. If your current host doesn't support it, you may need to upgrade your plan or switch to a host that supports Node.js applications.

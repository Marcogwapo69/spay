# GiyaPay Transaction Manager - cPanel Deployment Instructions 
 
## 🚀 Quick Upload Instructions 
 
### Method 1: cPanel File Manager (Recommended) 
1. **Login to cPanel** 
2. **Go to File Manager** 
3. **Navigate to public_html** 
4. **Create folder: giyapay-manager** 
5. **Enter the giyapay-manager folder** 
6. **Upload all files from this cpanel_deploy folder** 
7. **Extract if you uploaded as ZIP** 
 
### Method 2: FTP Upload 
1. **Use FTP client** (FileZilla, WinSCP) 
2. **Connect to your server** 
3. **Navigate to public_html/giyapay-manager** 
4. **Upload all files from this cpanel_deploy folder** 
 
## ⚙️ cPanel Node.js Setup 
1. **Go to cPanel → Node.js** 
2. **Click "Create Application"** 
3. **Use settings from cpanel_config.txt** 
4. **Install packages: express, cors, sqlite3** 
5. **Start the application** 
6. **Test at https://yourdomain.com** 

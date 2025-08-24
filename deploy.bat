@echo off
REM GiyaPay Transaction Manager - One-Click cPanel Deployment (Windows)
REM Usage: deploy.bat

echo 🚀 GiyaPay Transaction Manager - One-Click cPanel Deployment
echo ============================================================

REM Configuration - EDIT THESE VALUES
set DOMAIN=yourdomain.com
set APP_NAME=giyapay-manager
set NODE_VERSION=18
set APP_MODE=production

echo Configuration:
echo Domain: %DOMAIN%
echo App Name: %APP_NAME%
echo Node Version: %NODE_VERSION%
echo.

REM Check if we're in the right directory
if not exist "server.js" (
    echo ❌ server.js not found. Please run this script from your project directory.
    pause
    exit /b 1
)

if not exist "package.json" (
    echo ❌ package.json not found. Please run this script from your project directory.
    pause
    exit /b 1
)

echo ✅ Project files found

REM Create deployment package directory
if exist "cpanel_deploy" rmdir /s /q "cpanel_deploy"
mkdir "cpanel_deploy"
echo ✅ Created deployment package directory

REM Copy files to deployment package
echo.
echo Step 1: Copying application files...

copy "server.js" "cpanel_deploy\" >nul
copy "package.json" "cpanel_deploy\" >nul
copy "GiyaPayButtonTest.html" "cpanel_deploy\" >nul 2>nul
copy "GiyaPayStatusFrontend.html" "cpanel_deploy\" >nul 2>nul
copy "success.html" "cpanel_deploy\" >nul 2>nul
copy "error.html" "cpanel_deploy\" >nul 2>nul
copy "cancel.html" "cpanel_deploy\" >nul 2>nul
copy "giyapay-backend.js" "cpanel_deploy\" >nul 2>nul

echo ✅ Core files copied

REM Copy any additional HTML files
for %%f in (*.html) do (
    if not "%%f"=="GiyaPayButtonTest.html" if not "%%f"=="GiyaPayStatusFrontend.html" if not "%%f"=="success.html" if not "%%f"=="error.html" if not "%%f"=="cancel.html" (
        copy "%%f" "cpanel_deploy\" >nul 2>nul
        echo ✅ Copied additional file: %%f
    )
)

echo.
echo Step 2: Creating production configuration...

REM Update server.js for cPanel
powershell -Command ^
"$content = Get-Content 'cpanel_deploy\server.js' -Raw; ^
if (-not $content.Contains('process.env.PORT')) { ^
    $content = $content -replace 'const PORT = \d+;?', 'const PORT = process.env.PORT ^|^| 3000;'; ^
    Write-Host '✅ Updated PORT configuration'; ^
} ^
$content = $content -replace 'app\.listen\(PORT,.*?\{[\s\S]*?\}\);', 'app.listen(PORT, () => { console.log(`Server running on port ${PORT}`); console.log(`Application URL: ${process.env.APPLICATION_URL ^|^| \"http://localhost:\" + PORT}`); });'; ^
Set-Content 'cpanel_deploy\server.js' $content; ^
Write-Host '✅ Server configuration updated for cPanel';"

REM Update callback URLs
powershell -Command ^
"if (Test-Path 'cpanel_deploy\GiyaPayButtonTest.html') { ^
    $content = Get-Content 'cpanel_deploy\GiyaPayButtonTest.html' -Raw; ^
    $content = $content -replace 'http://localhost:3000', 'https://%DOMAIN%'; ^
    Set-Content 'cpanel_deploy\GiyaPayButtonTest.html' $content; ^
    Write-Host '✅ Updated callback URLs to https://%DOMAIN%'; ^
}"

echo.
echo Step 3: Creating security configuration...

REM Create .htaccess
echo # Security configuration for GiyaPay Transaction Manager > "cpanel_deploy\.htaccess"
echo. >> "cpanel_deploy\.htaccess"
echo # Deny access to sensitive files >> "cpanel_deploy\.htaccess"
echo ^<Files "package.json"^> >> "cpanel_deploy\.htaccess"
echo     Order allow,deny >> "cpanel_deploy\.htaccess"
echo     Deny from all >> "cpanel_deploy\.htaccess"
echo ^</Files^> >> "cpanel_deploy\.htaccess"
echo. >> "cpanel_deploy\.htaccess"
echo ^<Files "server.js"^> >> "cpanel_deploy\.htaccess"
echo     Order allow,deny >> "cpanel_deploy\.htaccess"
echo     Deny from all >> "cpanel_deploy\.htaccess"
echo ^</Files^> >> "cpanel_deploy\.htaccess"
echo. >> "cpanel_deploy\.htaccess"
echo ^<Files "*.db"^> >> "cpanel_deploy\.htaccess"
echo     Order allow,deny >> "cpanel_deploy\.htaccess"
echo     Deny from all >> "cpanel_deploy\.htaccess"
echo ^</Files^> >> "cpanel_deploy\.htaccess"
echo. >> "cpanel_deploy\.htaccess"
echo # Force HTTPS >> "cpanel_deploy\.htaccess"
echo RewriteEngine On >> "cpanel_deploy\.htaccess"
echo RewriteCond %%{HTTPS} off >> "cpanel_deploy\.htaccess"
echo RewriteRule ^^(.*)$ https://%%{HTTP_HOST}%%{REQUEST_URI} [L,R=301] >> "cpanel_deploy\.htaccess"

echo ✅ Created .htaccess security configuration

echo.
echo Step 4: Creating cPanel configuration helper...

REM Create cPanel configuration file
echo GiyaPay Transaction Manager - cPanel Configuration > "cpanel_deploy\cpanel_config.txt"
echo. >> "cpanel_deploy\cpanel_config.txt"
echo Use these settings when creating your Node.js app in cPanel: >> "cpanel_deploy\cpanel_config.txt"
echo. >> "cpanel_deploy\cpanel_config.txt"
echo Application Details: >> "cpanel_deploy\cpanel_config.txt"
echo - Node.js Version: %NODE_VERSION% (or latest available) >> "cpanel_deploy\cpanel_config.txt"
echo - Application Mode: %APP_MODE% >> "cpanel_deploy\cpanel_config.txt"
echo - Application Root: /public_html/%APP_NAME% >> "cpanel_deploy\cpanel_config.txt"
echo - Application URL: https://%DOMAIN% >> "cpanel_deploy\cpanel_config.txt"
echo - Application Startup File: server.js >> "cpanel_deploy\cpanel_config.txt"
echo. >> "cpanel_deploy\cpanel_config.txt"
echo Environment Variables (optional): >> "cpanel_deploy\cpanel_config.txt"
echo - NODE_ENV: production >> "cpanel_deploy\cpanel_config.txt"
echo - PORT: (leave empty, cPanel will auto-assign) >> "cpanel_deploy\cpanel_config.txt"
echo. >> "cpanel_deploy\cpanel_config.txt"
echo Required Packages to Install: >> "cpanel_deploy\cpanel_config.txt"
echo 1. express >> "cpanel_deploy\cpanel_config.txt"
echo 2. cors >> "cpanel_deploy\cpanel_config.txt"
echo 3. sqlite3 >> "cpanel_deploy\cpanel_config.txt"
echo. >> "cpanel_deploy\cpanel_config.txt"
echo After deployment, your application will be available at: >> "cpanel_deploy\cpanel_config.txt"
echo - Main site: https://%DOMAIN% >> "cpanel_deploy\cpanel_config.txt"
echo - Payment generator: https://%DOMAIN%/GiyaPayButtonTest.html >> "cpanel_deploy\cpanel_config.txt"
echo - Transaction list: https://%DOMAIN%/all-transactions >> "cpanel_deploy\cpanel_config.txt"

echo ✅ Created cPanel configuration helper

echo.
echo Step 5: Creating deployment instructions...

REM Create deployment instructions
echo # GiyaPay Transaction Manager - cPanel Deployment Instructions > "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo. >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo ## 🚀 Quick Upload Instructions >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo. >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo ### Method 1: cPanel File Manager (Recommended) >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 1. **Login to cPanel** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 2. **Go to File Manager** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 3. **Navigate to public_html** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 4. **Create folder: %APP_NAME%** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 5. **Enter the %APP_NAME% folder** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 6. **Upload all files from this cpanel_deploy folder** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 7. **Extract if you uploaded as ZIP** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo. >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo ### Method 2: FTP Upload >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 1. **Use FTP client** (FileZilla, WinSCP) >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 2. **Connect to your server** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 3. **Navigate to public_html/%APP_NAME%** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 4. **Upload all files from this cpanel_deploy folder** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo. >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo ## ⚙️ cPanel Node.js Setup >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 1. **Go to cPanel → Node.js** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 2. **Click "Create Application"** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 3. **Use settings from cpanel_config.txt** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 4. **Install packages: express, cors, sqlite3** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 5. **Start the application** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"
echo 6. **Test at https://%DOMAIN%** >> "cpanel_deploy\UPLOAD_INSTRUCTIONS.md"

echo ✅ Created deployment instructions

echo.
echo Step 6: Creating ZIP package for easy upload...

powershell -Command "Compress-Archive -Path 'cpanel_deploy\*' -DestinationPath 'GiyaPay_cPanel_Deploy.zip' -Force"

if exist "GiyaPay_cPanel_Deploy.zip" (
    echo ✅ Created ZIP package: GiyaPay_cPanel_Deploy.zip
) else (
    echo ⚠️ Could not create ZIP package, but files are ready in cpanel_deploy folder
)

echo.
echo 🎉 ONE-CLICK DEPLOYMENT PACKAGE CREATED SUCCESSFULLY! 🎉
echo.
echo 📁 Deployment files ready in: cpanel_deploy\
echo 📦 ZIP package ready: GiyaPay_cPanel_Deploy.zip
echo 📋 Upload instructions: cpanel_deploy\UPLOAD_INSTRUCTIONS.md
echo 📄 cPanel config: cpanel_deploy\cpanel_config.txt
echo.
echo 🔧 Next Steps:
echo 1. Upload files to your cPanel (use ZIP or folder)
echo 2. Follow instructions in UPLOAD_INSTRUCTIONS.md
echo 3. Create Node.js app in cPanel using cpanel_config.txt
echo 4. Install packages: express, cors, sqlite3
echo 5. Start your application
echo 6. Test at https://%DOMAIN%
echo.
echo ✅ Your GiyaPay Transaction Manager is ready for cPanel deployment!
echo.
pause

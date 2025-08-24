#!/bin/bash

# GiyaPay Transaction Manager - One-Click cPanel Deployment Script
# Author: Auto-generated for easy cPanel deployment
# Usage: bash deploy.sh

echo "🚀 GiyaPay Transaction Manager - One-Click cPanel Deployment"
echo "============================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - EDIT THESE VALUES
DOMAIN="yourdomain.com"                    # Change to your domain
APP_NAME="giyapay-manager"                 # Your app folder name
NODE_VERSION="18"                          # Node.js version (14, 16, 18)
APP_MODE="production"                      # production or development
PUBLIC_HTML_PATH="$HOME/public_html"       # Usually this is correct
APP_PATH="$PUBLIC_HTML_PATH/$APP_NAME"

echo -e "${BLUE}Configuration:${NC}"
echo -e "Domain: ${GREEN}$DOMAIN${NC}"
echo -e "App Name: ${GREEN}$APP_NAME${NC}"
echo -e "Node Version: ${GREEN}$NODE_VERSION${NC}"
echo -e "App Path: ${GREEN}$APP_PATH${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print warning message
print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Step 1: Check prerequisites
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"

# Check if we're in the right directory
if [ ! -f "server.js" ]; then
    print_error "server.js not found. Please run this script from your project directory."
    exit 1
fi

if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from your project directory."
    exit 1
fi

print_success "Project files found"

# Check if node is available
if command_exists node; then
    NODE_CURRENT=$(node --version)
    print_success "Node.js is available: $NODE_CURRENT"
else
    print_warning "Node.js not found in PATH. Will try to use cPanel's Node.js selector."
fi

# Check if npm is available
if command_exists npm; then
    NPM_CURRENT=$(npm --version)
    print_success "npm is available: $NPM_CURRENT"
else
    print_warning "npm not found in PATH. Will try to use cPanel's package manager."
fi

# Step 2: Create application directory
echo -e "\n${BLUE}Step 2: Creating application directory...${NC}"

if [ -d "$APP_PATH" ]; then
    print_warning "Directory $APP_PATH already exists. Backing up..."
    mv "$APP_PATH" "${APP_PATH}_backup_$(date +%Y%m%d_%H%M%S)"
fi

mkdir -p "$APP_PATH"
print_success "Created directory: $APP_PATH"

# Step 3: Copy files
echo -e "\n${BLUE}Step 3: Copying application files...${NC}"

# List of files to copy
FILES=(
    "server.js"
    "package.json"
    "GiyaPayButtonTest.html"
    "GiyaPayStatusFrontend.html"
    "success.html"
    "error.html"
    "cancel.html"
    "giyapay-backend.js"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$APP_PATH/"
        print_success "Copied $file"
    else
        print_warning "File $file not found, skipping..."
    fi
done

# Copy any additional HTML files
for html_file in *.html; do
    if [ -f "$html_file" ] && [[ ! " ${FILES[@]} " =~ " ${html_file} " ]]; then
        cp "$html_file" "$APP_PATH/"
        print_success "Copied additional file: $html_file"
    fi
done

# Step 4: Update configuration files
echo -e "\n${BLUE}Step 4: Updating configuration for production...${NC}"

# Update server.js for cPanel
cat > "$APP_PATH/server_update.js" << 'EOF'
// Auto-generated server.js updates for cPanel deployment
const fs = require('fs');

let serverContent = fs.readFileSync('server.js', 'utf8');

// Update port configuration
if (!serverContent.includes('process.env.PORT')) {
    serverContent = serverContent.replace(
        /const PORT = \d+;?/,
        'const PORT = process.env.PORT || 3000;'
    );
    console.log('✅ Updated PORT configuration');
}

// Update listen function
if (!serverContent.includes('process.env.APPLICATION_URL')) {
    serverContent = serverContent.replace(
        /app\.listen\(PORT,.*?\{[\s\S]*?\}\);/,
        `app.listen(PORT, () => {
    console.log(\`Server running on port \${PORT}\`);
    console.log(\`Application URL: \${process.env.APPLICATION_URL || 'http://localhost:' + PORT}\`);
});`
    );
    console.log('✅ Updated listen function');
}

fs.writeFileSync('server.js', serverContent);
console.log('✅ Server configuration updated for cPanel');
EOF

cd "$APP_PATH"
node server_update.js
rm server_update.js
cd - > /dev/null

print_success "Updated server.js for cPanel environment"

# Update callback URLs in GiyaPayButtonTest.html
if [ -f "$APP_PATH/GiyaPayButtonTest.html" ]; then
    sed -i.bak "s|http://localhost:3000|https://$DOMAIN|g" "$APP_PATH/GiyaPayButtonTest.html"
    rm "$APP_PATH/GiyaPayButtonTest.html.bak" 2>/dev/null
    print_success "Updated callback URLs to https://$DOMAIN"
fi

# Step 5: Create .htaccess for security
echo -e "\n${BLUE}Step 5: Creating security configuration...${NC}"

cat > "$APP_PATH/.htaccess" << 'EOF'
# Security configuration for GiyaPay Transaction Manager

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

<Files "*.log">
    Order allow,deny
    Deny from all
</Files>

# Force HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Prevent directory browsing
Options -Indexes
EOF

print_success "Created .htaccess security configuration"

# Step 6: Set file permissions
echo -e "\n${BLUE}Step 6: Setting file permissions...${NC}"

chmod 755 "$APP_PATH"
chmod 644 "$APP_PATH"/*.html "$APP_PATH"/*.json "$APP_PATH"/.htaccess 2>/dev/null
chmod 755 "$APP_PATH/server.js" 2>/dev/null

print_success "Set appropriate file permissions"

# Step 7: Install dependencies
echo -e "\n${BLUE}Step 7: Installing dependencies...${NC}"

cd "$APP_PATH"

# Try npm install first
if command_exists npm; then
    print_info "Installing dependencies with npm..."
    npm install
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_warning "npm install failed. You may need to install dependencies manually in cPanel."
    fi
else
    print_warning "npm not available. Please install dependencies manually in cPanel Node.js interface:"
    echo -e "${YELLOW}Required packages: express, cors, sqlite3${NC}"
fi

cd - > /dev/null

# Step 8: Create startup script
echo -e "\n${BLUE}Step 8: Creating startup script...${NC}"

cat > "$APP_PATH/start.sh" << EOF
#!/bin/bash
# GiyaPay Manager Startup Script
cd "$APP_PATH"
node server.js
EOF

chmod +x "$APP_PATH/start.sh"
print_success "Created startup script"

# Step 9: Create cPanel configuration helper
echo -e "\n${BLUE}Step 9: Creating cPanel configuration helper...${NC}"

cat > "$APP_PATH/cpanel_config.txt" << EOF
GiyaPay Transaction Manager - cPanel Configuration

Use these settings when creating your Node.js app in cPanel:

Application Details:
- Node.js Version: $NODE_VERSION (or latest available)
- Application Mode: $APP_MODE
- Application Root: $APP_PATH
- Application URL: https://$DOMAIN
- Application Startup File: server.js

Environment Variables (optional):
- NODE_ENV: production
- PORT: (leave empty, cPanel will auto-assign)

Required Packages to Install:
1. express
2. cors  
3. sqlite3

After deployment, your application will be available at:
- Main site: https://$DOMAIN
- Payment generator: https://$DOMAIN/GiyaPayButtonTest.html
- Transaction list: https://$DOMAIN/all-transactions

Next Steps:
1. Go to cPanel → Node.js
2. Click "Create Application"
3. Use the settings above
4. Install the required packages
5. Start the application
6. Test all functionality
EOF

print_success "Created cPanel configuration helper"

# Step 10: Create deployment summary
echo -e "\n${BLUE}Step 10: Creating deployment summary...${NC}"

cat > "$APP_PATH/DEPLOYMENT_SUMMARY.md" << EOF
# GiyaPay Transaction Manager - Deployment Summary

## ✅ Deployment Completed Successfully!

### Files Deployed:
- All application files copied to: \`$APP_PATH\`
- Configuration updated for production
- Security .htaccess created
- File permissions set correctly

### 🔧 Manual Steps Required in cPanel:

1. **Create Node.js Application:**
   - Go to cPanel → Node.js
   - Click "Create Application"
   - Use settings from \`cpanel_config.txt\`

2. **Install Dependencies:**
   - In Node.js app settings, install these packages:
     - express
     - cors
     - sqlite3

3. **Start Application:**
   - Click "Start" in Node.js interface

### 🌐 Application URLs:
- Main Homepage: https://$DOMAIN
- Payment Generator: https://$DOMAIN/GiyaPayButtonTest.html
- Transaction List: https://$DOMAIN/all-transactions

### 📋 Checklist:
- [ ] Node.js app created in cPanel
- [ ] Dependencies installed
- [ ] Application started
- [ ] HTTPS working
- [ ] Payment generation tested
- [ ] Transaction list accessible

### 🆘 If Issues Occur:
1. Check Node.js logs in cPanel
2. Verify all dependencies are installed
3. Ensure domain is pointing to correct directory
4. Contact hosting support if needed

### 📁 Important Files:
- \`server.js\` - Main application file
- \`cpanel_config.txt\` - cPanel setup instructions
- \`.htaccess\` - Security configuration
- \`start.sh\` - Startup script (for terminal use)

Deployment completed on: $(date)
EOF

print_success "Created deployment summary"

# Final output
echo ""
echo -e "${GREEN}🎉 ONE-CLICK DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉${NC}"
echo ""
echo -e "${BLUE}📁 Files deployed to:${NC} $APP_PATH"
echo -e "${BLUE}📋 Next steps:${NC} Check $APP_PATH/cpanel_config.txt"
echo -e "${BLUE}📄 Full summary:${NC} Check $APP_PATH/DEPLOYMENT_SUMMARY.md"
echo ""
echo -e "${YELLOW}🔧 Manual cPanel Steps Required:${NC}"
echo "1. Go to cPanel → Node.js"
echo "2. Create new application using settings in cpanel_config.txt"
echo "3. Install packages: express, cors, sqlite3"
echo "4. Start the application"
echo "5. Test at https://$DOMAIN"
echo ""
echo -e "${GREEN}Your GiyaPay Transaction Manager is ready for cPanel deployment!${NC}"

exit 0

// Database Test Script for cPanel
// Add this temporarily to your server.js to test database

// Add this route after your existing routes for testing
app.get('/test-db', (req, res) => {
    console.log('Testing database connection...');
    
    // Test if database file exists and is accessible
    const fs = require('fs');
    const dbPath = path.join(__dirname, 'transactions.db');
    
    console.log('Database path:', dbPath);
    console.log('Database exists:', fs.existsSync(dbPath));
    
    // Test database connection
    db.all('SELECT name FROM sqlite_master WHERE type="table"', [], (err, tables) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ 
                error: 'Database connection failed', 
                details: err.message,
                dbPath: dbPath,
                dbExists: fs.existsSync(dbPath)
            });
        }
        
        console.log('Database tables:', tables);
        
        // Test the transactions table
        db.all('SELECT COUNT(*) as count FROM transactions', [], (err2, count) => {
            if (err2) {
                console.error('Transactions table error:', err2);
                return res.json({
                    status: 'Database connected but transactions table has issues',
                    tables: tables,
                    error: err2.message,
                    dbPath: dbPath
                });
            }
            
            res.json({
                status: 'Database working correctly',
                tables: tables,
                transactionCount: count[0].count,
                dbPath: dbPath,
                timestamp: new Date().toISOString()
            });
        });
    });
});

// Remove this route after testing!

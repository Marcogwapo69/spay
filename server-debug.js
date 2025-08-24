const express = require('express');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Simplified database setup with better error handling
const dbPath = path.join(__dirname, 'transactions.db');
console.log('Database path:', dbPath);

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Database connection error:', err.message);
    } else {
        console.log('Connected to SQLite database');
    }
});

// Create table if it doesn't exist
db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchantId TEXT,
        referenceNumber TEXT,
        status TEXT,
        paid INTEGER,
        amount REAL,
        name TEXT,
        description TEXT,
        checkedAt TEXT
    )`, (err) => {
        if (err) {
            console.error('Error creating table:', err.message);
        } else {
            console.log('Transactions table ready');
        }
    });
});

// Simple test route
app.get('/', (req, res) => {
    res.json({ 
        message: 'GiyaPay Transaction Manager is running!',
        timestamp: new Date().toISOString(),
        routes: [
            '/ - This test page',
            '/transactions - JSON API',
            '/all-transactions - HTML view',
            '/test-db - Database test'
        ]
    });
});

// Database test route
app.get('/test-db', (req, res) => {
    console.log('Testing database...');
    
    db.all('SELECT COUNT(*) as count FROM transactions', [], (err, result) => {
        if (err) {
            console.error('Database test error:', err.message);
            return res.status(500).json({ 
                error: 'Database test failed', 
                details: err.message 
            });
        }
        
        res.json({
            status: 'Database working',
            transactionCount: result[0].count,
            timestamp: new Date().toISOString()
        });
    });
});

// Original transactions route with better error handling
app.get('/transactions', (req, res) => {
    console.log('Fetching transactions...');
    
    db.all('SELECT * FROM transactions ORDER BY checkedAt DESC', [], (err, rows) => {
        if (err) {
            console.error('Transactions fetch error:', err.message);
            return res.status(500).json({ 
                error: 'Failed to fetch transactions', 
                details: err.message 
            });
        }
        
        console.log(`Found ${rows.length} transactions`);
        res.json(rows);
    });
});

// Serve static files
app.use(express.static(__dirname));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Test the following URLs:`);
    console.log(`- Homepage: http://localhost:${PORT}/`);
    console.log(`- Database test: http://localhost:${PORT}/test-db`);
    console.log(`- Transactions: http://localhost:${PORT}/transactions`);
});

const express = require('express');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// SQLite database setup
const dbPath = path.join(__dirname, 'transactions.db');
const db = new sqlite3.Database(dbPath);
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
    )`);
    
    // Add new columns to existing table if they don't exist
    db.run(`ALTER TABLE transactions ADD COLUMN amount REAL`, () => {});
    db.run(`ALTER TABLE transactions ADD COLUMN name TEXT`, () => {});
    db.run(`ALTER TABLE transactions ADD COLUMN description TEXT`, () => {});
});

// Root route - Welcome page with navigation
app.get('/', (req, res) => {
    const html = `
    <html>
    <head>
        <title>GiyaPay Transaction Manager</title>
        <style>
            body { font-family: sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #333; text-align: center; }
            .links { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 30px; }
            .link-card { background: #007bff; color: white; padding: 20px; border-radius: 8px; text-decoration: none; text-align: center; transition: background 0.3s; }
            .link-card:hover { background: #0056b3; text-decoration: none; color: white; }
            .link-card h3 { margin: 0 0 10px 0; }
            .link-card p { margin: 0; opacity: 0.9; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🏦 Transaction Manager</h1>
            
            <div class="links">
                <a href="/GiyaPayButtonTest.html" class="link-card">
                    <h3>💳 Generate Payment</h3>
                    <p>Create new payment buttons</p>
                </a>
                
                <a href="/all-transactions" class="link-card">
                    <h3>📊 View All Transactions</h3>
                    <p>See transactions in table format</p>
                </a>
            </div>
        </div>
    </body>
    </html>`;
    res.send(html);
});

// HTML page to list all transactions from SQLite
app.get('/all-transactions', (req, res) => {
    db.all('SELECT * FROM transactions ORDER BY checkedAt DESC', [], (err, rows) => {
        let html = `<html><head><title>All Transactions</title><style>body{font-family:sans-serif;margin:20px;}table{border-collapse:collapse;width:100%;}th,td{border:1px solid #ccc;padding:8px;text-align:left;}th{background:#eee;}</style></head><body><h2>All Transactions</h2>`;
        if (err || rows.length === 0) {
            html += '<p>No transactions found.</p>';
        } else {
            html += '<table><tr><th>Name</th><th>Amount</th><th>Description</th><th>Payment Status</th><th>Checked At</th></tr>';
            for (const tx of rows) {
                const amount = tx.amount ? `₱${tx.amount.toFixed(2)}` : 'N/A';
                const paymentStatus = tx.paid ? '<span style="color:green;font-weight:bold;">✅ PAID</span>' : '<span style="color:red;font-weight:bold;">❌ UNPAID</span>';
                const rowStyle = tx.paid ? '' : 'style="background-color:#ffe6e6;"';
                html += `<tr ${rowStyle}><td>${tx.name||'N/A'}</td><td>${amount}</td><td>${tx.description||'E-WALLET PAYMENT'}</td><td>${paymentStatus}</td><td>${tx.checkedAt||''}</td></tr>`;
            }
            html += '</table>';
        }
        html += '</body></html>';
        res.send(html);
    });
});

// JSON endpoint for all transactions from SQLite
app.get('/transactions', (req, res) => {
    db.all('SELECT * FROM transactions ORDER BY checkedAt DESC', [], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json(rows);
    });
});

// Endpoint to add a new transaction
app.post('/add-transaction', (req, res) => {
    const { merchantId, referenceNumber, status, amount, name } = req.body;
    const paid = req.body.paid === true ? 1 : 0; // Default to unpaid (0) unless explicitly set to true
    const description = 'E-WALLET PAYMENT'; // Always set to E-WALLET PAYMENT
    const checkedAt = new Date().toISOString();
    
    db.run(`INSERT INTO transactions (merchantId, referenceNumber, status, paid, amount, name, description, checkedAt) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, 
            [merchantId, referenceNumber, status, paid, amount, name, description, checkedAt], 
            function(err) {
                if (err) {
                    return res.status(500).json({ error: err.message });
                }
                res.json({ 
                    id: this.lastID, 
                    merchantId, 
                    referenceNumber, 
                    status, 
                    paid: paid === 1, 
                    amount,
                    name,
                    description,
                    checkedAt 
                });
            });
});

// Endpoint to store payment details when generating payment
app.post('/store-payment-details', (req, res) => {
    const { order_id, customer_name, amount, merchant_id } = req.body;
    const description = 'E-WALLET PAYMENT';
    const checkedAt = new Date().toISOString();
    
    // Store as unpaid transaction initially
    db.run(`INSERT OR REPLACE INTO transactions (merchantId, referenceNumber, status, paid, amount, name, description, checkedAt) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, 
            [merchant_id, order_id, 'pending', 0, parseFloat(amount) / 100, customer_name, description, checkedAt], 
            function(err) {
                if (err) {
                    console.error('Error storing payment details:', err);
                    return res.status(500).json({ error: err.message });
                }
                console.log('Payment details stored:', { 
                    id: this.lastID, 
                    order_id, 
                    customer_name, 
                    amount: parseFloat(amount) / 100 
                });
                res.json({ 
                    success: true, 
                    id: this.lastID 
                });
            });
});

// Endpoint to update payment status (for callbacks)
app.post('/update-payment-status', (req, res) => {
    const { order_id, status } = req.body;
    const paid = (status === 'success' || status === 'completed') ? 1 : 0;
    const finalStatus = status || 'completed';
    
    db.run(`UPDATE transactions SET status = ?, paid = ? WHERE referenceNumber = ?`, 
            [finalStatus, paid, order_id], 
            function(err) {
                if (err) {
                    console.error('Error updating payment status:', err);
                    return res.status(500).json({ error: err.message });
                }
                console.log('Payment status updated:', { 
                    order_id, 
                    status: finalStatus, 
                    paid: paid === 1,
                    changes: this.changes 
                });
                res.json({ 
                    success: true, 
                    changes: this.changes 
                });
            });
});

// Endpoint to capture payment data from GiyaPay (webhook/callback)
app.post('/capture-payment', (req, res) => {
    const { merchant_id, order_id, amount, currency, customer_name, description, status } = req.body;
    const paid = (status === 'success' || status === 'completed') ? 1 : 0;
    const finalAmount = amount ? parseFloat(amount) / 100 : 0; // Convert from cents to main currency
    const checkedAt = new Date().toISOString();
    
    db.run(`INSERT OR REPLACE INTO transactions (merchantId, referenceNumber, status, paid, amount, name, description, checkedAt) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, 
            [merchant_id, order_id, status || 'pending', paid, finalAmount, customer_name, 'E-WALLET PAYMENT', checkedAt], 
            function(err) {
                if (err) {
                    console.error('Error capturing payment:', err);
                    return res.status(500).json({ error: err.message });
                }
                console.log('Payment captured:', { 
                    id: this.lastID, 
                    merchant_id, 
                    order_id, 
                    customer_name, 
                    amount: finalAmount, 
                    paid: paid === 1 
                });
                res.json({ 
                    success: true, 
                    id: this.lastID 
                });
            });
});

// Endpoint to create a new unpaid transaction (for new orders)
app.post('/create-unpaid-transaction', (req, res) => {
    const { merchantId, referenceNumber, amount, name } = req.body;
    const status = 'pending'; // New transactions start as pending
    const paid = 0; // Always unpaid for new transactions
    const description = 'E-WALLET PAYMENT'; // Always set to E-WALLET PAYMENT
    const checkedAt = new Date().toISOString();
    
    db.run(`INSERT INTO transactions (merchantId, referenceNumber, status, paid, amount, name, description, checkedAt) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, 
            [merchantId, referenceNumber, status, paid, amount, name, description, checkedAt], 
            function(err) {
                if (err) {
                    return res.status(500).json({ error: err.message });
                }
                res.json({ 
                    id: this.lastID, 
                    merchantId, 
                    referenceNumber, 
                    status, 
                    paid: false, 
                    amount,
                    name,
                    description,
                    checkedAt 
                });
            });
});

app.get('/success', (req, res) => {
    res.sendFile(path.join(__dirname, 'success.html'));
});

app.get('/error', (req, res) => {
    res.sendFile(path.join(__dirname, 'error.html'));
});

app.get('/cancel', (req, res) => {
    res.sendFile(path.join(__dirname, 'cancel.html'));
});

// Serve static files (after API routes)
app.use(express.static(__dirname));

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`\nTest URLs:`);
    console.log(`- All Transactions: http://localhost:${PORT}/all-transactions`);
    console.log(`- Transactions API: http://localhost:${PORT}/transactions`);
    console.log(`- Payment Button: http://localhost:${PORT}/GiyaPayButtonTest.html`);
    console.log(`- Transaction Status: http://localhost:${PORT}/GiyaPayStatusFrontend.html`);
});

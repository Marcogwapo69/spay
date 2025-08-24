const express = require('express');
const crypto = require('crypto');
const fetch = require('node-fetch');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/check-transaction', async (req, res) => {
    const { merchantId, referenceNumber, secretKey } = req.body;
    const timestamp = Date.now().toString();
    const nonce = Math.floor(Math.random() * 1e18).toString();

    // Create the string for hashing
    const myStringForHashing = merchantId + referenceNumber + timestamp + nonce + secretKey;
    const signature = crypto.createHash('sha512').update(myStringForHashing).digest('hex');

    // Build the request URL - using sandbox endpoint from documentation
    const url = `https://pay.giyapay.com/api/1.0/transaction/${referenceNumber}?signature=${signature}&merchantId=${merchantId}&timestamp=${timestamp}&nonce=${nonce}&secretKey=${secretKey}`;

    try {
        const response = await fetch(url);
        const data = await response.json();
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

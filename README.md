# GiyaPay Transaction Manager

A modern, responsive HTML-based payment management system integrated with **GiyaPay Standard API**. This application provides a complete payment processing solution with QRPh (InstaPay) support, real-time transaction tracking, and comprehensive payment status management.

## 🌟 Features

### Payment Processing
- **Real GiyaPay API Integration** with your merchant credentials
- **QRPh (InstaPay) Payment Method** - Primary payment option
- **Automatic Signature Generation** using HMAC-SHA256
- **Secure Payment Processing** with proper authentication
- **Fallback Simulation Mode** for development/testing

### Transaction Management
- **Real-time Transaction Tracking** with localStorage persistence
- **Payment Status Updates** via GiyaPay callbacks
- **Reference Number Generation** with 2836 prefix format
- **Transaction History** with filtering and search capabilities
- **Status Monitoring** (pending, completed, failed, cancelled)

### User Experience
- **Responsive Design** - Works on desktop, tablet, and mobile
- **Modern UI/UX** with gradient backgrounds and smooth animations
- **Real-time Updates** for payment status changes
- **Error Handling** with user-friendly messages
- **Multi-page Flow** (payment → processing → success/error/cancel)

## 🔧 GiyaPay API Integration

### Configuration
```javascript
const GIYAPAY_CONFIG = {
    merchantId: "mmmda",
    secretKey: "e7c7bb007d69d5d4444b09e1e5a6437aa9b71a4687afe93bf6a3cfcd0ea03e814d846ceb44c00750a864088edf67e877918aa70bc2d8354122ddc2b8dfcf8da8",
    apiUrl: "https://giyapay.dev.symphco.com/v1"
};
```

### API Endpoints Used
- **POST** `/checkout` - Create payment checkout session
- **Webhooks** - Payment status notifications (success, error, cancel)

### Signature Generation
The application implements HMAC-SHA256 signature generation as required by GiyaPay:
```
data = merchantId + amount + currency + orderId + timestamp + nonce
signature = HMAC-SHA256(data, secretKey)
```

### Payment Flow
1. **Payment Creation** - User fills form, generates reference number
2. **API Request** - Create checkout session with GiyaPay
3. **Redirect** - User redirected to GiyaPay checkout page
4. **Processing** - Payment processed by GiyaPay
5. **Callback** - GiyaPay redirects to success/error/cancel pages
6. **Status Update** - Transaction status updated in localStorage

## 📁 File Structure

```
├── index.html              # Main application page
├── payment.html            # Payment processing with GiyaPay API
├── success.html            # Payment success page (handles GiyaPay callbacks)
├── error.html              # Payment error page (handles GiyaPay callbacks)
├── cancel.html             # Payment cancellation page (handles GiyaPay callbacks)
├── webhook.html            # Webhook handler for testing
├── giyapay-config.html     # API configuration and testing page
└── README.md              # This documentation
```

## 🚀 Getting Started

### 1. Quick Start
1. Open `index.html` in your browser
2. Create a test payment
3. Process payment through GiyaPay integration
4. View transaction status and history

### 2. API Testing
1. Open `giyapay-config.html` for API testing
2. Test signature generation
3. Test API connectivity
4. Create test payments

### 3. Webhook Testing
1. Open `webhook.html` for webhook simulation
2. Simulate payment callbacks
3. Test status updates

## 🔒 Security Features

- **HMAC-SHA256 Signature** verification
- **Secure credential storage** in configuration
- **Input validation** and sanitization
- **CORS-friendly** API requests
- **Error handling** for failed requests

## 📱 Responsive Design

The application is fully responsive and works on:
- **Desktop** (1200px+)
- **Tablet** (768px - 1199px)
- **Mobile** (320px - 767px)

## 🔄 Payment Status Management

### Status Types
- `pending` - Payment initiated, awaiting completion
- `completed` - Payment successful
- `failed` - Payment failed
- `cancelled` - Payment cancelled by user

### Status Updates
- **Automatic updates** via GiyaPay callbacks
- **Manual simulation** for testing
- **Real-time reflection** in transaction list
- **Persistent storage** using localStorage

## 🛠 Development & Testing

### Local Development
1. Serve files using any HTTP server (Live Server, Python, etc.)
2. Use `giyapay-config.html` for API testing
3. Enable fallback simulation for offline testing

### API Testing
```bash
# Test signature generation
curl -X POST "https://giyapay.dev.symphco.com/v1/checkout" \
  -H "Content-Type: application/json" \
  -d '{
    "merchant_id": "mmmda",
    "amount": 10000,
    "currency": "PHP",
    "order_id": "TEST-123",
    "signature": "generated_signature"
  }'
```

### Webhook Testing
Use `webhook.html` to simulate GiyaPay callbacks:
- Success payments
- Failed payments
- Cancelled payments

## 🌐 GiyaPay Integration Details

### Environment
- **Development API**: `https://giyapay.dev.symphco.com/v1`
- **Production API**: `https://giyapay.symphco.com/v1`

### Merchant Details
- **Merchant ID**: `mmmda`
- **Payment Methods**: QRPh (InstaPay)
- **Currency**: PHP (Philippine Peso)

### Callback URLs
- **Success**: `{origin}/success.html`
- **Error**: `{origin}/error.html`
- **Cancel**: `{origin}/cancel.html`

## 📊 Transaction Data Structure

```javascript
{
  referenceNumber: "2836-XXXXXX",
  amount: 100.00,
  description: "Payment description",
  merchant: "Merchant name",
  status: "completed",
  paymentMethod: "QRPh",
  createdAt: "2025-08-25T...",
  completedAt: "2025-08-25T...",
  giyapayData: { /* GiyaPay callback data */ }
}
```

## 🔍 Browser Support

- **Chrome** 60+
- **Firefox** 55+
- **Safari** 11+
- **Edge** 79+

Requires modern browser with Crypto.subtle API support for signature generation.

## 📝 Notes

- **No server required** - Pure frontend application
- **localStorage persistence** - Data stored locally
- **Real API integration** - Uses actual GiyaPay endpoints
- **Fallback mode** - Simulation when API unavailable
- **Mobile optimized** - Touch-friendly interface

## 🤝 Support

For GiyaPay API documentation and support:
- **Documentation**: https://symphco.notion.site/GiyaPay-Standard-API-Documentation-cd7e664391f34f379655cd4630114d71
- **API Support**: Contact GiyaPay team

---

**Version**: 2.0 (HTML + GiyaPay API Integration)  
**Last Updated**: August 25, 2025  
**Environment**: Development Ready

This is a pure frontend application requiring no server setup. Simply open `index.html` in a web browser to start using the application.

## License

MIT License - Feel free to modify and distribute as needed.

# GiyaPay Transaction Manager (HTML Version)

A complete frontend-only payment management system built with pure HTML, CSS, and JavaScript.

## Features

- **Payment Link Generation**: Create payment links with random reference numbers starting with "2836"
- **Transaction Management**: View and track all payment transactions
- **Payment Processing**: Simulated payment flow with multiple payment methods
- **Status Tracking**: Check payment status using reference numbers
- **Responsive Design**: Mobile-friendly interface
- **Local Storage**: All data stored locally in browser

## Files

- `index.html` - Main application with payment creation and transaction management
- `payment.html` - Payment processing page with method selection
- `success.html` - Payment success confirmation page
- `error.html` - Payment error handling page
- `cancel.html` - Payment cancellation page

## How to Use

1. **Open the Application**: Open `index.html` in any modern web browser
2. **Create Payment**: Fill in the payment details and generate a payment link
3. **Process Payment**: Click the generated link to simulate payment processing
4. **View Transactions**: Check all transactions in the "View Transactions" section
5. **Check Status**: Use reference numbers to check payment status

## Payment Methods Supported

- QRPh (QR Philippines) - Primary payment method

## Data Storage

All transaction data is stored locally in your browser using localStorage. Data persists between sessions but is specific to each browser/device.

## Reference Number Format

All reference numbers follow the format: `2836XXXXXXXX` where X represents random digits.

## Browser Compatibility

Works with all modern browsers that support:
- ES6 JavaScript features
- localStorage API
- CSS Grid and Flexbox
- URLSearchParams API

## Development

This is a pure frontend application requiring no server setup. Simply open `index.html` in a web browser to start using the application.

## License

MIT License - Feel free to modify and distribute as needed.

# Money Mouthy Wallet System & Payment Gateway Integration

## Overview

The Money Mouthy app now features a comprehensive wallet system with payment gateway integration, allowing users to:

- **Track Balance**: Real-time wallet balance tracking
- **Add Funds**: Secure payment processing via Stripe integration
- **Withdraw Funds**: Bank account withdrawals with processing status
- **Transaction History**: Complete transaction logging and history
- **Post Payments**: Automatic balance deduction when creating posts

## Features Implemented

### 1. Wallet Service (`lib/services/wallet_service.dart`)

**Core Functionality:**
- Balance management with persistent storage
- Transaction recording and history
- SQLite database for transaction storage
- Integration with payment gateway

**Key Methods:**
- `initialize()` - Initialize wallet service and payment gateway
- `addFunds(amount)` - Add funds via payment gateway
- `deductBalance(amount, description)` - Deduct balance for posts
- `withdrawFunds(amount, bankAccount)` - Process withdrawals
- `getTransactionHistory()` - Retrieve transaction history
- `formatCurrency(amount)` - Format currency display

### 2. Payment Service (`lib/services/payment_service.dart`)

**Payment Gateway Integration:**
- Stripe payment processing (demo mode)
- Payment method creation and management
- Withdrawal processing simulation
- Error handling and validation

**Key Methods:**
- `initialize()` - Initialize Stripe SDK
- `simulateCardPayment()` - Process card payments (demo)
- `processWithdrawal()` - Handle withdrawal requests
- `createPaymentIntent()` - Create Stripe payment intents

### 3. Wallet Screen (`lib/screens/wallet_screen.dart`)

**User Interface Features:**
- Real-time balance display
- Add funds dialog with preset amounts
- Withdrawal dialog with bank account selection
- Transaction history with filtering (All, Income, Expenses)
- Statistics cards showing total earnings and spending

**UI Components:**
- Balance header with gradient design
- Quick action buttons (Add Funds, Withdraw)
- Tabbed transaction history
- Transaction cards with icons and status indicators

### 4. Create Post Integration

**Wallet Integration in Post Creation:**
- Real-time balance display in post creation screen
- Balance validation before post creation
- Automatic balance deduction on successful post creation
- Dynamic preset amount filtering based on available balance
- Direct navigation to wallet for adding funds

## Database Schema

### Transactions Table
```sql
CREATE TABLE transactions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,           -- 'credit', 'debit', 'post_payment', 'withdrawal'
  amount REAL NOT NULL,
  description TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  postId TEXT,                  -- Optional reference to post
  status TEXT NOT NULL          -- 'completed', 'pending', 'failed'
)
```

## Transaction Types

1. **Credit** - Funds added to wallet
2. **Debit** - General balance deductions
3. **Post Payment** - Balance deducted for post creation
4. **Withdrawal** - Funds withdrawn to bank account

## Payment Flow

### Adding Funds
1. User selects amount (preset or custom)
2. Payment service processes card payment
3. On success, balance is updated
4. Transaction is recorded in database
5. User receives confirmation

### Creating Posts
1. User sets post amount
2. System validates sufficient balance
3. Balance is deducted on post creation
4. Transaction is recorded with post reference
5. User receives confirmation

### Withdrawals
1. User enters withdrawal amount
2. System validates minimum amount ($5) and balance
3. Payment service processes withdrawal request
4. Balance is deducted immediately
5. Transaction marked as 'pending'
6. User notified of processing time (1-3 business days)

## Security Features

- **Balance Validation**: All transactions validate sufficient funds
- **Minimum Amounts**: $0.05 minimum for posts, $5 minimum for withdrawals
- **Transaction Logging**: Complete audit trail of all transactions
- **Error Handling**: Comprehensive error handling and user feedback
- **Demo Mode**: Safe testing environment with simulated payments

## Configuration

### Stripe Integration
```dart
// Test keys (replace with production keys)
static const String publishableKey = 'pk_test_...';
static const String secretKey = 'sk_test_...';
```

### Database Configuration
- SQLite database stored locally
- Automatic table creation on first run
- Transaction history preserved across app sessions

## Usage Examples

### Initialize Wallet Service
```dart
final walletService = WalletService();
await walletService.initialize();
```

### Add Funds
```dart
final success = await walletService.addFunds(25.00);
if (success) {
  print('Funds added successfully');
}
```

### Check Balance
```dart
final balance = walletService.currentBalance;
print('Current balance: ${walletService.formatCurrency(balance)}');
```

### Get Transaction History
```dart
final transactions = await walletService.getTransactionHistory();
for (final transaction in transactions) {
  print('${transaction.type}: ${transaction.amount}');
}
```

## Testing

The wallet system includes comprehensive demo functionality:

- **Simulated Payments**: 95% success rate for testing
- **Mock Withdrawals**: Simulated processing with status updates
- **Test Data**: Pre-loaded with $50 starting balance
- **Error Scenarios**: Handles insufficient funds, network errors, etc.

## Future Enhancements

1. **Real Stripe Integration**: Replace demo mode with actual payment processing
2. **Multiple Payment Methods**: Support for PayPal, Apple Pay, Google Pay
3. **Cryptocurrency Support**: Bitcoin and other crypto payments
4. **Recurring Payments**: Subscription-based features
5. **Advanced Analytics**: Spending patterns and insights
6. **Export Features**: Transaction history export (CSV, PDF)
7. **Multi-Currency**: Support for multiple currencies
8. **Fraud Detection**: Advanced security and fraud prevention

## Dependencies Added

```yaml
dependencies:
  # Payment Gateway
  flutter_stripe: ^10.1.1
  http: ^1.1.0
  # Wallet & Transactions
  sqflite: ^2.3.0
  intl: ^0.19.0
```

## File Structure

```
lib/
├── services/
│   ├── wallet_service.dart      # Core wallet functionality
│   └── payment_service.dart     # Payment gateway integration
├── screens/
│   ├── wallet_screen.dart       # Wallet UI and management
│   ├── create_post.dart         # Updated with wallet integration
│   └── home_screen.dart         # Updated with wallet balance display
└── main.dart                    # Updated with wallet initialization
```

## Integration Points

1. **Home Screen**: Wallet balance display in app bar
2. **Create Post**: Real-time balance validation and deduction
3. **Navigation**: Direct access to wallet from multiple screens
4. **State Management**: Real-time balance updates across the app

This wallet system provides a solid foundation for monetized content creation while maintaining security and user experience standards. 
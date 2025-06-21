import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  late TabController _tabController;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  double _totalEarnings = 0.0;
  double _totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final transactions = await _walletService.getTransactionHistory();
      final earnings = await _walletService.getTotalEarnings();
      final spent = await _walletService.getTotalSpent();
      
      setState(() {
        _transactions = transactions;
        _totalEarnings = earnings;
        _totalSpent = spent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading wallet data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Balance Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _walletService.formatCurrency(_walletService.currentBalance),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              icon: Icons.add,
                              label: 'ReUp!',
                              onTap: _showAddFundsDialog,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              icon: Icons.remove,
                              label: 'Withdraw',
                              onTap: _showWithdrawDialog,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Cards
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.trending_up, color: Colors.green, size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _walletService.formatCurrency(_totalEarnings),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.trending_down, color: Colors.red, size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Total Spent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _walletService.formatCurrency(_totalSpent),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.green.shade600,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.green.shade600,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
            ],
          ),

          // Transaction List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionList(_transactions),
                      _buildTransactionList(_transactions.where((t) => t.type == 'credit').toList()),
                      _buildTransactionList(_transactions.where((t) => t.type == 'debit' || t.type == 'post_payment' || t.type == 'withdrawal').toList()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your transaction history will appear here',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isCredit = transaction.type == 'credit';
        final isWithdrawal = transaction.type == 'withdrawal';
        final isPending = transaction.status == 'pending';

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCredit 
                  ? Colors.green.shade100 
                  : isWithdrawal 
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
              child: Icon(
                isCredit 
                    ? Icons.add 
                    : isWithdrawal 
                        ? Icons.remove 
                        : Icons.shopping_cart,
                color: isCredit 
                    ? Colors.green.shade600 
                    : isWithdrawal 
                        ? Colors.orange.shade600
                        : Colors.red.shade600,
              ),
            ),
            title: Text(
              transaction.description,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.timestamp),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (isPending)
                  Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: Text(
              '${isCredit ? '+' : '-'}${_walletService.formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: isCredit ? Colors.green.shade600 : Colors.red.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AddFundsDialog(
        onSuccess: () {
          _loadData();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => WithdrawDialog(
        currentBalance: _walletService.currentBalance,
        onSuccess: () {
          _loadData();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class AddFundsDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddFundsDialog({super.key, required this.onSuccess});

  @override
  _AddFundsDialogState createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<AddFundsDialog> {
  final _amountController = TextEditingController();
  final WalletService _walletService = WalletService();
  bool _isLoading = false;
  final List<double> _presetAmounts = [10, 25, 50, 100, 250, 500];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ReUp!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select amount or enter custom amount:'),
          SizedBox(height: 16),
          
          // Preset amounts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetAmounts.map((amount) {
              return ElevatedButton(
                onPressed: () {
                  _amountController.text = amount.toString();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                ),
                child: Text('\$${amount.toInt()}'),
              );
            }).toList(),
          ),
          
          SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (\$)',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          
          SizedBox(height: 16),
          SizedBox.shrink(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                                : Text('ReUp!'),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (amount < 5.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum amount is \$5.00')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _walletService.addFunds(amount);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added ${_walletService.formatCurrency(amount)}'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class WithdrawDialog extends StatefulWidget {
  final double currentBalance;
  final VoidCallback onSuccess;

  const WithdrawDialog({super.key, required this.currentBalance, required this.onSuccess});

  @override
  _WithdrawDialogState createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  final _amountController = TextEditingController();
  final _accountController = TextEditingController(text: 'Bank Account ***1234');
  final WalletService _walletService = WalletService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Withdraw Funds'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Balance: ${_walletService.formatCurrency(widget.currentBalance)}'),
          SizedBox(height: 16),
          
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (\$)',
              border: OutlineInputBorder(),
              prefixText: '\$',
              helperText: 'Minimum \$5.00',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          
          SizedBox(height: 16),
          TextField(
            controller: _accountController,
            decoration: InputDecoration(
              labelText: 'Bank Account',
              border: OutlineInputBorder(),
              enabled: false,
            ),
          ),
          
          SizedBox(height: 16),
          Text(
            'Withdrawals typically take 1-3 business days to process.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _processWithdrawal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Withdraw'),
        ),
      ],
    );
  }

  Future<void> _processWithdrawal() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _walletService.withdrawFunds(amount, _accountController.text);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal request submitted for ${_walletService.formatCurrency(amount)}'),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 
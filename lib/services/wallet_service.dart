import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'payment_service.dart';

class Transaction {
  final int? id;
  final String type; // 'credit', 'debit', 'post_payment', 'withdrawal'
  final double amount;
  final String description;
  final DateTime timestamp;
  final String? postId;
  final String status; // 'completed', 'pending', 'failed'

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.postId,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'postId': postId,
      'status': status,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      postId: map['postId'],
      status: map['status'],
    );
  }
}

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  Database? _database;
  double _currentBalance = 0.0;
  final PaymentService _paymentService = PaymentService();
  List<Transaction> _webTransactions = []; // For web storage

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database not available on web');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web, we'll use a mock database that stores in memory
      // In a real app, you'd use a web-compatible database like IndexedDB
      throw UnsupportedError('SQLite not supported on web. Use alternative storage.');
    }
    
    String path = join(await getDatabasesPath(), 'wallet.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            postId TEXT,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> initialize() async {
    // Initialize payment service
    await _paymentService.initialize();
    
    // Load saved balance
    await _loadBalance();
    
    // Initialize database (only on mobile)
    if (!kIsWeb) {
      await database;
    } else {
      // Load web transactions from SharedPreferences
      await _loadWebTransactions();
    }
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _currentBalance = prefs.getDouble('wallet_balance') ?? 50.0; // Default $50
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', _currentBalance);
  }

  double get currentBalance => _currentBalance;

  Future<bool> addFunds(double amount, [String? paymentMethodId]) async {
    try {
      // Use payment service to process payment
      final success = await _paymentService.simulateCardPayment(
        amount: amount,
        currency: 'usd',
      );

      if (success) {
        _currentBalance += amount;
        await _saveBalance();
        
        // Record transaction
        await _addTransaction(Transaction(
          type: 'credit',
          amount: amount,
          description: 'Funds added via payment gateway',
          timestamp: DateTime.now(),
          status: 'completed',
        ));

        return true;
      }
      return false;
    } catch (e) {
      print('Error adding funds: $e');
      return false;
    }
  }



  Future<bool> deductBalance(double amount, String description, {String? postId}) async {
    if (_currentBalance >= amount) {
      _currentBalance -= amount;
      await _saveBalance();
      
      // Record transaction
      await _addTransaction(Transaction(
        type: 'debit',
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        postId: postId,
        status: 'completed',
      ));
      
      return true;
    }
    return false;
  }

  Future<bool> withdrawFunds(double amount, String bankAccount) async {
    if (_currentBalance >= amount && amount >= 5.0) { // Minimum $5 withdrawal
      try {
        // Use payment service to process withdrawal
        final result = await _paymentService.processWithdrawal(
          amount: amount,
          bankAccount: bankAccount,
        );
        
        if (result != null) {
          _currentBalance -= amount;
          await _saveBalance();
          
          // Record transaction
          await _addTransaction(Transaction(
            type: 'withdrawal',
            amount: amount,
            description: 'Withdrawal to $bankAccount',
            timestamp: DateTime.now(),
            status: 'pending',
          ));
          
          return true;
        }
        return false;
      } catch (e) {
        print('Error processing withdrawal: $e');
        return false;
      }
    }
    return false;
  }

  Future<void> _loadWebTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList('web_transactions') ?? [];
    _webTransactions = transactionsJson.map((json) {
      final map = Map<String, dynamic>.from(jsonDecode(json));
      return Transaction.fromMap(map);
    }).toList();
  }

  Future<void> _saveWebTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = _webTransactions.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList('web_transactions', transactionsJson);
  }

  Future<void> _addTransaction(Transaction transaction) async {
    if (kIsWeb) {
      // Add to web storage
      final newTransaction = Transaction(
        id: _webTransactions.length + 1,
        type: transaction.type,
        amount: transaction.amount,
        description: transaction.description,
        timestamp: transaction.timestamp,
        postId: transaction.postId,
        status: transaction.status,
      );
      _webTransactions.insert(0, newTransaction); // Add to beginning for recent first
      await _saveWebTransactions();
    } else {
      final db = await database;
      await db.insert('transactions', transaction.toMap());
    }
  }

  Future<List<Transaction>> getTransactionHistory({int limit = 50}) async {
    if (kIsWeb) {
      return _webTransactions.take(limit).toList();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    if (kIsWeb) {
      return _webTransactions.where((t) => t.type == type).toList();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<double> getTotalEarnings() async {
    if (kIsWeb) {
      return _webTransactions
          .where((t) => t.type == 'credit')
          .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);
    }
    
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = "credit"'
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> getTotalSpent() async {
    if (kIsWeb) {
      return _webTransactions
          .where((t) => t.type == 'debit' || t.type == 'post_payment' || t.type == 'withdrawal')
          .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);
    }
    
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = "debit" OR type = "post_payment"'
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  // Simulate payment for demo purposes
  Future<bool> simulatePayment(double amount) async {
    await Future.delayed(Duration(seconds: 1));
    _currentBalance += amount;
    await _saveBalance();
    
    await _addTransaction(Transaction(
      type: 'credit',
      amount: amount,
      description: 'Simulated payment (Demo)',
      timestamp: DateTime.now(),
      status: 'completed',
    ));
    
    return true;
  }
} 
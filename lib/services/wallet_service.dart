// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'payment_service.dart';

class Transaction {
  final String id; // Firestore doc ID
  final String type; // credit, debit, withdrawal, post_payment
  final double amount;
  final String description;
  final DateTime timestamp;
  final String status; // completed | pending | failed
  final String? postId;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
    this.postId,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'postId': postId,
    };
  }

  factory Transaction.fromMap(String id, Map<String, dynamic> map) {
    return Transaction(
      id: id,
      type: map['type'] ?? 'unknown',
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      status: map['status'] ?? 'completed',
      postId: map['postId'],
    );
  }
}

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _paymentService = PaymentService();

  DocumentReference<Map<String, dynamic>>? _walletDoc;
  double _currentBalance = 0.0;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _balanceSub;

  double get currentBalance => _currentBalance;

  /// Call this once after Firebase.initializeApp() and user login.
  Future<void> initialize() async {
    await _paymentService.initialize();

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('WalletService.initialize: user not signed-in');
      return;
    }

    _walletDoc = _firestore.collection('wallets').doc(uid);

    // Ensure wallet doc exists.
    await _walletDoc!.set({'balance': 0.0}, SetOptions(merge: true));

    // Listen for balance changes.
    _balanceSub = _walletDoc!.snapshots().listen((snap) {
      _currentBalance = (snap.data()?['balance'] ?? 0).toDouble();
    });
  }

  Future<void> dispose() async {
    await _balanceSub?.cancel();
  }

  CollectionReference<Map<String, dynamic>> get _txCol {
    if (_walletDoc == null) {
      throw StateError('WalletService not initialised');
    }
    return _walletDoc!.collection('transactions');
  }

  Future<void> _setBalance(double newBalance) async {
    _currentBalance = newBalance;
    await _walletDoc!.update({'balance': newBalance});
  }

  Future<void> _addTransaction(Transaction tx) async {
    await _txCol.add(tx.toMap());
  }

  // ---------- Public API  ----------

  Future<bool> addFunds(double amount) async {
    final success = await _paymentService.simulateCardPayment(amount: amount, currency: 'usd');
    if (!success) return false;

    await _setBalance(_currentBalance + amount);
    await _addTransaction(Transaction(
      id: 'tmp',
      type: 'credit',
      amount: amount,
      description: 'Added funds',
      timestamp: DateTime.now(),
      status: 'completed',
    ));
    return true;
  }

  Future<bool> deductBalance(double amount, String description, {String? postId}) async {
    if (_currentBalance < amount) return false;
    await _setBalance(_currentBalance - amount);
    await _addTransaction(Transaction(
      id: 'tmp',
      type: 'debit',
      amount: amount,
      description: description,
      timestamp: DateTime.now(),
      status: 'completed',
      postId: postId,
    ));
    return true;
  }

  Future<bool> withdrawFunds(double amount, String bankAccount) async {
    if (_currentBalance < amount || amount < 5.0) return false;

    final result = await _paymentService.processWithdrawal(amount: amount, bankAccount: bankAccount);
    if (result == null) return false;

    await _setBalance(_currentBalance - amount);
    await _addTransaction(Transaction(
      id: 'tmp',
      type: 'withdrawal',
      amount: amount,
      description: 'Withdrawal to $bankAccount',
      timestamp: DateTime.now(),
      status: 'pending',
    ));
    return true;
  }

  Future<List<Transaction>> getTransactionHistory({int limit = 50}) async {
    final snap = await _txCol.orderBy('timestamp', descending: true).limit(limit).get();
    return snap.docs.map((d) => Transaction.fromMap(d.id, d.data())).toList();
  }

  Future<double> getTotalEarnings() async {
    final snap = await _txCol.where('type', isEqualTo: 'credit').get();
    return snap.docs.fold<double>(0.0, (sum, d) => sum + (d['amount'] as num).toDouble());
  }

  Future<double> getTotalSpent() async {
    final snap = await _txCol.where('type', whereIn: ['debit', 'post_payment', 'withdrawal']).get();
    return snap.docs.fold<double>(0.0, (sum, d) => sum + (d['amount'] as num).toDouble());
  }

  String formatCurrency(double amount) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);

  // Dev utility
  Future<bool> simulatePayment(double amount) => addFunds(amount);
} 
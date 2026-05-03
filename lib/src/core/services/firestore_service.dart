import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/core/models/user_model.dart';
import 'package:myapp/src/core/models/transaction_model.dart' as models;
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get one-time user profile
  Future<UserProfile?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  // Stream of user profile
  Stream<UserProfile> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((doc) async {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      } else {
        // Create initial profile if not exists
        final newUser = UserProfile(
          id: userId,
          name: 'New User',
          balance: 5000.0,
          qrCode: jsonEncode({'id': userId, 'type': 'haqdaar_v1', 'role': 'individual'}),
        );
        await _db.collection('users').doc(userId).set(newUser.toMap());
        return newUser;
      }
    });
  }

  // Stream of transactions
  Stream<List<models.Transaction>> streamTransactions(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => models.Transaction.fromMap(doc.data())).toList();
    });
  }

  // P2P Payment Transaction
  Future<bool> sendMoney({
    required String senderId,
    required String receiverId,
    required double amount,
    String? note,
  }) async {
    debugPrint('STARTING CLOUD TRANSACTION...');
    debugPrint('Sender ID: $senderId');
    debugPrint('Receiver ID: $receiverId');

    try {
      final senderDoc = _db.collection('users').doc(senderId);
      final receiverDoc = _db.collection('users').doc(receiverId);

      return await _db.runTransaction((transaction) async {
        final senderSnapshot = await transaction.get(senderDoc);
        final receiverSnapshot = await transaction.get(receiverDoc);

        if (!senderSnapshot.exists) {
          debugPrint('SENDER NOT FOUND');
          return false;
        }
        if (!receiverSnapshot.exists) {
          debugPrint('RECEIVER NOT FOUND');
          return false;
        }
        if (senderId == receiverId) {
          debugPrint('SAME USER TRANSACTION BLOCKED');
          return false;
        }

        final senderData = UserProfile.fromMap(senderSnapshot.data()!);
        final receiverData = UserProfile.fromMap(receiverSnapshot.data()!);

        // Role-based validation
        if (!senderData.canSendP2P) {
          debugPrint('ROLE BLOCKED: Merchants cannot send P2P payments');
          return false;
        }

        if (senderData.balance < amount) {
          debugPrint('INSUFFICIENT BALANCE');
          return false;
        }

        // 1. Update balances
        transaction.update(senderDoc, {'balance': senderData.balance - amount});
        transaction.update(receiverDoc, {'balance': receiverData.balance + amount});

        // 2. Create Transaction Records
        final txId = DateTime.now().millisecondsSinceEpoch.toString();
        
        final debitTx = models.Transaction(
          id: txId,
          title: 'Payment to ${receiverData.name}',
          amount: amount,
          date: DateTime.now(),
          type: models.TransactionType.debit,
          icon: Icons.send,
        );

        final creditTx = models.Transaction(
          id: txId,
          title: 'Received from ${senderData.name}',
          amount: amount,
          date: DateTime.now(),
          type: models.TransactionType.credit,
          icon: Icons.call_received,
        );

        transaction.set(senderDoc.collection('transactions').doc(txId), debitTx.toMap());
        transaction.set(receiverDoc.collection('transactions').doc(txId), creditTx.toMap());

        return true;
      });
    } catch (e) {
      debugPrint('Payment Error: $e');
      return false;
    }
  }

  // Initialize/Update User Profile (e.g. on login)
  Future<void> saveUser(UserProfile user) async {
    await _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  // Delete User Profile
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Get all users
  Future<List<UserProfile>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
  }
}

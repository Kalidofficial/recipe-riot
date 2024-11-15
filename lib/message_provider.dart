import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String sender;
  final String text;

  Message({required this.sender, required this.text});

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      text: json['text'],
    );
  }
}

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MessageProvider() {
    _loadMessages();
  }

  List<Message> get messages => _messages;

  Future<void> _loadMessages() async {
    // Fetch messages from Firestore
    _firestore.collection('messages').snapshots().listen((snapshot) {
      _messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
      notifyListeners(); // Notify listeners for UI update
    });
  }

  Future<void> addMessage(String sender, String text) async {
    final message = Message(sender: sender, text: text);
    await _firestore.collection('messages').add(message.toJson());
  }

  Future<void> clearMessages() async {
    // clear messages for the viewer perspective
    final batch = _firestore.batch();
    final querySnapshot = await _firestore.collection('messages').get();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    // refresh the messages list
    _loadMessages();
  }
}

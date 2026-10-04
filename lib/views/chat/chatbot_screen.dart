import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chatSnapshot = await _firestore
        .collection('chats')
        .doc(user.phoneNumber)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    setState(() {
      _messages = chatSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    final newMessage = {
      'sender': 'user',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() => _messages.add(newMessage));
    await _saveMessage(user.phoneNumber!, newMessage);

    // Simulated AI Response
    await Future.delayed(const Duration(milliseconds: 800));
    final aiResponse = _generateAIResponse(text);

    final botMessage = {
      'sender': 'bot',
      'text': aiResponse,
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() => _messages.add(botMessage));
    await _saveMessage(user.phoneNumber!, botMessage);

    _scrollToBottom();
  }

  Future<void> _saveMessage(String phone, Map<String, dynamic> message) async {
    await _firestore
        .collection('chats')
        .doc(phone)
        .collection('messages')
        .add(message);
  }

  String _generateAIResponse(String query) {
    query = query.toLowerCase();

    if (query.contains("fraud") || query.contains("anomaly")) {
      return "Anomalies usually indicate financial inconsistencies — such as low VAT returns or high expenses compared to revenue.";
    } else if (query.contains("how") && query.contains("detect")) {
      return "The system detects fraud using hybrid models combining rule-based logic and AI learning patterns from past data.";
    } else if (query.contains("vat")) {
      return "VAT anomalies occur when declared VAT is far below expected levels based on reported revenue.";
    } else if (query.contains("safe")) {
      return "Keeping accurate revenue and expense records reduces your anomaly rate and builds trust with the tax authority.";
    } else if (query.contains("hello") || query.contains("hi")) {
      return "Hello 👋, I'm SmartBot — your assistant for understanding tax anomalies and fraud detection.";
    } else if (query.contains("thank")) {
      return "You're welcome! Always here to help with fraud and anomaly queries.";
    } else {
      return "I'm not sure I understand that fully, but I can help you interpret fraud patterns, VAT mismatches, and revenue inconsistencies.";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("SmartBot - AI Assistant"),
        backgroundColor: const Color(0xFF013A80),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF013A80)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask about fraud or anomalies...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF013A80)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

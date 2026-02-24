import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String athleteId;
  final String athleteName;
  final String currentUserId;
  final bool isCoach;

  const ChatScreen({
    super.key,
    required this.athleteId,
    required this.athleteName,
    required this.currentUserId,
    required this.isCoach,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    final messageId = FirebaseFirestore.instance.collection('chats').doc().id;
    final message = MessageModel(
      id: messageId,
      senderId: widget.currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.athleteId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Bildirim gönder
    final targetId = widget.isCoach ? widget.athleteId : 'admin';
    final notifId = FirebaseFirestore.instance
        .collection('notifications')
        .doc()
        .id;
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notifId)
        .set({
          'id': notifId,
          'title': 'Yeni Mesaj 💬',
          'body': widget.isCoach
              ? 'Coach bir mesaj gönderdi.'
              : '${widget.athleteName} bir mesaj gönderdi.',
          'type': 'message',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'targetUserId': targetId,
          'senderId': widget.currentUserId,
        });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          widget.isCoach ? widget.athleteName : 'Coach',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFF00FF7F),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.athleteId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz mesaj yok.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  );
                }

                final messages = snapshot.data!.docs
                    .map(
                      (doc) => MessageModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;

                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF1A1A2E),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF00FF7F)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00FF7F) : const Color(0xFF16213E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(color: isMe ? Colors.black : Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isMe
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

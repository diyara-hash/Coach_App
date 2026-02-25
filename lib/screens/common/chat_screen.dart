import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.isCoach ? widget.athleteName : 'Coach',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
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
                padding: EdgeInsets.only(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      100, // Account for glass input
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.senderId == widget.currentUserId;

                  return _MessageBubble(
                    message: message,
                    isMe: isMe,
                  ).animate().fade(duration: 300.ms).slideY(begin: 0.1);
                },
              );
            },
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildMessageInput()),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom > 0
                ? MediaQuery.of(context).viewPadding.bottom
                : AppSpacing.md,
            top: AppSpacing.sm,
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Mesaj...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 14,
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 4,
                          minLines: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [AppColors.emeraldGlow],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: _sendMessage,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? null
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isMe ? [AppColors.emeraldGlow] : [AppColors.eliteShadow],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                height: 1.4,
                fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isMe
                    ? Colors.black54
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String threadId;

  const ChatScreen({Key? key, required this.threadId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final thread = chatProvider.getThread(widget.threadId);

    if (thread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("الدردشة")),
        body: const Center(child: Text("المحادثة غير موجودة")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(thread.otherUserName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(thread.carTitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryDark), maxLines: 1),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner for car reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.cardDark,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(thread.carImage, width: 45, height: 35, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 45, height: 35, color: Colors.grey)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    thread.carTitle,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: thread.messages.length,
              itemBuilder: (context, index) {
                final msg = thread.messages[index];
                final isMe = msg.senderId == "current_user" || msg.senderId == "me";

                return Align(
                  alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primaryGold : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isMe ? Colors.black : AppTheme.textPrimaryDark,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Text input bar
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.cardDark,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: AppTheme.textPrimaryDark),
                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك للبائع...",
                      hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGold,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black, size: 20),
                    onPressed: () {
                      if (_msgController.text.trim().isNotEmpty) {
                        chatProvider.sendMessage(widget.threadId, _msgController.text.trim());
                        _msgController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

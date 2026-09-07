import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });
}

class ChatThread {
  final String id;
  final String carId;
  final String carTitle;
  final String carImage;
  final String otherUserName;
  final String otherUserPhone;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.carId,
    required this.carTitle,
    required this.carImage,
    required this.otherUserName,
    required this.otherUserPhone,
    required this.messages,
  });
}

class ChatProvider with ChangeNotifier {
  List<ChatThread> _threads = [];

  ChatProvider() {
    _initMockChats();
  }

  List<ChatThread> get threads => _threads;

  ChatThread? getThread(String threadId) {
    try {
      return _threads.firstWhere((t) => t.id == threadId);
    } catch (_) {
      return null;
    }
  }

  String startOrGetThread({
    required String carId,
    required String carTitle,
    required String carImage,
    required String sellerName,
    required String sellerPhone,
  }) {
    final existingIdx = _threads.indexWhere((t) => t.carId == carId);
    if (existingIdx != -1) {
      return _threads[existingIdx].id;
    }

    final newThreadId = "chat_${DateTime.now().millisecondsSinceEpoch}";
    final newThread = ChatThread(
      id: newThreadId,
      carId: carId,
      carTitle: carTitle,
      carImage: carImage,
      otherUserName: sellerName,
      otherUserPhone: sellerPhone,
      messages: [
        ChatMessage(
          id: "msg_1",
          senderId: "seller",
          senderName: sellerName,
          text: "أهلاً بك! السيارة متوفرة في معرضنا، تفضل بأي استفسار.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        )
      ],
    );

    _threads.insert(0, newThread);
    notifyListeners();
    return newThreadId;
  }

  void sendMessage(String threadId, String text) {
    final idx = _threads.indexWhere((t) => t.id == threadId);
    if (idx != -1) {
      final old = _threads[idx];
      final newMsg = ChatMessage(
        id: "msg_${DateTime.now().millisecondsSinceEpoch}",
        senderId: "current_user",
        senderName: "أنا",
        text: text,
        createdAt: DateTime.now(),
      );

      final updatedMessages = List<ChatMessage>.from(old.messages)..add(newMsg);
      _threads[idx] = ChatThread(
        id: old.id,
        carId: old.carId,
        carTitle: old.carTitle,
        carImage: old.carImage,
        otherUserName: old.otherUserName,
        otherUserPhone: old.otherUserPhone,
        messages: updatedMessages,
      );
      notifyListeners();
    }
  }

  void _initMockChats() {
    _threads = [
      ChatThread(
        id: "chat_1",
        carId: "car_101",
        carTitle: "تويوتا لاند كروزر VXR فول مواصفات 2024",
        carImage: "https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=1200&q=80",
        otherUserName: "معرض الرافدين للسيارات الفاخرة",
        otherUserPhone: "+966562514125",
        messages: [
          ChatMessage(
            id: "m1",
            senderId: "other",
            senderName: "معرض الرافدين",
            text: "السلام عليكم، تفضل حبيبي السيارة موجودة ببغداد الكرادة.",
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: "m2",
            senderId: "me",
            senderName: "أنا",
            text: "وعليكم السلام، كم القسط الأول إذا مباشر من المعرض؟",
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          ChatMessage(
            id: "m3",
            senderId: "other",
            senderName: "معرض الرافدين",
            text: "الدفعة الأولى 30,000\$ والباقي اقساط سنتين. حياك الله بكت ما تحب تناورنا.",
            createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          ),
        ],
      )
    ];
  }
}

import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/models/message_model.dart';
import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/services/fireStore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final FireStoreService _firestoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final Uuid _uuid = const Uuid();
  ScrollController? _scrollController;
  ScrollController get scrollController {
    _scrollController ??= ScrollController();
    return _scrollController!;
  }

  final RxList<MessageModel> _messages = <MessageModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _otherUser = Rx<UserModel?>(null);
  final RxString _chatId = ''.obs;
  final RxBool _isTyping = false.obs;
  final RxBool _isChatActive = false.obs;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  String get error => _error.value;
  UserModel? get otherUser => _otherUser.value;
  String get chatId => _chatId.value;
  bool get isTyping => _isTyping.value;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    messageController.addListener(_onMessageChanged);
  }

  @override
  void onReady() {
    super.onReady();
    _isChatActive.value = true;
  }

  @override
  void onClose() {
    _isChatActive.value = false;
    _markMessagesAsRead();
    super.onClose();
  }

  void _initializeChat() {
    final arguments = Get.arguments;
    if (arguments != null) {
      _chatId.value = arguments['chatId'] ?? '';
      _otherUser.value = arguments['otherUser'];
      _loadMessages();
      _markMessagesAsRead();
    }
  }

  void _loadMessages() {
    final currentUserId = _authController.user?.uid;
    final otherUserId = _otherUser.value?.id;
    if (currentUserId != null && otherUserId != null) {
      _messages.bindStream(
          _firestoreService.getMessagesStream(currentUserId, otherUserId));
      ever(
        _messages,
        (List<MessageModel> messageList) {
          if (_isChatActive.value) {
            _markUnReadMessagesAsRead(messageList);
          }
          _scrollToBottom();
        },
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController != null && _scrollController!.hasClients) {
          _scrollController!.animateTo(
              _scrollController!.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      },
    );
  }

  Future<void> _markUnReadMessagesAsRead(List<MessageModel> messageList) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) {
      return;
    }
    try {
      final unreadMessages = messageList.where((message) =>
          message.receiverId == currentUserId &&
          !message.isRead &&
          message.senderId != currentUserId);

      for (var message in unreadMessages) {
        await _firestoreService.markMessageAsRead(message.id);
      }
      if (unreadMessages.isNotEmpty && _chatId.isNotEmpty) {
        await _firestoreService.restUnreadCount(_chatId.value, currentUserId);
      }
      if (_chatId.value.isNotEmpty) {
        await _firestoreService.updateUserLastSeen(
            _chatId.value, currentUserId);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteChat() async {
    try {
      final currentUserId = _authController.user?.uid;
      if (currentUserId == null || _chatId.value.isEmpty) {
        return;
      }
      final result = await Get.dialog<bool>(AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
            'Are you sure you want to delete this chat? This action cannot be undone'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete')),
        ],
      ));
      if (result == true) {
        _isLoading.value = true;
        await _firestoreService.deleteChatForUser(_chatId.value, currentUserId);
        Get.delete<ChatController>(tag: _chatId.value);
        Get.back();
        Get.snackbar('Success', 'Chat Deleted');
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Erorr', 'Failed to delete chat');
    } finally {
      _isLoading.value = false;
    }
  }

  void _onMessageChanged() {
    _isTyping.value = messageController.text.isNotEmpty;
  }

  Future<void> sendMessage() async {
    final currentUserId = _authController.user?.uid;
    final otherUserId = _otherUser.value?.id;
    final content = messageController.text.trim();
    messageController.clear();
    if (currentUserId == null || otherUserId == null || content.isEmpty) {
      Get.snackbar('Erorr', 'You cannot send messages to this user');
      return;
    }
    if (await _firestoreService.isUnfriended(currentUserId, otherUserId)) {
      Get.snackbar('Error',
          'You cannot send messages to this user as you are not friends');
      return;
    }
    try {
      _isSending.value = true;
      final message = MessageModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: otherUserId,
          content: content,
          type: MessageType.text,
          timestamp: DateTime.now());
      await _firestoreService.sendMessage(message);
      _isTyping.value = false;
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'You cannot send message');
    } finally {
      _isSending.value = false;
    }
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null && _chatId.value.isNotEmpty) {
      try {
        await _firestoreService.restUnreadCount(_chatId.value, currentUserId);
      } catch (e) {
        print(e);
      }
    }
  }

  void onChatResumed() {
    _isChatActive.value = true;
    _markUnReadMessagesAsRead(_messages);
  }

  void onChatPaused() {
    _isChatActive.value = false;
  }

  Future<void> deleteMessage(MessageModel message) async {
    try {
      await _firestoreService.deleteMessage(message.id);
      Get.snackbar('Success', 'Message Deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message');
    }
  }

  Future<void> editMessage(MessageModel message, String newContent) async {
    try {
      await _firestoreService.editMessage(message.id, newContent);
      Get.snackbar('Success', 'Message Edited');
    } catch (e) {
      Get.snackbar('Error', 'Failed to edit message');
    }
  }

  bool isMymessage(MessageModel message) {
    return message.senderId == _authController.user?.uid;
  }

  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[timestamp.weekday - 1]} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void clearError() {
    _error.value = '';
  }
}

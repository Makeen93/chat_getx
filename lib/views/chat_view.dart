import 'package:chat_getx/controllers/chat_controller.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:chat_getx/views/widgets/message_bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final String chatId;
  late final ChatController controller;
  @override
  void initState() {
    super.initState();
    chatId = Get.arguments?['chatId'] ?? '';
    if (!Get.isRegistered<ChatController>(tag: chatId)) {
      Get.put<ChatController>(ChatController(), tag: chatId);
    }
    controller = Get.find<ChatController>(tag: chatId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.delete<ChatController>(tag: chatId);
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
        title: Obx(
          () {
            final otherUser = controller.otherUser;
            if (otherUser == null) return const Text('Chat');
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor,
                  child: otherUser.photoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            otherUser.photoUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                otherUser.displayName.isNotEmpty
                                    ? otherUser.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        )
                      : Text(
                          otherUser.displayName.isNotEmpty
                              ? otherUser.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      otherUser.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: otherUser.isOnline
                              ? AppTheme.successColor
                              : AppTheme.textSecondryColor),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ))
              ],
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  controller.deleteChat();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorColor,
                    ),
                    title: Text('Delete Chat'),
                    contentPadding: EdgeInsets.zero,
                  ))
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Obx(
            () {
              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMyMessage = controller.isMymessage(message);
                  final showTime = index == 0 ||
                      controller.messages[index - 1].timestamp
                              .difference(message.timestamp)
                              .inMinutes
                              .abs() >
                          5;
                  return MessageBubble(
                    message: message,
                    isMyMessage: isMyMessage,
                    showTime: showTime,
                    timeText: controller.formatMessageTime(message.timestamp),
                    onLongPress:
                        isMyMessage ? () => _showMessageOptions(message) : null,
                  );
                },
              );
            },
          )),
          _buildMessageInput(),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.onChatResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        controller.onChatPaused();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.5), width: 1),
        ),
      ),
      child: SafeArea(
          child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                        color: controller.isTyping
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(24)),
                    child: IconButton(
                        onPressed: controller.isSending
                            ? null
                            : controller.sendMessage,
                        icon: Icon(
                          Icons.send_rounded,
                          color: controller.isTyping
                              ? Colors.white
                              : AppTheme.textSecondryColor,
                        )),
                  ),
                )
              ],
            ),
          ))
        ],
      )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40)),
              child: const Icon(
                Icons.chat_outlined,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Start the conversation',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppTheme.textPrimaryColor),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Send a message to get the chat started',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(dynamic message) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Edit Message'),
            onTap: () {
              Get.back();
              _showEditDialog(message);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: AppTheme.errorColor,
            ),
            title: const Text('Delete Message'),
            onTap: () {
              Get.back();
              _showDeleteDialog(message);
            },
          )
        ],
      ),
    ));
  }

  void _showEditDialog(dynamic message) {
    final editController = TextEditingController(text: message.content);
    Get.dialog(AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: editController,
        decoration: const InputDecoration(
          hintText: 'Enter new message',
        ),
        maxLines: null,
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                controller.editMessage(message, editController.text.trim());
                Get.back();
              }
            },
            child: const Text('Save')),
      ],
    ));
  }

  void _showDeleteDialog(dynamic message) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Message'),
      content: const Text(
          'Are you sure you want to delete this message? This cannot be undone'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              controller.deleteMessage(message);
              Get.back();
            },
            child: const Text('Delete')),
      ],
    ));
  }
}

import 'package:chat_getx/models/chat_model.dart';
import 'package:chat_getx/models/friend_request_model.dart';
import 'package:chat_getx/models/friendship_model.dart';
import 'package:chat_getx/models/message_model.dart';
import 'package:chat_getx/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(userId).update({
          'isOnline': isOnline,
          'lastSeen': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update user status: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(request.id)
          .set(request.toMap());

      String notificationId = _firestore.collection('notifications').doc().id;
      await createNotification(NotificationModel(
        id: notificationId,
        userId: request.receiverId,
        title: 'New Friend Request',
        body: 'You have receiced a new friend request.',
        type: NotificationType.friendRequest,
        data: {'senderId': request.senderId, 'requestId': request.id},
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      throw Exception('Failed to send friend request: ${e.toString()}');
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      DocumentSnapshot requestDoc =
          await _firestore.collection('friendRequests').doc(requestId).get();
      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
            requestDoc.data() as Map<String, dynamic>);
        await _firestore.collection('friendRequests').doc(requestId).delete();
        await deleteNotificationByTypeAndUser(
          request.receiverId,
          NotificationType.friendRequest,
          request.senderId,
        );
      }
    } catch (e) {
      throw Exception('Failed to cancel friend request: ${e.toString()}');
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  Future<void> respondToFriendRequest(
      String requestId, FriendRequesStatus status) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': status.name,
        'respondedAt': DateTime.now().millisecondsSinceEpoch,
      });
      DocumentSnapshot requestDoc =
          await _firestore.collection('friendRequests').doc('requestId').get();
      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
            requestDoc.data() as Map<String, dynamic>);
        if (status == FriendRequesStatus.accepted) {
          await createFriendShip(request.senderId, request.receiverId);
          await createNotification(NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Accepted',
              data: {'userId': request.receiverId},
              body: 'Your friend request has been accepted',
              type: NotificationType.friendRequestAccepted,
              createdAt: DateTime.now()));
          await _removeNotificationForCancelledRequest(
              request.receiverId, request.senderId);
        } else if (status == FriendRequesStatus.declined) {
          await createNotification(NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Declined',
              data: {'userId': request.receiverId},
              body: 'Your friend request has been Declined',
              type: NotificationType.friendRequestAccepted,
              createdAt: DateTime.now()));
          await _removeNotificationForCancelledRequest(
              request.receiverId, request.senderId);
        }
      }
    } catch (e) {
      throw Exception('Failed to respond to friend request: ${e.toString()}');
    }
  }

  Stream<List<FriendRequestModel>> getFriendRequestsStream(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('reciverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<FriendRequestModel>> getSentFriendRequestsStream(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<FriendRequestModel?> getFriendRequest(
      String senderId, String receiverId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('reciverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (query.docs.isNotEmpty) {
        return FriendRequestModel.fromMap(
            query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get friend request: ${e.toString()}');
    }
  }

  Future<void> createFriendShip(String userId, String user2Id) async {
    try {
      List<String> userIds = [userId, user2Id];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      FriendshipModel friendShip = FriendshipModel(
          id: frindShipId,
          user1Id: userIds[0],
          user2Id: userIds[1],
          createdAt: DateTime.now());

      await _firestore
          .collection('friendships')
          .doc(frindShipId)
          .set(friendShip.toMap());
    } catch (e) {
      throw Exception('Failed to create friendship: ${e.toString()}');
    }
  }

  Future<void> removeFriendShip(String userId, String user2Id) async {
    try {
      List<String> userIds = [userId, user2Id];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      await _firestore.collection('friendships').doc(frindShipId).delete();
      await createNotification(NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user2Id,
          title: 'Friend Removed',
          body: 'You are no longer friends',
          type: NotificationType.friendRemoved,
          createdAt: DateTime.now()));
    } catch (e) {
      throw Exception('Failed to remove friendship: ${e.toString()}');
    }
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    try {
      List<String> userIds = [blockerId, blockedId];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      await _firestore
          .collection('friendships')
          .doc(frindShipId)
          .update({'isBlocked': true, 'blockedBy': blockerId});
    } catch (e) {
      throw Exception('Failed to block user: ${e.toString()}');
    }
  }

  Future<void> unBlockUser(String userId, String user2Id) async {
    try {
      List<String> userIds = [userId, user2Id];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      await _firestore
          .collection('friendships')
          .doc(frindShipId)
          .update({'isBlocked': false, 'blockedBy': null});
    } catch (e) {
      throw Exception('Failed to block friendship: ${e.toString()}');
    }
  }

  Stream<List<FriendshipModel>> getFreindsStream(String userId) {
    return _firestore
        .collection('friendships')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap(
      (snapshot1) async {
        QuerySnapshot snapshot2 = await _firestore
            .collection('friendships')
            .where('user2Id', isEqualTo: userId)
            .get();
        List<FriendshipModel> friendships = [];
        for (var doc in snapshot1.docs) {
          friendships.add(FriendshipModel.fromMap(doc.data()));
        }
        for (var doc in snapshot2.docs) {
          friendships
              .add(FriendshipModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        return friendships
            .where(
              (element) => !element.isBlocked,
            )
            .toList();
      },
    );
  }

  Future<FriendshipModel?> getFriendships(
      String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      DocumentSnapshot doc =
          await _firestore.collection('friendships').doc(frindShipId).get();
      if (doc.exists) {
        return FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get friendship: ${e.toString()}');
    }
  }

  Future<bool> isUserBlocked(String userId, String otherUserId) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      DocumentSnapshot doc =
          await _firestore.collection('friendships').doc(frindShipId).get();
      if (doc.exists) {
        FriendshipModel friendship =
            FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
        return friendship.isBlocked;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check if user is blocked: ${e.toString()}');
    }
  }

  Future<bool> isUnfriended(String userId, String otherUserId) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();
      String frindShipId = '${userIds[0]}_ ${userIds[1]}';
      DocumentSnapshot doc =
          await _firestore.collection('friendships').doc(frindShipId).get();

      return !doc.exists || (doc.exists && doc.data() == null);
    } catch (e) {
      throw Exception('Failed to check if user is blocked: ${e.toString()}');
    }
  }

  Future<String> createOrGetChat(String userId1, String userId2) async {
    try {
      List<String> participants = [userId1, userId1];
      participants.sort();
      String chatId = '${participants[0]}_${participants[1]}';
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
      DocumentSnapshot chatdoc = await chatRef.get();
      if (!chatdoc.exists) {
        ChatModel newChat = ChatModel(
          id: chatId,
          participants: participants,
          unreadCount: {userId1: 0, userId2: 0},
          deletedBy: {userId1: false, userId2: false},
          deletedAt: {userId1: null, userId2: null},
          lastSeenBy: {userId1: DateTime.now(), userId2: DateTime.now()},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await chatRef.set(newChat.toMap());
      } else {
        ChatModel existingChat =
            ChatModel.fromMap(chatdoc.data() as Map<String, dynamic>);
        if (existingChat.isDeletedBy(userId1)) {
          await restoreChatForUser(chatId, userId1);
        }
        if (existingChat.isDeletedBy(userId2)) {
          await restoreChatForUser(chatId, userId2);
        }
      }
      return chatId;
    } catch (e) {
      throw Exception('Failed to create or get chat: ${e.toString()}');
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromMap(doc.data()),
              )
              .where(
                (chat) => !chat.isDeletedBy(userId),
              )
              .toList(),
        );
  }

  Future<void> updateChatLastMessage(
      String chatId, MessageModel message) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update chat last message: ${e.toString()}');
    }
  }

  Future<void> updateUserLastSeen(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update(
          {'lastSeenBy.$userId': DateTime.now().millisecondsSinceEpoch});
    } catch (e) {
      throw Exception('Failed to update last seen: ${e.toString()}');
    }
  }

  Future<void> deleteChatForUser(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'deletedBy.$userId': true,
        'deletedAt': DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      throw Exception('Failed to delete chat: ${e.toString()}');
    }
  }

  Future<void> restoreChatForUser(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'deletedBy.$userId': false,
      });
    } catch (e) {
      throw Exception('Failed to restore chat: ${e.toString()}');
    }
  }

  Future<void> updateUnreadCount(
      String chatId, String userId, int count) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({'unreadCount.$userId': count});
    } catch (e) {
      throw Exception('Failed to update unread count: ${e.toString()}');
    }
  }

  Future<void> restUnreadCount(String chatId, String userId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({'unreadCount.$userId': 0});
    } catch (e) {
      throw Exception('Failed to rest unread count: ${e.toString()}');
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('message')
          .doc(message.id)
          .set(message.toMap());
      String chatId =
          await createOrGetChat(message.senderId, message.receiverId);
      await updateChatLastMessage(chatId, message);
      await updateUserLastSeen(chatId, message.senderId);
      DocumentSnapshot chatDoc =
          await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        ChatModel chat =
            ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
        int currentUnread = chat.getUnreadCount(message.receiverId);
        await updateUnreadCount(chatId, message.receiverId, currentUnread + 1);
      }
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String userId1, String userId2) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userId1, userId2])
        .snapshots()
        .asyncMap(
          (snapshot) async {
            List<String> participants = [userId1, userId2];
            participants.sort();
            String chatId = '${participants[0]}_${participants[1]}';
            DocumentSnapshot chatDoc =
                await _firestore.collection('chats').doc(chatId).get();

            ChatModel? chat;
            if (chatDoc.exists) {
              chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
            }
            List<MessageModel> messages = [];
            for (var doc in snapshot.docs) {
              MessageModel message = MessageModel.fromMap(doc.data());
              if ((message.senderId == userId1 &&
                      message.receiverId == userId2) ||
                  (message.senderId == userId2 &&
                      message.receiverId == userId1)) {
                bool includeMessage = true;
                if (chat != null) {
                  DateTime? currentUserDeletedAt = chat.getDeletedAt(userId1);
                  if (currentUserDeletedAt != null &&
                      message.timestamp.isBefore(currentUserDeletedAt)) {
                    includeMessage = false;
                  }
                }
                if (includeMessage) {
                  messages.add(message);
                }
              }
            }
            messages.sort(
              (a, b) => a.timestamp.compareTo(b.timestamp),
            );
            return messages;
          },
        );
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark message as read: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: ${e.toString()}');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'editedAt': DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      throw Exception('Failed to edit message: ${e.toString()}');
    }
  }

  Stream<List<NotificationModel>> getNotificationStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => NotificationModel.fromMap(doc.data()),
            )
            .toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notification')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: true)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception(
          'Failed to mark all notification as read: ${e.toString()}');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notification').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  Future<void> deleteNotificationByTypeAndUser(
      String userId, NotificationType type, String relatedUserId) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .get();
      WriteBatch batch = _firestore.batch();
      for (var doc in notifications.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['data' != null] &&
            (data['data']['senderId'] == relatedUserId ||
                data['data']['userId'] == relatedUserId)) {}
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to deleting: ${e.toString()}');
    }
  }

  Future<void> _removeNotificationForCancelledRequest(
      String receiverId, String senderId) async {
    try {
      await deleteNotificationByTypeAndUser(
          receiverId, NotificationType.friendRequest, senderId);
    } catch (e) {
      print('error removing notification for cancelled request: $e');
    }
  }
}

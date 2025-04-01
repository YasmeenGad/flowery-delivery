import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../di/di.dart';
import 'firebase_server_token.dart';

class NotificationHelper {
  /// Singleton instance
  factory NotificationHelper() => _instance;
  static final NotificationHelper _instance = NotificationHelper._internal();
  static final GlobalKey<NavigatorState> navigatorKey =
  getIt<GlobalKey<NavigatorState>>();

  /// Firebase Messaging instance
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// Local Notifications Plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationHelper._internal();

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    await _requestPermissions();
    await _setupLocalNotifications();
    await messaging.setAutoInitEnabled(true);

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // Handle terminated state notifications
    // RemoteMessage? initialMessage = await messaging.getInitialMessage();
    // if (initialMessage != null) {
    //   _handleNavigation(initialMessage);
    // }

    await getDeviceToken();
  }

  /// Request notification permissions from the user
  Future<NotificationSettings> _requestPermissions() async {
    return await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle Firebase background messages
  // static Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   debugPrint("Handling background message: ${message.data}");
  //   _handleNavigation(message);
  // }

  // /// Handle foreground messages (when app is open)
  // void _handleForegroundMessage(RemoteMessage message) {
  //   debugPrint('Received foreground notification: ${message.data}');
  //   if (message.notification != null) {
  //     _showNotification(
  //       title: message.notification!.title ?? 'New Notification',
  //       body: message.notification!.body ?? '',
  //     );
  //   }
  // }
  //
  // /// Handle notification click (when app is in background or foreground)
  // void _handleNotificationClick(RemoteMessage message) {
  //   debugPrint("Notification clicked: ${message.data}");
  //   _handleNavigation(message);
  // }
  //
  // /// Handle navigation based on notification data
  // static void _handleNavigation(RemoteMessage message) {
  //   final Map<String, dynamic> data = message.data;
  //   final String? route = data['route'];
  //   final String? orderId = data['orderId'];
  //   final String? userId = data['userId'];
  //
  //   if (route != null) {
  //     navigatorKey.currentState?.pushNamed(
  //       route,
  //       arguments: {
  //         'orderId': orderId,
  //         'userId': userId,
  //       },
  //     );
  //   }
  //   // else {
  //   //   final notificationArgs = NotificationArgs(
  //   //     title: message.notification?.title ?? '',
  //   //     body: message.notification?.body ?? '',
  //   //   );
  //   //   navigatorKey.currentState?.pushNamed(
  //   //     AppRoutes.notificationView,
  //   //     arguments: notificationArgs,
  //   //   );
  //   // }
  // }
  //
  // /// Subscribe to a topic
  // Future<void> subscribeToTopic(String topic) async {
  //   await messaging.subscribeToTopic(topic);
  //   debugPrint('✅ Subscribed to topic: $topic');
  // }
  //
  // /// Unsubscribe from a topic
  // Future<void> unsubscribeFromTopic(String topic) async {
  //   await messaging.unsubscribeFromTopic(topic);
  //   debugPrint('❌ Unsubscribed from topic: $topic');
  // }

  /// Send Notification (Topic-based or Token-based)
  Future<void> sendNotification({
    String? topic,
    String? token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    final String serverToken = await FirebaseServerToken().getAccessToken();

    final Map<String, dynamic> notificationPayload = {
      "message": {
        if (topic != null) "topic": topic else "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": data,
      },
    };

    try {
      final response = await Dio().post(
        dotenv.get('NOTIFICATION_BASE_URL'),
        options: Options(
          headers: {
            'Authorization': 'Bearer $serverToken',
            'Content-Type': 'application/json',
          },
        ),
        data: notificationPayload,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Notification sent successfully: ${response.data}');
      } else {
        debugPrint('❌ Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: ${e.toString()}');
    }
  }

  /// Get the FCM device token
  Future<String?> getDeviceToken() async {
    final deviceToken = await messaging.getToken();
    debugPrint('📲 Device FCM Token: $deviceToken');
    return deviceToken;
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Local Notification Clicked: ${response.payload}');
      },
    );
  }

}
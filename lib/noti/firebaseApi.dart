import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    final fcmToken = await firebaseMessaging.getToken();
    print("FCM Token - $fcmToken");


    // local notification
    var androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidInitialization);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Title - ${message.notification?.title}");
    print("Body - ${message.notification?.body}");
    print("Payload - ${message.data}");

    await showNotification(message.notification?.title ?? 'No Title', message.notification?.body ?? 'No Body');
  }

  Future<void> showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'This is the description of the channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: 'test',
    );
  }
}

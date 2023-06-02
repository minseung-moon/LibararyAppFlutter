import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstapp/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a bacground message : ${message.messageId}");
}

Future<String?> fcmSetting() async {
  // firebase core 기능 사용을 위한 필수 initalizing
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permisstion: ${settings.authorizationStatus}');

  // foreground에서의 푸시 아림 표시를 위한 알림 중요도 설정(안드로이드)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'somain_notification',
      'somain_notification',
      '소마인 알림입니다.',
      importance: Importance.max
    );

  // foreground 에서의 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    print('Got a Message whilst in the foreground!');
    print('Message data: ${message.data}');

    if(message.notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification?.title,
          notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android.smallIcon,
            ),
          ));
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // firebase token 발급
  String? firebaseToken = await messaging.getToken();

  print('firebaseToken : ${firebaseToken}');

  return firebaseToken;
}
import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background handler triggered');
  try {
    await NotificationService.instance.setupFlutterNotifications();
    await NotificationService.instance.showNotification(message);
    log('Notification shown in background');
  } catch (e) {
    log('Error in background handler: $e');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    log('Initializing NotificationService...');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final settings = await FirebaseMessaging.instance.requestPermission();
  log('Permission status: ${settings.authorizationStatus}');

    
    try {
      // Request permission
      await _requestPermission();

      // Setup message handlers
      await _setupMessageHandlers();

      // Get FCM token
      log('Fetching FCM token...');
      final token = await _messaging.getToken();
      log("Firebase Initialized");
      print('FCM Token: $token');
    } catch (e) {
      log('Error during initialization: $e');
    }
  }

  Future<void> _requestPermission() async {
    log('Requesting permission...');
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      log('Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      log('Error requesting permission: $e');
    }
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      log('Flutter local notifications already initialized.');
      return;
    }

    try {
      log('Setting up Flutter notifications...');
      // Android setup
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS setup (Fixed onDidReceiveLocalNotification Issue)
      final initializationSettingsDarwin = DarwinInitializationSettings();

      final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Flutter notification setup
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          log("Notification Clicked: ${details.payload}");
        },
      );

      _isFlutterLocalNotificationsInitialized = true;
      log('Flutter local notifications initialized successfully.');
    } catch (e) {
      log('Error setting up Flutter notifications: $e');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    log('Preparing to show notification...');
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
        log('Notification displayed.');
      } else {
        log('No notification to display.');
      }
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    log('Setting up message handlers...');
    try {
      // Foreground message
      FirebaseMessaging.onMessage.listen((message) {
        log('Foreground message received: $message');
        showNotification(message);
      });

      // Background message
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Opened app
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        log('Initial message received: $initialMessage');
        _handleBackgroundMessage(initialMessage);
      }
    } catch (e) {
      log('Error setting up message handlers: $e');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    log('Handling background message: $message');
    if (message.data['type'] == 'chat') {
      // Open chat screen
      log('Navigating to chat screen...');
    }
  }
}
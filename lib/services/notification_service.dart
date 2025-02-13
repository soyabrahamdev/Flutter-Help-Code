//* Versión 1.0.0
/*
  - Generar archivo json de configuración en Firebase y pegarlo en /android/app/
  - Poner en el main.dart dentro del void main():

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    NotificationService notificationService = NotificationService();
    await notificationService.initialize();
  
  - Convertir MyApp en un StateFul widget
  - Pegar en MyApp:
    
    final NotificationService notificationService;

  - Pegar en _MyStateApp():

  late StreamSubscription _messageSubscription;

    - Dentro de initState():

      _messageSubscription = widget.notificationService.messageStream.listen((message) {
        // Aquí puedes manejar el mensaje recibido
        print('Mensaje recibido en el stream: ${message.notification?.title}');
        // Realiza cualquier acción adicional aquí, como actualizar la UI
      });

    - En dispose():

    _messageSubscription.cancel(); // Cancelar la suscripción cuando el widget se destruya


*/

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // StreamController para emitir notificaciones
  final StreamController<RemoteMessage> _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  // Inicializar Firebase y configurar el servicio de notificaciones
  Future<void> initialize() async {
    await _requestPermissions();
    await _setupFirebaseMessaging();
    await _setupLocalNotifications();
  }

  // Solicitar permisos para notificaciones
  Future _requestPermissions() async {
    // NotificationSettings settings = 
    await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
  }

  // Configurar Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Configurar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('Mensaje recibido en primer plano: ${message.notification?.title}');
      _messageController.add(message);  // Emitir mensaje al Stream
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });

    // Configurar cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('Mensaje abierto desde segundo plano: ${message.notification?.title}');
      _messageController.add(message);  // Emitir mensaje al Stream
    });

    // Obtener el token del dispositivo
    String? token = await _firebaseMessaging.getToken();
    print('Token del dispositivo: $token');
  }

  // Configurar las notificaciones locales
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Crear el canal de notificación para Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'default_channel', // ID del canal
            'Default Channel', // Nombre del canal
            description: 'Este es el canal de notificaciones predeterminado',
            importance: Importance.high,
          );

    // Crear el canal de notificación
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Mostrar la notificación localmente
  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel', // ID del canal
          'Default Channel', // Nombre del canal
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', // El ícono personalizado
        );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
              0, // ID única de la notificación
              notification.title, // Título de la notificación
              notification.body, // Cuerpo de la notificación
              platformChannelSpecifics,
              payload: 'default_payload',
            );
  }

  // Cerrar el StreamController cuando ya no se necesite
  void dispose() {
    _messageController.close();
  }

}

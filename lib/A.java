import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/api_service.dart';

Future<void> registerFcm(String uuid,String apitoken) async {
  // 1) grab the FCM token
  final fcm = FirebaseMessaging.instance;
  final token = await fcm.getToken();
  if (token == null) throw Exception('FCM token is null');

  // 2) call your endpoint
  final success = await ApiService.updateFcmToken(
    uuid:     uuid,
    apiToken: apitoken,
    userId:   '',            // or your logged-in user’s ID
    fcmToken: token,
  );

  if (success) {
    print('✅ FCM token updated on server');
  } else {
    print('❌ Failed to update FCM token');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// Update the FCM token on your server
  ///
  /// - [uuid] is the path segment (`02e331e5-3746-41a1-a987-50f5eecd778f`)
  /// - [apiToken] is your query-param token (`pbYJx9…`)
  /// - [userId] can be blank or your internal user ID
  /// - [fcmToken] is the string from FirebaseMessaging.instance.getToken()
  static Future<bool> updateFcmToken({
    required String uuid,
    required String apiToken,
    required int userId,
    required String fcmToken,
  }) async {
    final url = Uri.parse(
      'https://livingconnect.in/api/$userId/update-fcm?token=$apiToken',
    );

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
      },
      body: jsonEncode({
        'user_id':    userId,
        'fcm_token':  fcmToken,
      }),
    );

    return response.  statusCode == 200;
  }
  static Future<void> logMessageReceived(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('https://yourserver.com/api/log-message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('✅ Message logged successfully');
      } else {
        print('❌ Failed to log message: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception while logging message: $e');
    }
  }
 static Future<void> sendPushNotification(String msg,String mobieno) async {
    const String url = 'https://livingconnect.in/api/02e331e5-3746-41a1-a987-50f5eecd778f/send-notification?token=pbYJx9mgrgQOYiw6YduNGkL5QwxITIvrJJCw2jmnI8VJOfDecIg1pHP3JuSOoDkG';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
        // NOTE: Cookies are not typically used in Flutter requests
        // If the API does not require this cookie, you can remove this line
        'Cookie': 'PHPSESSID=bk0lrirmqi5isphgm5u3oovs8e; waba_panel_session=aBr3Vli2dWTfnmit37Lab9e4iTqWcTZk3eCUq3Ej',
      },
      body: jsonEncode({
        'title': "hiiii",
        'body': "hiiii",
      }),
    );

    if (response.statusCode == 200) {

    } else {
      print('❌ Failed to send notification');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }
}

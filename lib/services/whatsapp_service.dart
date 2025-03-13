import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatsAppService {
  // WhatsApp Business API credentials
  static const String _accessToken =
      'EAAQoLsoaM5oBOxM5vjTZBdScuyAAE1UmYEKKXh4YckQ8iQfi3ZAX0XtJtmDi7j9QZA6ZCCy7RVM4nSZCc1kBUGFpoWnd6K1lxWVnlg9gQ0fTCe15dihjADvZAVXTo0KLZAvNzdiycFyZAI5GrbqR2iAwZAl7ZCLXorhY22gyLhpA8duFehrdxmZC3pNCOpCAiT0UnZCHbsMxsGRHem5zjOcaXskWYVD2rLPNSzoMnA8ZD';
  static const String _phoneId = '613909378466133';
  static const String _apiVersion = 'v18.0';
  static const String _baseUrl = 'https://graph.facebook.com';

  // Send a WhatsApp message to a phone number
  Future<bool> sendMessage(String phoneNumber, String message) async {
    try {
      // Format the phone number (remove any '+' and ensure it has country code)
      final formattedNumber = _formatPhoneNumber(phoneNumber);

      // Construct the API URL
      final url = '$_baseUrl/$_apiVersion/$_phoneId/messages';

      // Prepare the request body
      final body = {
        'messaging_product': 'whatsapp',
        'to': formattedNumber,
        'type': 'text',
        'text': {'body': message}
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Check if the request was successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('WhatsApp message sent successfully: ${response.body}');
        return true;
      } else {
        print(
            'Failed to send WhatsApp message: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      return false;
    }
  }

  // Format the phone number for WhatsApp API
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure it has the country code (assuming India +91 if not present)
    if (!digits.startsWith('91') && digits.length == 10) {
      digits = '91$digits';
    }

    return digits;
  }

  // Send a payment confirmation message
  Future<bool> sendPaymentConfirmation(String phoneNumber, String patientName,
      String appointmentDate, String appointmentTime) async {
    final message =
        'Hi $patientName, your payment is confirmed! Your appointment is scheduled for $appointmentDate at $appointmentTime. Please arrive 5 minutes early. Thank you!';
    return await sendMessage(phoneNumber, message);
  }
}

// SendMultiple - متن و خط فرستنده جدا برای هر گیرنده.
//
// برای پیام‌های شخصی‌سازی‌شده که با یک قالب ثابت پوشش داده نمی‌شوند. برخلاف
// SendBulk، اینجا Text و Sender در سطح هر گیرنده تعریف می‌شوند.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... PAYAM_RESAN_SENDER=... dart run examples/v3/send-multiple.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> sendMultiple(String apiKey, int sender) async {
  final payload = jsonEncode({
    'ApiKey': apiKey,
    'Recipients': [
      {
        'Sender': sender,
        'Destination': 9121112222,
        'Text': 'آقای محمدی، سفارش شما ارسال شد.',
        'UserTraceId': 1001,
      },
      {
        'Sender': sender,
        'Destination': 9121113333,
        'Text': 'خانم رضایی، سفارش شما ارسال شد.',
        'UserTraceId': 1002,
      },
    ],
  });

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client
      .postUrl(Uri.parse('https://api.sms-webservice.com/api/V3/SendMultiple'));
  request.headers.contentType =
      ContentType('application', 'json', charset: 'utf-8');
  request.add(utf8.encode(payload));

  final answer = await request.close();
  final body = await answer.transform(utf8.decoder).join();
  client.close();

  final response = jsonDecode(body);

  if (response['Success'] != true) {
    throw Exception(
        'ناموفق. کد ${response['ErrorCode']}: ${response['Error']}');
  }

  for (final message in response['Result']) {
    print('${message['UserTraceId']} => شناسه ${message['Id']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async => sendMultiple(
      Platform.environment['PAYAM_RESAN_API_KEY']!,
      int.parse(Platform.environment['PAYAM_RESAN_SENDER']!),
    );

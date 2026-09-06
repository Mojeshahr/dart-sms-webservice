// SendBulk - یک متن به چند گیرنده، هر کدام با شناسه پی‌گیری خودتان.
//
// روش پیشنهادی برای ارسال عملیاتی. کلید در بدنه درخواست می‌رود نه در نشانی،
// و برای هر گیرنده UserTraceId می‌پذیرد تا گزارش تحویل را بدون نگه‌داشتن Id
// سامانه بگیرید.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... PAYAM_RESAN_SENDER=... dart run examples/v3/send-bulk.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> sendBulk(String apiKey, int sender) async {
  final payload = jsonEncode({
    'ApiKey': apiKey,
    'Sender': sender,
    'Text': 'سفارش شما ثبت شد.',
    'Recipients': [
      {'Destination': 9121112222, 'UserTraceId': 1001},
      {'Destination': 9121113333, 'UserTraceId': 1002},
    ],
  });

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client
      .postUrl(Uri.parse('https://api.sms-webservice.com/api/V3/SendBulk'));
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
void main() async => sendBulk(
      Platform.environment['PAYAM_RESAN_API_KEY']!,
      int.parse(Platform.environment['PAYAM_RESAN_SENDER']!),
    );

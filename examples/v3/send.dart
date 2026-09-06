// Send - ساده‌ترین ارسال، یک متن به چند شماره با یک درخواست GET.
//
// برای آزمایش سریع خوب است. در محیط عملیاتی SendBulk را بردارید: کلید را از
// نشانی بیرون می‌برد و برای هر گیرنده شناسه پی‌گیری می‌پذیرد.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... PAYAM_RESAN_SENDER=... dart run examples/v3/send.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> send(String apiKey, int sender) async {
  // متد replace خودش دقیقاً یک بار encode می‌کند. اگر متن را پیش از این هم
  // encode کنید، پیامک با نویسه‌های %D8 به گوشی می‌رسد.
  final url = Uri.parse('https://api.sms-webservice.com/api/V3/Send').replace(
    queryParameters: {
      'ApiKey': apiKey,
      'Sender': '$sender',
      'Text': 'کد تأیید شما ۱۲۳۴۵۶ است',
      'Recipients': '9121112222,9121113333',
    },
  );

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client.getUrl(url);

  final answer = await request.close();
  final body = await answer.transform(utf8.decoder).join();
  client.close();

  final response = jsonDecode(body);

  if (response['Success'] != true) {
    throw Exception(
        'ناموفق. کد ${response['ErrorCode']}: ${response['Error']}');
  }

  for (final message in response['Result']) {
    print('شناسه ${message['Id']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async => send(
      Platform.environment['PAYAM_RESAN_API_KEY']!,
      int.parse(Platform.environment['PAYAM_RESAN_SENDER']!),
    );

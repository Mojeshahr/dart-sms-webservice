// AccountInfo - اعتبار باقی‌مانده و خطوط فعال حساب.
//
// سبک‌ترین متد سرویس و بهترین راه آزمودن کلید: چیزی ارسال نمی‌کند، اعتباری
// مصرف نمی‌کند، و حتی با اعتبار صفر هم جواب می‌دهد.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کتابخانه استاندارد دارت هم کلاینت
// HTTP دارد و هم JSON، پس pubspec.yaml لازم نیست.
//
// کلید حساب را داخل اپ نگذارید. هر رشته‌ای که در بسته اپ برود قابل استخراج
// است. کلید را هنگام اجرا از بک‌اند خودتان بگیرید و به این تابع بدهید.
// شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/account-info.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> accountInfo(String apiKey) async {
  final payload = jsonEncode({'ApiKey': apiKey});

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client
      .postUrl(Uri.parse('https://api.sms-webservice.com/api/V3/AccountInfo'));
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

  final result = response['Result'];
  print('اعتبار: ${result['Credit']}');

  for (final line in result['AvailableSenders']) {
    print('خط: $line');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async =>
    accountInfo(Platform.environment['PAYAM_RESAN_API_KEY']!);

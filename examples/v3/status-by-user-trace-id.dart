// StatusByUserTraceId - وضعیت پیامک با شناسه‌هایی که خودتان داده‌اید.
//
// اگر UserTraceId را کلید رکورد پایگاه داده خودتان بگذارید، دیگر لازم نیست Id
// سامانه را ذخیره کنید. این متد راه امن تشخیص ارسال تکراری هم هست: بعد از قطع
// ارتباط، اول اینجا بپرسید ثبت شده یا نه.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/status-by-user-trace-id.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> statusByUserTraceId(String apiKey) async {
  final payload = jsonEncode({
    'ApiKey': apiKey,
    'UserTraceIds': [1001, 1002],
  });

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client.postUrl(
      Uri.parse('https://api.sms-webservice.com/api/V3/StatusByUserTraceId'));
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
    // کد ۸ یعنی این شناسه در حساب شما نیست. بعد از یک timeout، همین یعنی
    // ارسال ثبت نشده و می‌توانید با خیال راحت دوباره بفرستید.
    if (message['StatusCode'] == 8) {
      print('${message['UserTraceId']}: ثبت نشده');
      continue;
    }

    print('${message['UserTraceId']}: ${message['Status']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async =>
    statusByUserTraceId(Platform.environment['PAYAM_RESAN_API_KEY']!);

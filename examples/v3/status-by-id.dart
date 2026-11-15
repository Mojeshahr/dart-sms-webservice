// StatusById - وضعیت پیامک با شناسه‌هایی که متد ارسال برگردانده است.
//
// دسته‌ای بپرسید، نه یکی‌یکی. فاصله استعلام‌ها را هم کمتر از چند دقیقه
// نگذارید، وگرنه به خطای ۲۰ می‌خورید.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/status-by-id.dart

// docs:start
import 'dart:convert';
import 'dart:io';

// شرط را روی StatusCode بگذارید، نه روی متن Status. این پنج کد یعنی هنوز در
// راه است و باید بعداً دوباره استعلام کنید، نه اینکه دوباره بفرستید.
const pending = {0, 1, 2, 3, 10};

Future<void> statusById(String apiKey) async {
  final payload = jsonEncode({
    'ApiKey': apiKey,
    'Ids': [9903211, 9903212],
  });

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client
      .postUrl(Uri.parse('https://www.payam-resan.com/api/V3/StatusById'));
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
    final again =
        pending.contains(message['StatusCode']) ? ' (بعداً دوباره بپرسید)' : '';
    print('${message['Id']}: ${message['Status']}$again');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async => statusById(Platform.environment['PAYAM_RESAN_API_KEY']!);

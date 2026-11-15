// TokenList - قالب‌های حساب، با کلید و متن و وضعیت تأییدشان.
//
// برای پیدا کردن TemplateKey که متدهای ارسال قالب لازم دارند. این متد هم مثل
// AccountInfo از بررسی اعتبار معاف است.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/token-list.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> tokenList(String apiKey) async {
  final payload = jsonEncode({'ApiKey': apiKey});

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client
      .postUrl(Uri.parse('https://www.payam-resan.com/api/V3/TokenList'));
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

  for (final template in response['Result']) {
    final sendable =
        template['Status'] == 2 ? 'قابل ارسال' : 'قابل ارسال نیست';
    print('${template['Key']} ($sendable): ${template['TextTemplate']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async => tokenList(Platform.environment['PAYAM_RESAN_API_KEY']!);

// SendTokenMulti - یک قالب، چند گیرنده، مقادیر متفاوت.
//
// پارامترها اینجا آرایه‌اند، نه p1 تا p10. درایه اول به {1} می‌نشیند، دومی به
// {2} و همین‌طور تا آخر: ترتیب از شماره جای‌گاه می‌آید، نه از جایی که در متن
// قالب دیده می‌شود.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. کلید را داخل اپ نگذارید؛ هنگام اجرا
// از بک‌اند خودتان بگیریدش. شرحش در README آمده.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/send-token-multi.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> sendTokenMulti(String apiKey) async {
  // قالب نمونه: «مرسوله شما از {2} تحویل پست شد. بارکد مرسوله پستی: {1}»
  final payload = jsonEncode({
    'ApiKey': apiKey,
    'TemplateKey': 'postcode',
    'Recipients': [
      {
        'Destination': 9121112222,
        'UserTraceId': 1001,
        'Parameters': ['BARCODE-AAA', 'شیراز'],
      },
      {
        'Destination': 9121113333,
        'UserTraceId': 1002,
        'Parameters': ['BARCODE-BBB', 'تبریز'],
      },
    ],
  });

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client.postUrl(
      Uri.parse('https://api.sms-webservice.com/api/V3/SendTokenMulti'));
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
    print('${message['UserTraceId']} => ${message['FinalText']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async =>
    sendTokenMulti(Platform.environment['PAYAM_RESAN_API_KEY']!);

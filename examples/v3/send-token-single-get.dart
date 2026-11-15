// SendTokenSingle با GET - همان ارسال قالب، با ورودی در نشانی.
//
// برای آزمایش دستی مناسب است، برای محیط عملیاتی نه: در GET هم کلید حساب و هم
// مقدار رمز یک‌بارمصرف داخل نشانی می‌نشینند و در لاگ وب‌سرور و هدر Referer
// ثبت می‌شوند. واریانت POST را بردارید.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. رمز یک‌بارمصرف را از خود اپ نفرستید؛
// جای این کار بک‌اند شماست.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/send-token-single-get.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> sendTokenSingleByQuery(String apiKey) async {
  final url =
      Uri.parse('https://www.payam-resan.com/api/V3/SendTokenSingle')
          .replace(queryParameters: {
    'ApiKey': apiKey,
    'TemplateKey': 'verifycode',
    'Destination': '9121112222',
    'p1': '123456',
  });

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
    print('شناسه ${message['Id']}، متن نهایی: ${message['FinalText']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async =>
    sendTokenSingleByQuery(Platform.environment['PAYAM_RESAN_API_KEY']!);

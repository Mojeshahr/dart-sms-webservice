// SendTokenSingle - ارسال قالب به یک شماره، با بدنه JSON.
//
// مسیر معمول رمز یک‌بارمصرف. خط فرستنده ورودی ندارد؛ سامانه آن را از روی خود
// قالب برمی‌دارد. همین واریانت POST را به کار ببرید، نه GET: در GET هم کلید
// حساب و هم خود رمز داخل نشانی و لاگ وب‌سرور می‌نشینند.
//
// به هیچ بسته‌ای از pub.dev وابسته نیست. رمز یک‌بارمصرف را از خود اپ نفرستید؛
// اپ نباید کلید حساب را داشته باشد و نباید تعیین کند چه کدی برای چه شماره‌ای
// می‌رود. جای این کار بک‌اند شماست.
//
//   PAYAM_RESAN_API_KEY=... dart run examples/v3/send-token-single.dart

// docs:start
import 'dart:convert';
import 'dart:io';

Future<void> sendTokenSingle(String apiKey) async {
  final payload = jsonEncode({
    'ApiKey': apiKey,
    'TemplateKey': 'verifycode',
    'Destination': 9121112222,
    'p1': '123456',
  });

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final request = await client.postUrl(
      Uri.parse('https://www.payam-resan.com/api/V3/SendTokenSingle'));
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

  // این متد UserTraceId در ورودی ندارد، پس در پاسخ null برمی‌گردد. اگر شناسه
  // پی‌گیری لازم دارید، SendTokenMulti را حتی برای یک گیرنده هم می‌شود به کار برد.
  for (final message in response['Result']) {
    print('شناسه ${message['Id']} از خط ${message['Sender']}');
    print('متن نهایی: ${message['FinalText']}');
  }
}
// docs:end

// همین فایل از خط فرمان هم اجرا می‌شود تا ببینید سرویس چه برمی‌گرداند. در اپ
// واقعی این بخش وجود ندارد و کلید از بک‌اند خودتان می‌آید.
void main() async =>
    sendTokenSingle(Platform.environment['PAYAM_RESAN_API_KEY']!);

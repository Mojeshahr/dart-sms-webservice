<div align="center">

<a href="https://payam-resan.com">
  <img src=".github/assets/logo.svg" width="64" height="64" alt="پیام رسان">
</a>

<h1>نمونه‌کدهای Dart وب‌سرویس پیام رسان</h1>

اتصال به وب‌سرویس <a href="https://payam-resan.com"><b>پنل پیامکی پیام رسان</b></a> با Dart و Flutter<br>
یک فایل قابل اجرا به‌ازای هر متد سرویس، بدون هیچ وابستگی

[![API](https://img.shields.io/badge/API-V3-0a7cbd)](https://payam-resan.com)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175c2)](https://dart.dev)
[![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)](#شروع-سریع)
[![License](https://img.shields.io/badge/license-MIT-6e7781)](LICENSE)

<b>فارسی</b> · <a href="README.en.md">English</a>

</div>

<sub>دنبال زبان دیگری هستید؟ همین نمونه‌ها برای زبان‌های دیگر هم در
[github.com/Mojeshahr](https://github.com/Mojeshahr) هست.</sub>

---

## شروع سریع

```bash
git clone https://github.com/Mojeshahr/dart-sms-webservice.git
cd dart-sms-webservice

export PAYAM_RESAN_API_KEY='123456-XXXXXXXXXXXXXXX'
export PAYAM_RESAN_SENDER='30004040'

dart run examples/v3/account-info.dart
```

نه `pubspec.yaml` لازم است و نه `dart pub get`. کتابخانه استاندارد دارت هم
کلاینت HTTP دارد (`dart:io`) و هم JSON (`dart:convert`)، پس بسته‌ای از
pub.dev لازم نیست.

با `account-info.dart` شروع کنید: چیزی ارسال نمی‌کند، اعتباری مصرف نمی‌کند، و
اگر جواب داد یعنی کلید و اتصال هر دو سالم‌اند.

## فلاتر و کلید حساب

این مهم‌ترین بخش این صفحه است.

کلید حساب را داخل اپ نگذارید. هر رشته‌ای که در APK یا IPA برود قابل استخراج
است، و هر کسی که آن را دربیاورد با اعتبار شما پیامک می‌فرستد. نه در کد، نه در
`--dart-define`، نه در فایل asset، و نه در پایگاه داده محلی اپ.

جای درستش بک‌اند خودتان است. اپ به سرور شما می‌گوید «برای این کاربر کد
بفرست»، سرور شما تصمیم می‌گیرد و با کلید خودش این سرویس را صدا می‌زند. برای
رمز یک‌بارمصرف این حتی مهم‌تر است: اپ نباید تعیین کند چه کدی برای چه شماره‌ای
می‌رود.

برای همین توابع این مخزن کلید را **پارامتر** می‌گیرند و از متغیر محیطی
نمی‌خوانند؛ در اپ فلاتر متغیر محیطی وجود ندارد. نمونه‌ها سرویس را مستقیم صدا
می‌زنند تا شکل درخواست را نشان بدهند، و آن شکل همان است، چه از اپ صدایش بزنید
چه از سرورتان. در محصول واقعی از سرورتان صدایش بزنید.

## چرا بسته http نیست

نمونه‌ها روی `dart:io` نوشته شده‌اند، نه روی `package:http`. کتابخانه
استاندارد هم HTTP دارد و هم JSON، پس افزودن یک بسته چیزی به دست نمی‌آورد و
یک وابستگی به خواننده تحمیل می‌کند.

یک استثنا هست: **فلاتر وب** به `dart:io` دسترسی ندارد. اگر واقعاً از مرورگر
صدا می‌زنید، `package:http` لازمتان می‌شود؛ ولی آنجا کلید در جاوااسکریپت
مرورگر دیده می‌شود و درست‌ترین کار همان عبور از بک‌اند خودتان است.

## پیش از ارسال واقعی

یک سرور آزمایشی هست که مثل سرور عملیاتی جواب می‌دهد ولی پیامکی نمی‌فرستد و
اعتباری مصرف نمی‌کند. کافی است `V3` در نشانی را با `V3SandBox` عوض کنید. تنها
استثنا `TokenList` است که روی آن سرور پیاده نشده.

## متدها

<div dir="rtl">

| نمونه | متد | کار |
|---|---|---|
| [account-info.dart](examples/v3/account-info.dart) | `AccountInfo` | اعتبار و خطوط فعال |
| [send.dart](examples/v3/send.dart) | `Send` | ارسال ساده با `GET` |
| [send-bulk.dart](examples/v3/send-bulk.dart) | `SendBulk` | یک متن به چند گیرنده، با شناسه پی‌گیری |
| [send-multiple.dart](examples/v3/send-multiple.dart) | `SendMultiple` | متن جدا برای هر گیرنده |
| [token-list.dart](examples/v3/token-list.dart) | `TokenList` | فهرست قالب‌ها |
| [send-token-single.dart](examples/v3/send-token-single.dart) | `SendTokenSingle` | ارسال قالب به یک شماره |
| [send-token-single-get.dart](examples/v3/send-token-single-get.dart) | `SendTokenSingle` | همان، با `GET` |
| [send-token-multi.dart](examples/v3/send-token-multi.dart) | `SendTokenMulti` | یک قالب، چند گیرنده |
| [status-by-id.dart](examples/v3/status-by-id.dart) | `StatusById` | وضعیت با شناسه سامانه |
| [status-by-user-trace-id.dart](examples/v3/status-by-user-trace-id.dart) | `StatusByUserTraceId` | وضعیت با شناسه خودتان |
| [get-inbox.dart](examples/v3/get-inbox.dart) | `GetInbox` | پیامک‌های رسیده |

</div>

## استفاده در پروژه خودتان

نمونه‌ها عمداً به هیچ چیز این مخزن وابسته نیستند، پس کپی‌کردن تابع داخل پروژه
شما کافی است. اگر در پروژه‌تان `package:http` دارید، لایه `dart:io` را نبرید و
فقط بدنه درخواست و بررسی `Success` را بردارید:

```dart
final answer = await http.post(
  Uri.parse('https://api.sms-webservice.com/api/V3/SendBulk'),
  headers: {'Content-Type': 'application/json; charset=utf-8'},
  body: jsonEncode({
    'ApiKey': apiKey,
    'Sender': 30004040,
    'Text': 'کد تأیید شما ۱۲۳۴۵۶ است',
    'Recipients': [
      {'Destination': 9121112222, 'UserTraceId': 1001},
    ],
  }),
);

final response = jsonDecode(utf8.decode(answer.bodyBytes));

if (response['Success'] != true) {
  throw Exception('پیامک ارسال نشد: ${response['Error']} (کد ${response['ErrorCode']})');
}
```

توجه کنید که آنجا `answer.bodyBytes` را با `utf8.decode` می‌خوانیم نه
`answer.body` را: بسته http وقتی سرویس charset را در هدر نگوید، latin-1 فرض
می‌کند و متن فارسی پاسخ خراب می‌شود.

## چند نکته که وقت‌تان را می‌خرد

**کد وضعیت HTTP را نخوانید.** سرویس همیشه `200` برمی‌گرداند، حتی وقتی کلید
اشتباه است، پس `answer.statusCode` چیزی ثابت نمی‌کند. تصمیم را از فیلد
`Success` بگیرید. هر نمونه اینجا همین کار را می‌کند.

**شماره گیرنده صفر ابتدایی ندارد.** یعنی `9121112222` یا با کد کشور
`989121112222`. شماره‌ای که با `9` یا `989` شروع نشود کد خطای `13` می‌گیرد.

**متن را دوباره encode نکنید.** در `send.dart` متد `Uri.replace` خودش یک بار
این کار را می‌کند. اگر پیش از آن هم `Uri.encodeComponent` بزنید، پیامک با
نویسه‌های `%D8` به گوشی می‌رسد.

**برای هر گیرنده یک `UserTraceId` یکتا بفرستید.** بعد از یک timeout، این تنها
راه فهمیدن این است که پیامک ثبت شده یا نه.

## امنیت کلید

کلید یک راز است. در مخزن کد، در جاوااسکریپت مرورگر و در بسته اپلیکیشن موبایل
نباید قرار بگیرد. روی سرور جایش متغیر محیطی است و در موبایل باید از بک‌اند
خودتان بیاید.

اگر کلیدی لو رفت، از پنل یکی تازه بسازید. کلید حذف‌شده برنمی‌گردد.

## ساختار

<div dir="rtl">

| مسیر | چه چیزی دارد |
|---|---|
| `examples/v3/` | یک نمونه مستقل به‌ازای هر عملیات سرویس |
| `.env.example` | نمونه متغیرهای محیطی |

</div>

عدد `v3` در مسیر عمدی است. نسخه تازه سرویس یعنی پوشه `examples/v<n>/` تازه، و
پوشه موجود دست‌نخورده می‌ماند.

## مستندات و پشتیبانی

راهنمای کامل وب‌سرویس در [docs.payam-resan.com](https://docs.payam-resan.com)
است. توصیف ماشین‌خوان OpenAPI هم در
[sms-webservice-spec](https://github.com/Mojeshahr/sms-webservice-spec).

سؤال یا خطایی هست؟ [issue باز کنید](https://github.com/Mojeshahr/dart-sms-webservice/issues)
یا با [پشتیبانی](https://payam-resan.com) تماس بگیرید.

## مجوز

منتشرشده با مجوز MIT. متن کامل در [`LICENSE`](LICENSE).

<br>
<div align="center">
  <sub>
    <img src=".github/assets/logo.svg" width="16" height="16" alt="" align="top">
    &nbsp;<b>پنل پیامکی پیام رسان - موج شهر</b>&nbsp;
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset=".github/assets/mojeshahr-dark.svg">
      <img src=".github/assets/mojeshahr-light.svg" width="16" height="16" alt="" align="top">
    </picture>
  </sub>
  <br>
  <sub>
    <a href="https://payam-resan.com">payam-resan.com</a>
    &nbsp;·&nbsp;
    <a href="https://mojeshahr.ir">mojeshahr.ir</a>
  </sub>
</div>

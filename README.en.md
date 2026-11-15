<div align="center">

<a href="https://payam-resan.com">
  <img src=".github/assets/logo.svg" width="64" height="64" alt="Payam Resan">
</a>

<h1>Dart examples for the Payam Resan SMS web service</h1>

Talk to the <a href="https://payam-resan.com"><b>Payam Resan SMS panel</b></a> from Dart and Flutter<br>
One runnable file per API method, with no dependencies

[![API](https://img.shields.io/badge/API-V3-0a7cbd)](https://payam-resan.com)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175c2)](https://dart.dev)
[![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)](#quick-start)
[![License](https://img.shields.io/badge/license-MIT-6e7781)](LICENSE)

<a href="README.md">فارسی</a> · <b>English</b>

</div>

<sub>Looking for another language? The same examples exist for the others at
[github.com/Mojeshahr](https://github.com/Mojeshahr).</sub>

---

## Quick start

```bash
git clone https://github.com/Mojeshahr/dart-sms-webservice.git
cd dart-sms-webservice

export PAYAM_RESAN_API_KEY='123456-XXXXXXXXXXXXXXX'
export PAYAM_RESAN_SENDER='30004040'

dart run examples/v3/account-info.dart
```

No `pubspec.yaml` and no `dart pub get`. Dart's standard library has both the
HTTP client (`dart:io`) and JSON (`dart:convert`), so nothing from pub.dev is
needed.

Start with `account-info.dart`. It sends nothing, spends no credit, and if it
answers then both the key and the connection are fine.

## Flutter and the account key

This is the most important section on the page.

Do not put the key inside the app. Any string shipped in an APK or IPA can be
extracted, and whoever extracts it sends SMS on your credit. Not in code, not
in `--dart-define`, not in an asset file, and not in the app's local database.

It belongs on your own backend. The app asks your server to "send a code to
this user", your server decides and calls this service with its own key. For a
one-time password this matters even more: the app should not get to decide
which code goes to which number.

That is why the functions here take the key as a **parameter** rather than
reading an environment variable: a Flutter app has none. The examples call the
service directly so you can see the shape of the request, and that shape is the
same either way. In a real product, make the call from your server.

## Why not package:http

The examples are written on `dart:io`, not `package:http`. The standard library
already has HTTP and JSON, so adding a package would buy nothing and impose a
dependency on the reader.

There is one exception: **Flutter Web** has no access to `dart:io`. If you
really are calling from a browser you will need `package:http`, but there the
key is visible in browser JavaScript, and going through your own backend is the
right answer anyway.

## Before sending anything real

There is a sandbox server that answers exactly like production but sends no
message and spends no credit. Swap `V3` for `V3SandBox` in the URL. The one
exception is `TokenList`, which the sandbox does not implement.

## The methods

| Example | Method | What it does |
|---|---|---|
| [account-info.dart](examples/v3/account-info.dart) | `AccountInfo` | Credit and active lines |
| [send.dart](examples/v3/send.dart) | `Send` | Simple send over `GET` |
| [send-bulk.dart](examples/v3/send-bulk.dart) | `SendBulk` | One text to many recipients, with tracking ids |
| [send-multiple.dart](examples/v3/send-multiple.dart) | `SendMultiple` | A separate text per recipient |
| [token-list.dart](examples/v3/token-list.dart) | `TokenList` | The account's templates |
| [send-token-single.dart](examples/v3/send-token-single.dart) | `SendTokenSingle` | Send a template to one number |
| [send-token-single-get.dart](examples/v3/send-token-single-get.dart) | `SendTokenSingle` | The same, over `GET` |
| [send-token-single-concat-param.dart](examples/v3/send-token-single-concat-param.dart) | `SendTokenSingleConcatParam` | Template values in one semicolon-separated `p` string |
| [send-token-single-concat-param-get.dart](examples/v3/send-token-single-concat-param-get.dart) | `SendTokenSingleConcatParam` | The same, over `GET` |
| [send-token-multi.dart](examples/v3/send-token-multi.dart) | `SendTokenMulti` | One template, many recipients |
| [status-by-id.dart](examples/v3/status-by-id.dart) | `StatusById` | Status by the service's id |
| [status-by-user-trace-id.dart](examples/v3/status-by-user-trace-id.dart) | `StatusByUserTraceId` | Status by your own id |
| [get-inbox.dart](examples/v3/get-inbox.dart) | `GetInbox` | Messages people sent to your lines |

## Using this in your own project

Every example is deliberately free of any dependency on this repository, so
copying the function into your project is enough. If your project already has
`package:http`, leave the `dart:io` layer behind and take only the request body
and the `Success` check:

```dart
final answer = await http.post(
  Uri.parse('https://www.payam-resan.com/api/V3/SendBulk'),
  headers: {'Content-Type': 'application/json; charset=utf-8'},
  body: jsonEncode({
    'ApiKey': apiKey,
    'Sender': 30004040,
    'Text': 'Your verification code is 123456',
    'Recipients': [
      {'Destination': 9121112222, 'UserTraceId': 1001},
    ],
  }),
);

final response = jsonDecode(utf8.decode(answer.bodyBytes));

if (response['Success'] != true) {
  throw Exception('SMS not sent: ${response['Error']} (code ${response['ErrorCode']})');
}
```

Note the `utf8.decode(answer.bodyBytes)` rather than `answer.body`: when the
service does not state a charset in the header, package:http assumes latin-1
and the Persian text in the answer comes back mangled.

## Things that will save you time

**Do not read the HTTP status code.** The service answers `200` to everything,
including a wrong key, so `answer.statusCode` proves nothing. Decide on the
`Success` field. Every example here does.

**Recipient numbers carry no leading zero.** Use `9121112222`, or
`989121112222` with the country code. A number that does not start with `9` or
`989` returns error code `13`.

**Do not encode the text twice.** In `send.dart`, `Uri.replace` already does it
once. Call `Uri.encodeComponent` beforehand and the message arrives full of
`%D8`.

**Send a unique `UserTraceId` per recipient.** After a timeout it is the only
way to learn whether the message was registered.

## Key safety

The key is a secret. It does not belong in a code repository, in browser
JavaScript, or in a mobile app bundle. On a server it belongs in an environment
variable; on mobile it has to come from your own backend.

If a key leaks, issue a new one from the panel. A deleted key never comes back.

## Layout

| Path | What it holds |
|---|---|
| `examples/v3/` | One self-contained example per service operation |
| `.env.example` | The environment variables the examples read |

The `v3` in the path is deliberate. A new service version means a new
`examples/v<n>/`, with the existing folder left alone.

## Documentation and support

The full guide to the web service is at
[docs.payam-resan.com](https://docs.payam-resan.com), and the machine-readable
OpenAPI description is in
[sms-webservice-spec](https://github.com/Mojeshahr/sms-webservice-spec).

Question or bug? [Open an issue](https://github.com/Mojeshahr/dart-sms-webservice/issues)
or contact [support](https://payam-resan.com).

## License

Released under the MIT license. Full text in [`LICENSE`](LICENSE).

<br>
<div align="center">
  <sub>
    <img src=".github/assets/logo.svg" width="16" height="16" alt="" align="top">
    &nbsp;<b>Payam Resan SMS Panel - Moje Shahr</b>&nbsp;
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

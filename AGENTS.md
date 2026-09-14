# Working with this repository

You are looking at runnable Dart examples for the **Payam Resan** SMS web
service (`api.sms-webservice.com`, API V3), an Iranian SMS provider. Someone is
probably asking you to add SMS to a Dart or Flutter project.

Read Rule 1 before you write any code. It changes where the code goes.

## Rule 1: the key must not ship inside the app

This is the most important thing on this page, and it is the one a Flutter
developer gets wrong.

Any string shipped in an APK or IPA can be extracted, and whoever extracts it
sends SMS on the user's credit. Not in code, not in `--dart-define`, not in an
asset file, and not in the app's local database. Obfuscation does not help; the
string still has to exist at runtime.

**The call belongs on the user's own backend.** The app asks their server
"send a code to this user", the server decides and calls this service with its
own key. For a one-time password this matters more, not less: the app must not
get to choose which code goes to which number, or a user can request a code for
someone else's phone and read it out of their own request.

That is why every function here takes the key as a **parameter**:

```dart
Future<void> sendBulk(String apiKey, int sender) async {
```

not from an environment variable — a Flutter app has none. The examples call the
service directly so you can see the shape of the request, and the shape is the
same wherever it runs. In a real product, make the call from the server.

If the user insists on calling from the app, say plainly that it exposes their
account, and offer the backend shape instead. Their server can use any of the
other repositories at <https://github.com/Mojeshahr>.

## Start here

```bash
export PAYAM_RESAN_API_KEY='123456-XXXXXXXXXXXXXXX'
dart run examples/v3/account-info.dart
```

`account-info.dart` sends nothing, spends no credit, and answers even on a zero
balance, so run it first to prove the key and the connection work.

Dart 3.0 or newer. Zero packages: `dart:io` gives the HTTP client and
`dart:convert` gives JSON, so there is no `pubspec.yaml` and nothing to fetch.

Each file has the reusable function between `// docs:start` and `// docs:end`,
and a `void main()` below it that reads `Platform.environment` just so the file
can be run from a terminal. Copy the function, not the `main`.

## Rule 2: Flutter Web is the one place `dart:io` fails

`dart:io` does not exist in a browser. If the user is on Flutter Web they would
need `package:http` — but that is also exactly the case where the key would sit
in browser JavaScript for anyone to read. The answer there is not a different
package, it is a backend.

## Rule 3: `Success`, never the HTTP status

The service answers `200` to everything, including a wrong key, an empty account
and a malformed body. `answer.statusCode` proves nothing.

Write the check as `!= true`, not `!response['Success']`:

```dart
if (response['Success'] != true) {
  throw Exception('ناموفق. کد ${response['ErrorCode']}: ${response['Error']}');
}
```

The value arrives from `jsonDecode` as `dynamic`, and a body that is not the
usual envelope gives `null` there. `!= true` treats that as a failure, which it
is. `!response['Success']` throws on null instead of reporting it.

`ErrorCode` is only meaningful when `Success` is false.

## Rule 4: decode the body as bytes, not as a string

The examples here read the response with
`await answer.transform(utf8.decoder).join()`, which is correct by construction.

If you port to `package:http`, the trap is live:

```dart
final response = jsonDecode(utf8.decode(answer.bodyBytes));  // right
final response = jsonDecode(answer.body);                    // mangles Persian
```

When the service does not state a charset in the header, `package:http` assumes
latin-1 and the Persian text in the answer comes back garbled.

## Rule 5: pick the right method

| The user wants | Use | File |
|---|---|---|
| one text to many people | `SendBulk` | `send-bulk.dart` |
| a different text per person | `SendMultiple` | `send-multiple.dart` |
| a one-time password or code | `SendTokenSingle` | `send-token-single.dart` |
| a template to many people | `SendTokenMulti` | `send-token-multi.dart` |
| delivery status | `StatusByUserTraceId` | `status-by-user-trace-id.dart` |
| balance and sender lines | `AccountInfo` | `account-info.dart` |

**A one-time password goes through a template**, not free text — that is the
usual route for OTP, and the template fixes the sender line, which is why
`SendTokenSingle` takes no `Sender`. `token-list.dart` lists the account's
templates; `Status` `2` means approved and sendable, `1` awaiting review, `3`
rejected.

**Use the POST variant for OTP**, never `send-token-single-get.dart`. In the GET
form both the account key and the code itself land in the URL, the web server
log and the `Referer` header.

## Rule 6: build the URL, do not concatenate it

GET examples use `Uri.parse(...).replace(queryParameters: {...})`, which encodes
each value exactly once. Concatenate or pre-encode and Persian text arrives as
literal `%D8` sequences in the message.

## Rule 7: phone numbers have no leading zero

The service wants `9121112222` or `989121112222`. Users type `09121112222` or
`+989121112222`. Normalise before sending, or you get error `13`.

Ninety-nine recipients per request is the ceiling for `SendBulk`,
`SendMultiple` and `SendTokenMulti`.

## Rule 8: always send a `UserTraceId`

Use the user's own database id. After a timeout or error `100`, resending blind
may send twice — `StatusByUserTraceId` is the only safe way to learn whether the
message was registered. Status code `8` there means "not registered", so it is
safe to send again.

`SendTokenSingle` is the exception: it has no such input, so its `UserTraceId`
comes back null. If a trace id is needed for an OTP, use `SendTokenMulti` with a
single recipient.

## Rule 9: know which errors are worth retrying

These never succeed on retry — fix the cause; retrying only burns the rate limit
until the account hits error `20`:

`1`, `2`, `3`, `6`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `19`

`19` is an empty balance; `10` means the caller's IP is not on the account's
allowlist. Treat any unknown code the way you treat `100`: unclear outcome,
check with `StatusByUserTraceId` before resending.

## Rule 10: delivery status is a poll, not a callback

Status codes `0`, `1`, `2`, `3` and `10` mean still in flight — query again
later, and not more often than every few minutes or you will hit error `20`.
Everything else is final. Branch on `StatusCode`, never on the `Status` text,
which is Persian prose meant for humans and can change.

## Rule 11: `GetInbox` consumes what it returns

The service hands over each incoming message **once**. Never call it from a
screen or a request handler: every call consumes unread messages permanently. It
belongs in a scheduled job on the server that writes straight to storage.

The sender field is called `Form`, not `From`. That is the service's spelling.

## Testing without spending credit

Replace `V3` with `V3SandBox` in the URL. No message is sent and no credit is
spent. `TokenList` is not implemented there.

The sandbox is a simulator, not a mirror of the account: credit is always
`1234567`, sender lines are invented, and **it accepts any key**. Success there
proves nothing about the user's real key.

## Where the authoritative answers are

- Method reference and error tables: <https://docs.payam-resan.com>
- Machine-readable OpenAPI: <https://github.com/Mojeshahr/sms-webservice-spec>

If the spec and these examples ever disagree, the spec wins — report it as a bug
rather than guessing.

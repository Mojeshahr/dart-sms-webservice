# Contributing

Maintainer notes for this repository: the rules that keep the examples
consistent with the other language repositories and with the documentation site.

If you came here to integrate the service into your own project, read
`AGENTS.md` instead. This file is about changing the examples, not using them.

## Rule one: no dependencies

An example runs with a stock Dart SDK and nothing else. `dart:io` has the HTTP
client and `dart:convert` has JSON, so there is no `pubspec.yaml`, no
`dart pub get` and nothing from pub.dev. A reader copies the function into their
project and it works.

Do not reach for `package:http` here. The one case it would be needed is Flutter
Web, which has no `dart:io`, and that is also the one case where the key should
never be in the client to begin with. The README says so; the examples stay
dependency free.

## Rule two: the key is a parameter, not an environment variable

A Flutter app has no environment variables, and a key shipped inside an APK or
IPA can be extracted. So every function takes `apiKey: String` and the header of
every file says the key must come from the reader's own backend.

`void main()` sits **below** `docs:end` on purpose. It reads
`Platform.environment` so the file can be run from a terminal and checked, while
the documentation tab shows only the function a reader would actually call.

Whichever way you touch a file, the key never appears in the code.

## Rule three: the examples are the documentation

Each file carries `// docs:start` and `// docs:end`. The region between them is
lifted verbatim into the method's page on docs.payam-resan.com, so it is read by
people who have never seen this repository.

Two consequences:

- **Full-line comments are stripped** when the region is lifted. Anything the
  reader must see has to be code. The `Success` check is an `if`, not a note.
- The file name matches the reference page slug exactly: `send-bulk.dart`,
  `status-by-user-trace-id.dart`. A path with two variants gets two files, the
  plain name for `POST` and a `-get` suffix for `GET`.

The full contract lives in the `handbook` repository, section `docs-site`, file
`code-samples.md`.

## Rule four: check Success, never the status code

The service answers `200` to everything, including a wrong key and an empty
account, so `answer.statusCode` proves nothing:

```dart
if (response['Success'] != true) {
  throw Exception('ناموفق. کد ${response['ErrorCode']}: ${response['Error']}');
}
```

An uncaught exception ends the process with a non-zero status, which is what a
reader running the file from a terminal wants.

Write the check as `!= true`, not `!response['Success']`. The value arrives from
`jsonDecode` as `dynamic`, and a body that is not the usual envelope gives
`null` there; `!= true` treats that as a failure, which it is.

## Rule five: build the URL, do not concatenate it

GET examples use `Uri.parse(...).replace(queryParameters: {...})`. That encodes
each value exactly once, which is the lesson the reader needs, and it keeps the
base URL a visible literal so tooling can rewrite it.

## Rule six: a version is a folder

A new service version means a new `examples/v<n>/`. No file inside an existing
version folder is moved or renamed; older versions still have users.

## Secrets

No key, no real phone number and no customer name goes into a file here, not
even a dead one. Example numbers are `9121112222` upward and the example key is
`123456-XXXXXXXXXXXXXXX`.

## Layout

| Path | What it holds |
|---|---|
| `examples/v3/` | one self-contained file per service operation |
| `.env.example` | the environment variables the runnable `main` reads |

## Before every commit

```bash
dart analyze --fatal-infos examples/v3
for f in examples/v3/*.dart; do dart run "$f" >/dev/null || echo "FAILED $f"; done
```

Point them at `api/V3SandBox/` before running one for real, so no message goes
out.

## Git

Semantic messages, `type(scope): subject`, with no explanatory body and no
attribution trailer. Commits here are authored as Payam Resan.

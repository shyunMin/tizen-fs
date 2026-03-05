# tizen_fs

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## AI Chat
To Enable AI Chat faeture, a config file for AI service is requried.
Currently, only Gauss is supported, and the configuration required in the following format.
This file must be placsed in the devcie at `/opt/usr/home/owner/apps_rw/org.tizen.homescreen/data/gauss_config.json`.

``` json
{
    "client_key": "",
    "pass_key": "",
    "email": "",
    "endpoint_url": ""
}
```
You can obtain access permission and keys for the service from the link below.
- [Gauss Portal](https://genai.sec.samsung.net/portal/chat)


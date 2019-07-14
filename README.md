# lenden

A new Flutter project.

## Setup

While it's not the end of the world the `GoogleService-Info.plist` is not checked in.
As a note for myself, the AppStore `plist` can be downloaded [here](https://console.firebase.google.com/u/0/project/lenden-1cf29/settings/general/ios:eu.dtrautwein.lenden).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Debugging with Redux Remote Dev Tools

Use the Javascript Remote Devtools package. Start the remotedev server on your machine

```shell
npm install -g remotedev-server
remotedev --port 8000
```

Run the application. It will connect to the remotedev server. You can now debug your redux application by opening up <http://localhost:8000> in a web browser.

## Generating JSON serializations

To make use of the JSON annotations (decorators) run the following command:

```shell
flutter pub run build_runner build
```

## Running Tests

### Firestore rules

The first step is to download the firestore emulator:

```shell
yarn run setup:firestore
```

In order to run the tests the emulator needs to run:

```shell
yarn run serve:firestore
```

Now the tests can be run with:

```shell
yarn run test:rules
```

## Deployment

- Everything

  ```shell
  yarn run deploy:all
  ```

- Firestore rules

  ```shell
  yarn run deploy:rules
  ```

- Cloud functions

  ```shell
  yarn run deploy:functions
  ```

## Testflight

From inside the `ios` subdirectory run

```sh
bundle # only necessary once
bundle exec fastlane ios beta
```

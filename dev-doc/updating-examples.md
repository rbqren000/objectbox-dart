# Updating Flutter examples

First, make sure to update your Flutter SDK to the latest version:

```bash
# Make sure to close IDEs or tools using the Flutter or Dart SDK first. Then:
flutter upgrade
flutter doctor
```

Make sure CI config files are also updated to use this or a later Flutter SDK.

Then, for an example in its directory delete the platform-specific directories (such as `android`,
`linux`, ...) and the

- `.gitignore`
- `analysis_options.yaml`
- `pubspec.yaml`

files.

Then, use `flutter create` to create empty example files. For example:

```bash
cd objectbox/example/flutter/objectbox_demo_relations/

rm -rf android/
rm -rf ios/
rm -rf linux/
rm -rf macos/
rm -rf windows/
rm .gitignore
rm analysis_options.yaml
rm pubspec.yaml

flutter create --project-name=objectbox_demo_relations --platforms=android,ios,linux,macos,windows .
```

Note: set `--project-name` in case the parent directory is not a valid Dart package name (like for
Sync example).

Then, remove the created default widget test file.

```bash
rm test/widget_test.dart
```

Review the changes, restore any required changes (like in Podfile, build scripts, project files, the
files mentioned above...). Use `flutter pub upgrade` to re-create generated files, and on each 
platform (with the same Flutter SDK version!) `flutter run` to update build and project files
(for example, running on macOS and iOS adds CocoaPods configuration).

Then, commit only what's necessary. See the previous commits that update the examples for reference.

Then, adjust (or repeat for) the other examples accordingly.

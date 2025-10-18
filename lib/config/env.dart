abstract class Env {
  static String appName = "";
  static String baseUrl = "";
  static bool useFirebase = false;
  static void setEnvironment(EnvironmentType env) {
    switch (env) {
      case EnvironmentType.dev:
        appName = "MyApp Dev";
        baseUrl = "https://dev-api.example.com";
        useFirebase = true;
        break;
      case EnvironmentType.stage:
        appName = "MyApp Staging";
        baseUrl = "https://stage-api.example.com";
        useFirebase = true;
        break;
      case EnvironmentType.prod:
        appName = "MyApp";
        baseUrl = "https://api.example.com";
        useFirebase = true;
        break;
    }
  }
}
enum EnvironmentType { dev, stage, prod }



/*
for the release build
flutter run --release --flavor dev -t lib/main_dev.dart --dart-define=FLAVOR=dev

flutter run --flavor dev -t lib/main_dev.dart --dart-define=FLAVOR=dev
flutter run --flavor prod -t lib/main_prod.dart --dart-define=FLAVOR=prod
flutter run --flavor stage -t lib/main_stage.dart --dart-define=FLAVOR=stage
*/

/*
for ios 
flutter run --flavor dev -t lib/main_dev.dart  
flutter run --flavor stage -t lib/main_stage.dart
flutter run --flavor prod -t lib/main_prod.dart  

for building release version
flutter build ios --release --flavor prod -t lib/main_prod.dart

android 
flutter build appbundle --flavor prod -t lib/main_prod.dart
*/

/*
eski ayar güzelhosting ilk 2
ns43.guzelhosting.com
*/
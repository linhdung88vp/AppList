import 'dart:typed_data';

class AppInfo {
  final String name;
  final String packageName;
  final String versionName;
  final String versionCode;
  final int? installTime;
  final int? updateTime;
  final Uint8List? icon;
  final bool isSystemApp;
  final String? apkFilePath;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    this.installTime,
    this.updateTime,
    this.icon,
    this.isSystemApp = false,
    this.apkFilePath,
  });

  @override
  String toString() {
    return 'AppInfo(name: $name, packageName: $packageName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInfo && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;
}

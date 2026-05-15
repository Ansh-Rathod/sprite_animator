import 'package:path_provider/path_provider.dart';

class Cache {
  static String? tempPath;

  static Future init() async {
    tempPath = (await getApplicationCacheDirectory()).path;
  }
}

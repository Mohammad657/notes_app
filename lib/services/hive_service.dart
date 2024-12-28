import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  Future<Box> openBox(String boxName) async {
    await Hive.initFlutter();
    return await Hive.openBox(boxName);
  }
}
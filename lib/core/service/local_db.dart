import 'package:hive_flutter/hive_flutter.dart';

class LocalHiveDatabase {
  late final Box? box;
  Future<void> init(String boxName) async {
    box = await Hive.openBox(boxName);
  }

  Future<void> closeBox() async {
    await box?.close();
  }

  Future<void> put(String key, dynamic boxName) async {
    await box?.put(key, boxName);
  }

  Future<dynamic> get(String key) async {
    return box?.get(key);
  }

  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }

  Future<void> deleteAllBoxes() async {
    await Hive.deleteFromDisk();
  }
}

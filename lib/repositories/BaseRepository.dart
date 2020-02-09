
import 'package:hive/hive.dart';

abstract class BaseRepository<T> {

  Box<T> _box;

  BaseRepository() {}

  Future<Null> initHive() async {
    Hive.registerAdapter(adapter());
    await Hive.openBox<T>(
        boxName(),
        compactionStrategy: (int total, int deleted) => deleted > 5
    );
  }

  String boxName();
  TypeAdapter<T> adapter();

  Box<T> get box {
    if(_box == null) _box = Hive.box<T>(boxName());
    return _box;
  }

  void close() {
    this._box.compact().whenComplete(() => this._box.close());
  }
}

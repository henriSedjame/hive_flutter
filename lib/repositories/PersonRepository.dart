
import 'package:hive/hive.dart';
import 'package:hive_no_sql_db/models/Person.dart';
import 'package:hive_no_sql_db/repositories/BaseRepository.dart';

class PersonRepository extends BaseRepository<Person> {


  @override
  String boxName() {
    return 'Persons';
  }

  @override
  TypeAdapter<Person> adapter() {
    return PersonAdapter();
  }

  Future<void> save(Person person) async {
   await this.box.add(person);
  }

  Future<void> update(Person person, int index) async {
    this.box.putAt(index, person);
  }

  Future<void> delete(int index) async {
    await this.box.deleteAt(index);
  }
}

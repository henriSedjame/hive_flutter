
import 'package:hive/hive.dart';

part 'Person.g.dart';

@HiveType(typeId: 0, adapterName: 'PersonAdapter')
class Person {

  @HiveField(0)
  String nom;
  @HiveField(1)
  int age;

  Person(this.nom, this.age);
}

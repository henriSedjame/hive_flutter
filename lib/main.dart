import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_no_sql_db/models/Person.dart';
import 'package:hive_no_sql_db/repositories/PersonRepository.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await path.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  var personRepository = PersonRepository();

  await personRepository.initHive();

  await personRepository.save(Person('Henri', 33));
  await personRepository.save(Person('Chloe', 29));
  await personRepository.save(Person('Audrey', 36));

  runApp(MultiProvider(
    providers: [Provider.value(value: personRepository)],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController nCtrl = new TextEditingController();
  TextEditingController aCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var repository = Provider.of<PersonRepository>(context);

    ValueListenable<Box<Person>> listenable = repository.box.listenable();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              onPressed: () => show(repository),
              icon: Icon(Icons.person_add),
            )
          ],
        ),
        body:  ValueListenableBuilder(
            valueListenable: listenable,
            builder: (ctx, Box<Person> box, widget) {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: box.length,
                  itemBuilder: (context, i) {
                    Person person = box.getAt(i);
                    return ListTile(
                      title: Text('${person.nom} (${person.age} ans)'),
                      leading: IconButton(
                        onPressed: () async {
                          await repository.delete(i);
                        },
                        icon: Icon(Icons.delete),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          nCtrl.text = person.nom;
                          aCtrl.text = person.age.toString();
                          show(repository, index: i);
                        },
                        icon: Icon(Icons.edit),
                      ),
                    );
                  });
            }),);
  }

  Future<void> show(PersonRepository repository, {int index}) {
    return showDialog(context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          child: Center(
            child: Column(
                children: <Widget>[
                  TextField(
                    controller: nCtrl,
                    decoration: InputDecoration(
                        hintText: 'Entrez le nom'
                    ),

                  ),
                  TextField(
                    controller: aCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Entrez l\'age'
                    ),

                  ),
                  SizedBox(height: 20.0,),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        child: Text('ADD'),
                        color: Colors.blue,
                        disabledColor: Colors.grey,
                        onPressed: () {
                          var person = Person(nCtrl.text, int.parse(aCtrl.text));
                          if(index != null) {
                            repository.update(person, index);
                          } else {
                            repository.save(person);
                          }

                          nCtrl.clear();
                          aCtrl.clear();
                          Navigator.of(ctx).pop();
                        },
                      )
                    ],
                  )
                ]
            ),
          ),

        );
      }
    );
    }

}

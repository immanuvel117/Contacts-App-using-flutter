// Here where the main code scenerio works

import 'package:flutter/material.dart';

import ' util/database_helper.dart';
import 'models/contact.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Contact List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: unused_field
  late DatabaseHelper _dbHelper;
  int _id = 0;

  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();
  // ignore: prefer_final_fields
  Contact _contact = Contact(
    id: 0,
    mobile: '',
    name: '',
  );
  // ignore: prefer_final_fields
  List<Contact> _contacts = [];

  int get id => _id;
  set id(int userId) {
    _id = userId;
  }

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    print("inside init state");
    _refreshContactList();
  }

  _refreshContactList() async {
    print("inside refresh contact list");
    List<Contact> x = await _dbHelper.fetchContacts();
    setState(() {
      _contacts = x;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }


// form method to display the form page and sending the data

  _form() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Visibility(
                visible: false,
                child: TextFormField(
                  initialValue: "LastNamePlaceholder",
                  onSaved: (val) => setState(() => _contact.id = id),
                ),
              ),
              TextFormField(
                controller: _ctrlName,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) =>
                    // ignore: prefer_is_empty
                    (val!.length == 0 ? 'This field is mandatory' : null),
                onSaved: (val) => setState(
                  () => _contact.name = val!,
                ),
              ),
              TextFormField(
                controller: _ctrlMobile,
                decoration: const InputDecoration(labelText: 'Mobile'),
                validator: (val) =>
                    val!.length < 10 ? '10 characters required' : null,
                onSaved: (val) => setState(() => _contact.mobile = val!),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                // ignore: deprecated_member_use
                child: RaisedButton(
                  onPressed: () => _onSubmit(),
                  child: const Text('Submit'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
  // ignore: unused_element
  _showForEdit(index) {
    setState(() {
      _contact = _contacts[index];
      print('ID :$id');

      _ctrlName.text = _contacts[index].name;

      _ctrlMobile.text = _contacts[index].mobile;
    });
  }

// OnSubmit method to store our contacts

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();

      // ignore: avoid_print
      print('''
    Full Name : ${_contact.name}
    Mobile : ${_contact.mobile}
    Id:${_contact.id}
    ''');
      _contacts.add(Contact(
          id: _contact.id, name: _contact.name, mobile: _contact.mobile));
      print(_contact.id);
      int status = 0;
      if (_contact.id < 1) {
        print("inside insert");
        status = await _dbHelper.insertContact(_contact);
      } else {
        print("inside update");
        status = await _dbHelper.updateContact(_contact, _contact.id);
      }
//   // ignore: curly_braces_in_flow_control_structures
      if (status == 200) {
        await _refreshContactList();
        form.reset();
      }
    }

    // ignore: unnecessary_null_comparison
//
    _resetForm();
  }

  _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = 0;
    });
  }


// List method to display the stored ones

  _list() => Expanded(
        child: Card(
          margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(
                        Icons.account_circle,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                      title: Text(
                        _contacts[index].name.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_contacts[index].mobile),
                      onTap: () {
                        print(_contacts[index].id);
                        id = _contacts[index].id;
                        _showForEdit(index);
                      },
                      trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep,
                              color: Colors.blue),
                          onPressed: () async {
                            await _dbHelper.deleteContact(_contacts[index].id);
                            _resetForm();
                            _refreshContactList();
                          }),
                    ),
                    const Divider(
                      height: 5.0,
                    ),
                  ],
                );
              },
              itemCount: _contacts.length,
            ),
          ),
        ),
      );
}

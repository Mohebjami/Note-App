import 'package:connect_to_sqflite/sql_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Container(
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  void _refreshJournals() async{
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
    print("..number of items ${_journals.length}");
  }

    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();

    Future<void> _addItem() async{
      await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
        _refreshJournals();

    }

    Future<void> _updateItem(int id) async {
      await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
      _refreshJournals();
    }

    void _deleteItem(int id) async{
      await SQLHelper.deleteItem(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted a journal')));
      _refreshJournals();
    }

  void _showForm(int? id) async{
    if(id != null){
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }


    showModalBottomSheet(context: context,
      elevation: 5 ,
      isScrollControlled: true,
      builder: (_)=> Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,

          bottom: MediaQuery.of(context).viewInsets.bottom+120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            ElevatedButton(onPressed: ()async{
              if(id == null){
                await _addItem();
              }
              if(id != null){
                await _updateItem(id);
              }
              _titleController.text = '';
              _descriptionController.text = '';
              Navigator.of(context).pop();
            }, child: Text(id == null ? 'Create New' : 'Update')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context , index)=> Card(
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_journals[index]['title']),
              subtitle: Text(_journals[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(onPressed: ()=> _showForm(_journals[index]['id']), icon: const Icon(Icons.edit)),
                    IconButton(onPressed: ()=> _deleteItem(_journals[index]['id']) , icon: const Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: ()=>_showForm(null),
      ),
    );
  }
}

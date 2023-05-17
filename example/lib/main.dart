import 'package:flutter/material.dart';

import 'ui/todo_list_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Todo';
    return Material(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodoListPage(title: title),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project.dart';

void main() {
  runApp(CicdApp());
}

Future<Project> _fetchProject() async {
  final response = await http.get('http://127.0.0.1:9000/api/v1/json');

  if (response.statusCode == 200) {
    return Project.fromJson(json.decode(response.body));
  } else {
    print('Failed to load project data');
    throw Exception('Failed to load project data');
  }
}

class CicdApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CICD Dashboard [Project X]',
      theme: ThemeData(
        primaryColor: Colors.grey[850],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'CICD Dashboard [Project X]'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Project> project;
  List<TableRow> tablerow = [];
  List<TableCell> tablecell = [];
  int count = 0;

  @override
  void initState() {
    super.initState();
    project = _fetchProject();
  }

  // routine to build buttons from json (cicd)
  List<RaisedButton> buildButtons(Payload p) {
    List<RaisedButton> buttons = [];
    p.stages.forEach((v) {
      buttons.add(
        RaisedButton(
          color: Colors.grey[600],
          child: Text(
            v.name,
            style: TextStyle(fontSize: 12),
          ),
          onPressed: () {},
        ),
      );
    });
    return buttons;
  }

  // convenience function to build a table row
  TableRow buildRow(List<TableCell> tc) {
    return TableRow(
      children: tc,
    );
  }

  // convenience function to build a table cell
  TableCell buildCell(SizedBox c) {
    return TableCell(
      child: c,
    );
  }

  // convenience function to build an empty table cell
  // table rows in flutter can't have holes
  TableCell buildEmptyCell() {
    return TableCell(
      child: SizedBox(
        height: 230.0,
        width: 530.0,
        child: Card(
          color: Colors.white,
          borderOnForeground: false,
          elevation: 5.0,
          margin: EdgeInsets.all(10.0),
          child: Text(''),
        ),
      ),
    );
  }

  // build the card from the cicd json data
  SizedBox buildProjectCard(Payload p, List<RaisedButton> buttons) {
    return SizedBox(
      height: 230.0,
      width: 530.0,
      child: Card(
      color: Colors.white,
      borderOnForeground: false,
      elevation: 5.0,
      margin: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.label_important),
            title: Text(p.project),
            subtitle: Text(
              p.scm,
              style: TextStyle(fontSize: 12),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: buttons,
          ),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                color: Colors.grey[850],
                child: const Text(
                  'TRIGGER',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {/* ... */},
              ),
              RaisedButton(
                color: Colors.grey[850],
                child: const Text(
                  'CANCEL',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<Project>(
          future: project,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              snapshot.data.payload.forEach((p) {
                count++;
                List<RaisedButton> buttons = buildButtons(p);
                // build 3 columns
                if ((count % 3) == 0) {
                  tablecell.add(buildCell(buildProjectCard(p,buttons)));
                  tablerow.add(buildRow(tablecell));
                  tablecell = [];
                } else {
                  tablecell.add(buildCell(buildProjectCard(p,buttons)));
                }
              });
            
              // add whats left over
              if ((count % 3) == 1) { 
                tablecell.add(buildEmptyCell());
                tablecell.add(buildEmptyCell());
                tablerow.add(buildRow(tablecell));
              }
              if ((count % 2) == 2) { 
                tablecell.add(buildEmptyCell());
                tablerow.add(buildRow(tablecell));
              }
              // return our completed table 
              return Table(
                border: TableBorder.all(
                  color: Colors.white, width: 1, style: BorderStyle.none
                ),
                children: tablerow,
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

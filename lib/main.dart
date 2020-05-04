import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

// websocket class
class WebSocket {
  
  final _streamController = StreamController.broadcast();
  static WebSocket _instance;
  WebSocketChannel channel;

  static WebSocket get instance {
    if (_instance == null) {
      _instance = WebSocket();
    }
    return _instance;
  }


  Stream get channelStream => _streamController.stream;
  //Stream get channel => channel.stream;

  void add(String val) {
    channel.sink.add(val);
  }

  Future init(int retries) async {
    if (channel == null) {
      channel = WebSocketChannel.connect(Uri.parse("ws://127.0.0.1:8080/api/v1/websocket/streamdata"));
      _streamController.sink.add(null);
      channel.stream.listen((value) {
        _streamController.sink.add(value);
      });
    }
  }

  void close() => _streamController.close();
}

class CicdApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CICD Dashboard [ Project golang microservice utils ]',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
        title: 'CICD Dashboard [ Project golang microservice utils ]',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Project> project;
  List<TableRow> tablerow = [];
  List<TableCell> tablecell = [];
  Map<String, Color> cm = new Map<String, Color>();
  int count = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    project = _fetchProject();
    WebSocket.instance.init(3);
    resetColors('all');
    // all good we set our timer interval
    Timer.periodic(new Duration(seconds: 300), (timer) {
      var now = new DateTime.now();
      debugPrint('[INFO] ${now}'); 
      WebSocket.instance.add('poll');
    });
  }

  void resetColors(String id) {
    //TODO: fix this - try get a dynamic length
    if (id == 'all') {
      for (int x = 0; x < 10; x++) {
        for (int y = 1; y < 8; y++) {
          cm["100" + x.toString() + "-" + y.toString()] = Colors.grey[600];
        }
      } 
    } else {
      print('reset ${id}');
      for (int y = 1; y < 8; y++) {
        cm[id + y.toString()] = Colors.grey[600];
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      count = 0;
      tablerow = [];
      tablecell = [];
      _selectedIndex = index;
    });
  }

  void updateColor(String data) {
    var tmp = data.split(":");
    if (tmp[1] == "clear") {
      resetColors(tmp[0]);
    }
    switch (tmp[1]) {
      case "error":
        cm[tmp[0]] = Colors.red;
        break;
      case "success":
        cm[tmp[0]] = Colors.green;
        break;
      case "skipping":
        cm[tmp[0]] = Colors.lightBlue[600];
        break;
      case "pending":
        cm[tmp[0]] = Colors.amber[900];
        break;
    }
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

  // build stage button bar
  ButtonBar buildButtonBar(Payload p) {
    List<RaisedButton> buttons = [];
    p.stages.forEach((v) {
      buttons.add(RaisedButton(
        color: cm[p.id+'-'+v.name],
        child: Text(
          v.name,
          style: TextStyle(fontSize: 12),
        ),
        onPressed: () {},
      ),);
    });  
    return ButtonBar(
      alignment: MainAxisAlignment.start,
      children: buttons,
    );
  }

  // build the card from the cicd json data
  SizedBox buildProjectCard(Payload p) {
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
            StreamBuilder(
              stream: WebSocket.instance.channelStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print('snapshot data ${snapshot.data}');
                  updateColor(snapshot.data);
                }
                // it would be cool to have a convenience function to build the buttons
                // however streambuilder is a bit fussy :(
                // so for now we do it manually
                return ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: <Widget> [
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[0].id.toString()],
                      child: Text(
                        p.stages[0].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[1].id.toString()],
                      child: Text(
                        p.stages[1].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[2].id.toString()],
                      child: Text(
                        p.stages[2].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[3].id.toString()],
                      child: Text(
                        p.stages[3].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[4].id.toString()],
                      child: Text(
                        p.stages[4].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[5].id.toString()],
                      child: Text(
                        p.stages[5].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      color: cm[p.id+'-'+p.stages[6].id.toString()],
                      child: Text(
                        p.stages[6].name,
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                  ],
                );
              }
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  color: Colors.grey[900],
                  child: const Text(
                    'TRIGGER',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      count = 0;
                      tablerow = [];
                      tablecell = [];
                      WebSocket.instance.add(p.id + '-force');
                    });
                  },
                ),
                RaisedButton(
                  color: Colors.grey[900],
                  child: const Text(
                    'TEST',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    WebSocket.instance.add(p.id + '-test');
                  },
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
        child: Column(
          children: <Widget>[
            FutureBuilder<Project>(
              future: project,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  snapshot.data.payload.forEach((p) {
                    count++;
                    //List<RaisedButton> buttons = buildButtons(p);
                    // build 3 columns
                    if ((count % 3) == 0) {
                      tablecell.add(buildCell(buildProjectCard(p)));
                      tablerow.add(buildRow(tablecell));
                      tablecell = [];
                    } else {
                      tablecell.add(buildCell(buildProjectCard(p)));
                    }
                  });

                  // add whats left over
                  if ((count % 3) == 1) {
                    tablecell.add(buildEmptyCell());
                    tablecell.add(buildEmptyCell());
                    tablerow.add(buildRow(tablecell));
                  }
                  if ((count % 2) == 2 || count < 3) {
                    tablecell.add(buildEmptyCell());
                    tablerow.add(buildRow(tablecell));
                  }
                  // return our completed table
                  return Table(
                    border: TableBorder.all(
                        color: Colors.white, width: 1, style: BorderStyle.none),
                    children: tablerow,
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            title: Text('Info'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Contact'),
          ),
        ],
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    WebSocket.instance.close();
    super.dispose();
  }
}

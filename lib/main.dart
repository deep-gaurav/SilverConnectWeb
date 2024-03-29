import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js';

import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/material.dart';

import 'phoneInfo.dart';
import 'filePlugin.dart';

StreamController<Map> messageStream = StreamController.broadcast();
StreamController rawmessageStream = StreamController.broadcast();
StreamController sendStream = StreamController.broadcast();

Future main() async {
  if (!html.window.localStorage.containsKey("connections")) {
    html.window.localStorage["connections"] = json.encode([]);
  }
  messageStream.stream.listen((data){
    if((data as Map).containsKey("notify")){
      new html.Notification(data["notificationtitle"]);
    }
  });

  rawmessageStream.stream.listen((data){
    print(data);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Silver Connect'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key) {
    html.Notification.requestPermission().then((val) {
      print(val);
    });
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var logmessage = ValueNotifier("");

  html.WebSocket websocket;

  var _editingcontroller = TextEditingController();
  var _nameEditingcontroller = TextEditingController();

  List plugins = [
    PhoneInfoPlugin(),
    ReceiverPlugin()
  ];


  Timer timer;

  Completer testcompleter;

  void tryoldconnect() {
    print("TRY OLDS");
    var oldm = json.decode(html.window.localStorage["connections"]);
    for (var connections in oldm) {
      for (var urls in connections["urls"]) {
        if (websocket != null && websocket.readyState == 3) {
          connect(urls);
        } else if (websocket == null) {
          connect(urls);
        }
      }
    }
  }

  void connect(String ip, {port = 9000}) async{
    if(testcompleter!=null && !testcompleter.isCompleted){
      return;
    }else{
      testcompleter=Completer();
    }
    context["Fingerprint2"].callMethod("get", [
      (components) {
        List<String> values = List();

        for (var x in components) {
          values.add(x["value"].toString());
        }

        var murmur = context["Fingerprint2"]
            .callMethod("x64hash128", [values.join(" "), 31]);
        print(murmur);
        websocket = new html.WebSocket("ws://$ip:$port");

        sendStream.stream.listen((data){
            websocket.send(data);
        });

        var data = {
          "name": _nameEditingcontroller.text,
          "type": "connectionRequest",
          "fingerprint": murmur
        };
        websocket.onOpen.listen((op) {
          print(op);
          websocket.send(json.encode(data));
        });
        websocket.onMessage.listen((data) {

          rawmessageStream.add(data.data);

          try{
            var message = json.decode(data.data);

            messageStream.add(message);

            if (message["type"] == "ConnectionGranted") {
              print("connection");
              var l = (html.window.localStorage["connections"]);
              Set peers = HashSet(equals: (e1, e2) => e1["id"] == e2["id"]);
              peers.addAll(json.decode(l) as List);
              if (peers.contains(message)) {
                var oldm = peers.lookup(message);
                var oldmurls = Set.from(oldm["urls"]);
                oldmurls.add(ip);
                oldm["urls"] = oldmurls.toList();
                peers.remove(oldm);
                peers.add(oldm);
              } else {
                message["urls"] = [ip];
                peers.add(message);
              }
              print(message);
              print(peers);
              var peerslist = peers.toList();
              html.window.localStorage["connections"] = json.encode(peerslist);
              setState(() {});

            }
          }catch(e){
            print(e);
          }

        });
        websocket.onClose.listen((data) {
          setState(() {
            websocket = null;
          });
        });
        testcompleter.complete();
      }
    ]);
  }

  @override
  void initState() {
    super.initState();

    logmessage.addListener(() {
      if (html.Notification.permission == "granted") {
        var notification = new html.Notification(logmessage.value);
      }
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (websocket == null) {
        tryoldconnect();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
          ),
          if (websocket == null)
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 300),
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      decoration:
                          InputDecoration(labelText: "Name to of this device"),
                      controller: _nameEditingcontroller,
                    ),
                    TextField(
                      decoration:
                          InputDecoration(labelText: "IP of Device to Connect"),
                      controller: _editingcontroller,
                      onSubmitted: (val) {
                        connect(val);
                      },
                    ),
                    RaisedButton(
                      child: Text("Connect"),
                      onPressed: () {
                        connect(_editingcontroller.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (websocket != null)
            ...plugins
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          websocket.send("Hello World");
        },
      ),
    );
  }
}

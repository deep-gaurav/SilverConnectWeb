import 'dart:async';
import 'dart:js';

import 'package:flutter_web/material.dart';
import 'dart:html' as html;

import 'main.dart';

class ReceiverPlugin extends StatelessWidget{

  html.Blob fileblob;

  List blobparts;

  var receive=false;

  ReceiverPlugin(){
    rawmessageStream.stream.listen((data){
      if(data is html.Blob){

        if(receive){
          print("add toblob");
          blobparts.add(data);
        }else{

        }
      }
    });
    messageStream.stream.listen(
        (data){
          if(data["type"]=="sendfile" && data["mark"]=="start"){
            blobparts=[];
            receive=true;
            print("startreceivingfile");
          }else if(data["type"]=="sendfile" && data["mark"]=="stop"){
            receive=false;
            fileblob=html.Blob(blobparts);
            var url = html.Url.createObjectUrlFromBlob(fileblob);
            var link = new html.AnchorElement();
            link.href = url;
            link.download = data["filepath"];
            link.click();
            print("stopreceivingfile");
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

}
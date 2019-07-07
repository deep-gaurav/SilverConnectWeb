import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/material.dart';

import 'main.dart';

class PhoneInfoPlugin extends StatelessWidget {
  var name=ValueNotifier("");
  var brand=ValueNotifier("");
  var battery=ValueNotifier(0);

  PhoneInfoPlugin(){
    messageStream.stream.listen((data){
      if(data.containsKey("battery")){
        battery.value=data["battery"];
      }
      if(data.containsKey("batterylevel")){
        battery.value=data["batterylevel"];
      }
      if(data.containsKey("name")){
        name.value=data["name"];
      }
      if(data.containsKey("brand")){
        brand.value=data["brand"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: ValueListenableBuilder(
            valueListenable: battery,
            builder: (context,batteryval,child){
             return Stack(
               children: <Widget>[
                 Positioned.fill(
                     child: CircularProgressIndicator(
                       value: battery.value / 100,
                     )),
                 Container(
                   padding: EdgeInsets.all(20),
                   child: Icon(
                     Icons.phone_android,
                     size: 100.0,
                   ),
                 ),
                 Positioned.fill(
                   child: Center(
                     child: Text(battery.value.toString()+"%"),
                   ),
                 ),
               ],
             );
            },
          )
        ),
        Column(
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: name,
              builder: (context,nameval,child){
                return Text(
                  name.value,
                  style: Theme.of(context).textTheme.title,
                );
              }
            ),
            ValueListenableBuilder(
                valueListenable: name,
                builder: (context,brandval,child){
                  return Text(
                    brand.value,
                    style: Theme.of(context).textTheme.subtitle,
                  );
                }
            ),
          ],
        )
      ],
    );
  }
}

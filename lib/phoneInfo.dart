import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/material.dart';

class info {
  String name, brand;
  int battery;

  info({this.name, this.brand, this.battery});
}

class PhoneInfo extends StatelessWidget {
  info pinfo;
  PhoneInfo(this.pinfo);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: CircularProgressIndicator(
                value: pinfo.battery / 100,
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
                  child: Text(pinfo.battery.toString()+"%"),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            Text(
              pinfo.name,
              style: Theme.of(context).textTheme.title,
            ),
            Text(
              pinfo.brand,
              style: Theme.of(context).textTheme.subtitle,
            )
          ],
        )
      ],
    );
  }
}

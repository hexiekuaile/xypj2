import 'package:flutter/material.dart';
import '../i18n.dart';

//子页面
class ChildItemView extends StatefulWidget {
  String _title;

  ChildItemView(this._title);

  @override
  _ChildItemViewState createState() => _ChildItemViewState();
}

class _ChildItemViewState extends State<ChildItemView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text(Strings.of(context).valueOf('firstPage'))),
      /*child: Center(
        child: Column(
          children: <Widget>[
            Text(Strings.of(context).valueOf('a.c.d')),
            Text(Strings.of(context).valueOf('a.c')),
            Text(Strings.of(context).valueOf('a.firstPage')),
          ],
        ),
      ),*/
    );
  }
}

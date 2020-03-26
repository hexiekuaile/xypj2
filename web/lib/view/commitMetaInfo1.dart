import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web/m.dart';
import 'package:web/i18n.dart';
import 'package:web/domain/info.dart';

//提交保存基础信息视图
class CommitMetaInfo extends StatefulWidget {
  @override
  _CommitMetaInfoState createState() => _CommitMetaInfoState();
}

class _CommitMetaInfoState extends State<CommitMetaInfo> with AutomaticKeepAliveClientMixin {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var rows = <Widget>[];
  String _title;

  @override
  void initState() {
    super.initState();
    rows.add(row_title());
    rows.add(row_add());
    rows.add(new Row_meta(UniqueKey(), removeMetaRow));
    rows.add(row_save());
    // print('基础信息视图 init');
  }

  @override
  bool get wantKeepAlive => true; //切换页面时，保持状态不刷新

  void _formSubmitted() {
    var _form = _formKey.currentState;

    if (_form.validate()) {
      _form.save(); //执行每个输入框的save方法
      _post(_handDatas()); //上传到服务器
    }
  }

  //收集处理录入的数据
  //Map<String, dynamic> _handDatas() {
  dynamic _handDatas() {
    Info info = new Info();
    info.name = _title;
    info.type = "基础信息";
    info.map = Map<String, dynamic>();

    List<Widget> lw = rows.sublist(2, rows.length - 1);
    lw.forEach((w) {
      Row_meta rm = w as Row_meta;
      //info.map['${rm._name}'] = rm._type;
      info.map[rm._name] = rm._type;
    });
    return info;
  }

//上传到服务器保存录入的基础信息
  void _post(dynamic data) async {
    String t;
    try {
      Dio dio = new Dio();
      //var response = await dio.post(M.metaInfoUrl, data: datas);
      var response = await dio.post(M.metaInfoUrl, data: data);
      if (response.statusCode == HttpStatus.created)
        t = '保存成功！ ';
      else
        t = '保存失败！';
    } catch (exception) {
      t = exception.toString();
    }
    _showSnackBar(t);
  }

  //显式上传结果对话框
  void _showSnackBar(String title) {
    final snackBar = new SnackBar(
      content: new Text(title),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 5),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

//清除组件方法，被删除按钮回调
  void removeMetaRow(Widget w) {
    //rows.removeAt(rows.indexOf(w));
    rows.remove(w);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      //可以上下滚动视图
      padding: const EdgeInsets.all(16.0),
      child: new Form(
        key: _formKey,
        child: new Column(
          children: rows,
        ),
      ),
    );
  }

  //标题行
  Widget row_title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: new Text(
          '录入',
          textAlign: TextAlign.right,
          style: new TextStyle(
            fontSize: 20.0,
            //字体大小
            fontWeight: FontWeight.bold,
            //字体粗细  粗体和正常
            color: Colors.blue, //文字颜色
          ),
        )),
        Expanded(
          child: new TextFormField(
            initialValue: _title,
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontSize: 20.0,
              //字体大小
              fontWeight: FontWeight.bold,
              //字体粗细  粗体和正常
              color: Colors.blue, //文字颜色
            ),
            validator: (val) {
              if (val.trim().isEmpty)
                return '不能为空';
              else
                return null;
            },
            onSaved: (val) {
              _title = val;
            },
          ),
        ),
        Expanded(
            child: new Text(
          '的基础信息',
          style: new TextStyle(
            fontSize: 20.0,
            //字体大小
            fontWeight: FontWeight.bold,
            //字体粗细  粗体和正常
            color: Colors.blue, //文字颜色
          ),
        )),
      ],
    );
  }

  //增加按钮
  Widget row_add() {
    return Align(
      alignment: Alignment.bottomRight,
      heightFactor: 2,
      child: new RaisedButton.icon(
        icon: Icon(Icons.add, size: 25.0),
        label: Text("增加"),
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: () {
          setState(() {
            rows.insert(rows.length - 1, Row_meta(UniqueKey(), removeMetaRow));
          });
        },
      ),
    );
  }

//保存按钮
  Widget row_save() {
    return Center(
      heightFactor: 2,
      child: RaisedButton.icon(
        icon: Icon(Icons.save, size: 25.0),
        //padding: EdgeInsets.all(15.0),
        label: Text("保存"),
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: this._formSubmitted,
      ),
    );
  }
}

//基础信息行类
class Row_meta extends StatefulWidget {
  String _name;
  String _type = '字符串';
  Function callback;

  Row_meta(Key key, @required this.callback) : super(key: key);

  @override
  _RowMetaState createState() => _RowMetaState();
}

class _RowMetaState extends State<Row_meta> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
          child: new TextFormField(
        textAlign: TextAlign.center,
        decoration: new InputDecoration(icon: Icon(Icons.text_fields), labelText: '名称'),
        validator: (val) {
          if (val.trim().isEmpty)
            return '不能为空';
          else
            return null;
        },
        onSaved: (val) {
          widget._name = val;
        },
        onChanged: (val) {
          widget._name = val;
        },
      )),
      Expanded(
          child: new DropdownButtonFormField(
        decoration: new InputDecoration(icon: Icon(Icons.menu), labelText: '数据类型'),
        value: widget._type,
        style: TextStyle(color: Colors.blue),
        //icon: Icon(Icons.sort),
        items: <String>[
          '字符串',
          '数字'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            widget._type = val;
          });
        },
      )),
      new RaisedButton.icon(
        icon: Icon(Icons.remove, size: 25.0),
        label: Text("删除"),
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: () {
          widget.callback(this.widget);
        },
      )
    ]);
  }
}

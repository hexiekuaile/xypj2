import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web/domain/entity.dart';
import 'package:web/i18n.dart';
//import 'package:web/m.dart';

//录入、提交信息视图
class CommitInfo extends StatefulWidget {
  @override
  _CommitInfoState createState() => _CommitInfoState();
}

class _CommitInfoState extends State<CommitInfo> with AutomaticKeepAliveClientMixin {
  //GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  // List<Info> _menusMetaInfo;
  //List<Info> _bodyTableInfo;
  Entity _selectedMetaInfo;
  Dio _dio;
  Widget _drawer;
  Widget _body;
  List<Entity> _rowsInfo; //bodyTable的行数据

  @override
  bool get wantKeepAlive => true; //切换页面时，保持状态不刷新

  @override
  void initState() {
    super.initState();
    _dio = new Dio();
    _drawer = Drawer(child: Center(child: Text('')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbar, drawer: _drawer, body: _body);
    //return Scaffold(appBar: _appbar, drawer: _drawer ?? CircularProgressIndicator(), body: _body);
  }

  get _appbar => AppBar(
        title: Text(Strings.of(context).valueOf("commitInfo.commit") +
            (_selectedMetaInfo == null
                ? Strings.of(context).valueOf("commitInfo.info")
                : _selectedMetaInfo.map['name'])),
        leading: Builder(
          builder: (context) => IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () {
              _drawer = _startBuildMenus();
              setState(() {});
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: <Widget>[
          MyButton(
              iconData: Icons.add,
              label: Strings.of(context).valueOf("commitInfo.label_insertButton"),
              onPressed: () {
                if (_body != null) {
                  setState(() {
                    Entity e = new Entity();
                    e.map = new Map<String, dynamic>();
                    e.map['type'] = _selectedMetaInfo.map['name'];
                    _rowsInfo.add(e);
                    _body = _buildBodyTable(_selectedMetaInfo, _rowsInfo);
                  });
                }
              }),
          MyButton(
              iconData: Icons.save,
              label: Strings.of(context).valueOf("commitInfo.label_saveButton"),
              onPressed: () {
                if (_body != null) {}
              }),
          MyButton(
              iconData: Icons.remove,
              label: Strings.of(context).valueOf("commitInfo.label_removeButton"),
              onPressed: () {
                if (_body != null) {}
              }),
        ],
      );

  //开始构建drawer菜单，
  FutureBuilder<List<Entity>> _startBuildMenus() {
    return FutureBuilder<List<Entity>>(
      future: _fetchMenusInfo(),
      builder: (BuildContext context, AsyncSnapshot<List<Entity>> snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(child: Center(child: CircularProgressIndicator()));
            Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            /* if (snapshot.hasError) {
              print(snapshot.error);
              _showSnackBar(snapshot.error.toString());
              return null;
            }*/
            return _buildMenus(snapshot.data);
          }
        } catch (ex) {
          _showSnackBar(ex.toString());
        }
        return null; // unreachable
      },
    );
  }

  //从数据库中提取菜单对应的基础信息info
  Future<List<Entity>> _fetchMenusInfo() async {
    List<Entity> _menusInfo;
    try {
      // var response = await _dio.get(M.URL_FindMetaInfoByType + '基础信息');
      //print(Strings.of(context).valueOf("commitInfo.URL_findMenusInfo"));
      var response = await _dio.get(Strings.of(context).valueOf("commitInfo.URL_findMenusInfo"));

      // print('${response.statusCode} : ${response.statusMessage} }' );
      if (response.statusCode == HttpStatus.ok)
        _menusInfo = (response.data as List<dynamic>).map<Entity>((m) {
          return Entity.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      _showSnackBar(ex.toString());
    }
    return _menusInfo ?? <Entity>[];
  }

  Widget _buildMenus(List<Entity> menusInfo) {
    List<ListTile> listTiles;
    listTiles = menusInfo.map<ListTile>((m) {
      return ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text(m.map['name'] ?? 'null'),
          //点击drawer菜单，立即从数据库中提取相对应的信息，显示在body表中//
          onTap: () {
            //name不能为null，因为下一步就是根据name从服务器提取bodyTable数据
            if (m.map['name'] != null)
              setState(() {
                _selectedMetaInfo = m;
                _body = _startBuildBodyTable(m);
              });
          });
    }).toList();

    return Drawer(
      child: ListView(
        children: listTiles,
      ),
    );
  }

  /*
    onnectionState.none	当前没有连接到任何的异步任务
    ConnectionState.waiting	连接到异步任务并等待进行交互
    ConnectionState.active	连接到异步任务并开始交互
    ConnectionState.done	异步任务中止
    */
  FutureBuilder<List<Entity>> _startBuildBodyTable(Entity selectedMetaInfo) {
    return FutureBuilder<List<Entity>>(
      future: _fetchRowsInfo(selectedMetaInfo),
      builder: (BuildContext context, AsyncSnapshot<List<Entity>> snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            /*   if (snapshot.hasError) {
              _showSnackBar(snapshot.error.toString());
              return null;
            }*/
            _rowsInfo = snapshot.data;
            return _buildBodyTable(selectedMetaInfo, snapshot.data);
          }
        } catch (ex) {
          _showSnackBar(snapshot.error.toString());
        }
        return null; // unreachable
      },
    );
  }

  //通过选定的基础信息名称，从数据库中提取基础信息的一般信息，填充到body中的表。
  //例如，通过 评价指标 这个名称，获取所有的评价指标
  Future<List<Entity>> _fetchRowsInfo(Entity seletedMetaInfo) async {
    List<Entity> _bodyTableInfo;
    try {
      var response =
          await _dio.get(Strings.of(context).valueOf("commitInfo.URL_findInfoByType") + seletedMetaInfo.map['name']);
      if (response.statusCode == HttpStatus.ok)
        _bodyTableInfo = (response.data as List<dynamic>).map<Entity>((m) {
          return Entity.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      _showSnackBar(ex);
    }

    return _bodyTableInfo ?? <Entity>[];
  }

  Widget _buildBodyTable(Entity selectedMetaInfo, List<Entity> rowsInfo) {
    List<String> _colNames = selectedMetaInfo.map.keys.toList();
    /*List<String> _colNames = <String>[];
    if (rowsInfo.length > 0) _colNames = rowsInfo[0].map.keys.toList();*/
    _colNames.remove("name");
    _colNames.remove("type");
    int _defalutRowPageCount = 10; //默认一页行数
    //分页表
    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Text(Strings.of(context).valueOf("commitInfo.headerText")),
      rowsPerPage: _defalutRowPageCount,
      onRowsPerPageChanged: (value) {
        setState(() {
          _defalutRowPageCount = value;
        });
      },
      initialFirstRowIndex: 0,
      availableRowsPerPage: [10, 20],
      onPageChanged: (value) {
        // print('翻页： $value');
      },
      columns: _getCols(_colNames),
      source: BodyTableSource(
          _colNames,
          rowsInfo,
          _dio,
          Strings.of(context).valueOf("commitInfo.URL_saveRow"),
          _showSnackBar,
          Strings.of(context).valueOf("commitInfo.tip_saveSuccess"),
          Strings.of(context).valueOf("commitInfo.tip_saveFail")),
    ));
  }

  List<DataColumn> _getCols(List<String> colNames) {
    return colNames.map<DataColumn>((txt) {
      return DataColumn(label: Text(txt));
    }).toList();
  }

  //在底部显示消息提示栏
  void _showSnackBar(String title) {
    final snackBar = new SnackBar(
      content: new Text(title),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 5),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class BodyTableSource extends DataTableSource {
  List<String> _colNames;
  List<Entity> _rowsInfo;
  String _URL_saveRow;
  Function _showSnackBarCallback;
  String _tip_saveSuccess; //提示保存成功
  String _tip_saveFail; //提示保存失败

  Entity _editingInfo; //正在编辑中的
  int _editingIndex = -1;
  Dio _dio;
  BodyTableSource(this._colNames, this._rowsInfo, this._dio, this._URL_saveRow, this._showSnackBarCallback,
      this._tip_saveSuccess, this._tip_saveFail);

  @override //根据索引获取内容行
  DataRow getRow(int index) {
    if (index < _rowsInfo.length) {
      final Entity row = _rowsInfo[index];
      return DataRow.byIndex(
          index: index,
          cells: _getCells(index, row),
          selected: false,
          onSelectChanged: (val) {
            print("------- ${val}");
          });
    }
  }

  //一行所有单元格
  List<DataCell> _getCells(int index, Entity rowInfo) {
    return _colNames.map<DataCell>((colName) {
      return DataCell(
          TextFormField(
            key: UniqueKey(),
            initialValue: rowInfo.map[colName],
            style: new TextStyle(
              fontSize: 13.0,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (val) {
              //录入框值改变，将变化写入editing
              if (_editingInfo == null || _editingInfo.id != rowInfo.id) {
                //_editingInfo = Info.fromJson(rowInfo.toJson());
                _editingInfo = new Entity();
                _editingInfo.id = rowInfo.id;
                _editingInfo.map = new Map<String, dynamic>();
                if (rowInfo.id == null) _editingInfo.map['type'] = rowInfo.map['type'];
                _editingIndex = index;
              }
              _editingInfo.map[colName] = val;
              rowInfo.map[colName] = val;
            },
            onTap: () {
              //鼠标点击进入录入框，准备提交保存改变
              if (_editingIndex < 0 || _editingIndex == index) return;
              _startSave();
            },
            onEditingComplete: () {
              //print("onEditingComplete");
            },
            onFieldSubmitted: (val) {
              //print("OnFieldSubmitted");
            },
          ),
          showEditIcon: true, onTap: () {
        //鼠标点击单元格(没有进入录入框)，准备提交保存改变
        if (_editingIndex < 0 || _editingIndex == index) return;
        _startSave();
      });
    }).toList();
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _rowsInfo.length;

  @override //选中的行数
  int get selectedRowCount => 0;

  void _startSave() {
    Entity tmp = _rowsInfo[_editingIndex];
    _save(_editingInfo);
    _editingIndex = -1;
    _editingInfo = null;
  }

  void _save(Entity rowInfo) async {
    String t;
    try {
      if (_dio == null) _dio = new Dio();
      var response;
      if (rowInfo.id != null)
        response = await _dio.put(_URL_saveRow, data: rowInfo);
      else
        response = await _dio.post(_URL_saveRow, data: rowInfo);
      //print(response.statusCode);
      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created)
        t = _tip_saveSuccess;
      else
        t = _tip_saveFail;
    } catch (ex) {
      t = ex;
    }
    _showSnackBarCallback(t);
  }
}

class MyButton extends RaisedButton {
  MyButton({
    @required IconData iconData,
    @required String label,
    @required VoidCallback onPressed,
  }) : super(
            color: Colors.blue,
            textColor: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(iconData, size: 25.0),
                const SizedBox(width: 8.0),
                Text(label),
              ],
            ),
            onPressed: onPressed);
}

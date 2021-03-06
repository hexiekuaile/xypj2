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
  Widget _drawer;
  Widget _body;
  Dio _dio;
  Entity _selectedMetaInfo;
  List<Entity> _rowsInfo; //bodyTable的行数据
  MyDataSource _dataSource;
  Strings strings;
  List<Widget> menuButtons;

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
    strings = Strings.of(context);
    menuButtons = buildMenuButtons();
    return Scaffold(appBar: _appbar, drawer: _drawer, body: _body);
  }

  get _appbar => AppBar(
        title: Text(strings.valueOf("commitInfo.commit") +
            (_selectedMetaInfo == null ? strings.valueOf("commitInfo.info") : _selectedMetaInfo.map['name'])),
        leading: Builder(
          builder: (context) => IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () {
              _drawer = _startBuildMenus();
              Scaffold.of(context).openDrawer();
              Future.delayed(Duration(milliseconds: 1500), () {
                Scaffold.of(context).openEndDrawer();
              });
              setState(() {});
            },
          ),
        ),
        actions: menuButtons,
      );

  //建造菜单右边的几个动作按钮：插入、保存、删除
  List<Widget> buildMenuButtons() {
    return <Widget>[
      MyButton(
          iconData: Icons.add,
          label: strings.valueOf("commitInfo.label_insertButton"),
          onPressed: () {
            if (_body == null || _rowsInfo == null) return;
            if (_rowsInfo.length > 0 && _dataSource._indexCurrent < 0) return;

            Entity e = new Entity(map: Map<String, dynamic>());
            e.map['type'] = _selectedMetaInfo.map['name'];

            if (_rowsInfo.length == 0)
              _rowsInfo.add(e);
            else
              _rowsInfo.insert(_dataSource._indexCurrent, e);

            List<String> _colNames = _selectedMetaInfo.map.keys.toList();
            _colNames..remove('name')..remove('type');
            _dataSource = MyDataSource(_colNames, _rowsInfo, _saveRow);
            _body = _buildBodyTable(_colNames, _dataSource);
            setState(() {});
          }),
      MyButton(
          iconData: Icons.save,
          label: strings.valueOf("commitInfo.label_saveButton"),
          onPressed: () {
            if (_body == null || _rowsInfo == null) return;
            if (_dataSource._indexCurrent != _dataSource._editingIndex) return;

            String act = _dataSource._editingInfo.id == null ? 'insert' : 'update';
            _saveRow(act, entity: _dataSource._editingInfo);
            _dataSource._editingInfo = null;
            _dataSource._editingIndex = -1;
          }),
      MyButton(
          iconData: Icons.remove,
          label: strings.valueOf("commitInfo.label_removeButton"),
          onPressed: () {
            if (_body != null && _dataSource._indexCurrent > -1) {
              Entity entity = _rowsInfo.elementAt(_dataSource._indexCurrent);
              //直接删除，更新UI
              _rowsInfo.removeAt(_dataSource._indexCurrent);
              List<String> _colNames = _selectedMetaInfo.map.keys.toList();
              _colNames..remove('name')..remove('type');
              _dataSource = MyDataSource(_colNames, _rowsInfo, _saveRow);
              _body = _buildBodyTable(_colNames, _dataSource);
              setState(() {});
              //从服务器删除
              if (entity.id != null) {
                _saveRow('delete', id: entity.id);
              }
            }
          }),
    ];
  }

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
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) throw Exception(snapshot.error);
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
      var response = await _dio.get(strings.valueOf("commitInfo.URL_findMenusInfo"));

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
            if (snapshot.hasError) throw Exception(snapshot.error);
            _rowsInfo = snapshot.data;
            List<String> _colNames = _selectedMetaInfo.map.keys.toList();
            _colNames..remove('name')..remove('type');
            _dataSource = MyDataSource(_colNames, _rowsInfo, _saveRow);
            return _buildBodyTable(_colNames, _dataSource);
          }
        } catch (ex) {
          _showSnackBar(ex);
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
      var response = await _dio.get(strings.valueOf("commitInfo.URL_findInfoByType") + seletedMetaInfo.map['name']);
      if (response.statusCode == HttpStatus.ok)
        _bodyTableInfo = (response.data as List<dynamic>).map<Entity>((m) {
          return Entity.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      _showSnackBar(ex);
    }
    return _bodyTableInfo ?? <Entity>[];
  }

  Widget _updateBodyTable() {
    List<String> _colNames = _selectedMetaInfo.map.keys.toList();
    _colNames..remove('type')..remove('name');
    _dataSource = MyDataSource(_colNames, _rowsInfo, _saveRow);
    return _buildBodyTable(_colNames, _dataSource);
  }

  Widget _buildBodyTable(List<String> _colNames, DataTableSource _dataSource) {
    int _defalutRowPageCount = 10; //默认行数/页

    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Text(strings.valueOf("commitInfo.headerText")),
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
      columns: _colNames.map<DataColumn>((txt) {
        return DataColumn(label: Text(txt));
      }).toList(),
      source: _dataSource,
    ));
  }

  //保存行数据到服务器
  Future<int> _saveRow(String act, {Entity entity, String id}) async {
    String t = strings.valueOf("commitInfo.tip_saveFail"); //提示信息
    int n = -1; //返回值0,1表示成功，-1表示失败
    String _URL_saveRow = strings.valueOf("commitInfo.URL_saveRow");
    var response;
    try {
      switch (act) {
        case 'insert':
          {
            response = await _dio.post(_URL_saveRow, data: entity);
            t = strings.valueOf("commitInfo.tip_insertSuccess");
            n = 1;
          }
          break;
        case 'update':
          {
            response = await _dio.put(_URL_saveRow, data: entity);
            t = strings.valueOf("commitInfo.tip_saveSuccess");
            n = 0;
          }
          break;
        case 'delete':
          {
            response = await _dio.delete(_URL_saveRow + id);
            t = strings.valueOf("commitInfo.tip_deleteSuccess");
            n = 1;
          }
          break;
      }
      /*if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.created &&
          response.statusCode != HttpStatus.noContent) {
        t = strings.valueOf("commitInfo.tip_saveFail");
        n = -1;
      }*/
    } catch (ex) {
      t = ex;
    }
    _showSnackBar(t);
    return n;
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

class MyDataSource extends DataTableSource {
  List<String> _colNames;
  List<Entity> _rowsInfo;
  Function _callbackSave; //回调-保存到服务器

  int _indexCurrent = -1; //当前行
  Entity _editingInfo; //正在编辑中的
  int _editingIndex = -1;
  MyDataSource(this._colNames, this._rowsInfo, this._callbackSave);

  @override //根据索引获取内容行
  DataRow getRow(int index) {
    if (index < _rowsInfo.length) {
      final Entity row = _rowsInfo[index];
      return DataRow.byIndex(
        index: index,
        cells: _getCells(index, row),
      );
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
                _editingInfo = new Entity(map: Map<String, dynamic>());
                _editingInfo.id = rowInfo.id;
                if (rowInfo.id == null) _editingInfo.map['type'] = rowInfo.map['type'];
                _editingIndex = index;
              }
              _editingInfo.map[colName] = val;
              rowInfo.map[colName] = val;
            },
            onTap: () {
              _indexCurrent = index;
              //鼠标点击进入录入框
            },
            onEditingComplete: () {
              //print("onEditingComplete");
            },
            onFieldSubmitted: (val) {
              //print("OnFieldSubmitted");
            },
          ), onTap: () {
        //鼠标点击单元格(没有进入录入框)
      });
    }).toList();
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _rowsInfo.length;

  @override //选中的行数
  int get selectedRowCount => 0;
}

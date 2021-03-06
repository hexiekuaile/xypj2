import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web/domain/entity.dart';
import 'package:web/i18n.dart';

Dio _dio = new Dio();
Strings _str; //国际化字符串，从中获取 字符串
List<Entity> _rows; //body区的表格 对应的列表，bodyTable的行数据
int _rowsCount = 0; //表格的总行数
int _countPerPage = PaginatedDataTable.defaultRowsPerPage; //默认的行数/页
List<String> _colNames; //表格的列名

//录入、提交信息视图
class CommitInfo extends StatefulWidget {
  @override
  _CommitInfoState createState() => _CommitInfoState();
}

class _CommitInfoState extends State<CommitInfo> with AutomaticKeepAliveClientMixin {
  //GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<Entity> _metaInfos; //基础信息列表，其name即菜单名
  var _metaInfosFuture;
  Entity _selectedMetaInfo; //选中的基础信息，即选中的菜单，其map中key即body表格 的列名
  MyDataSource _dataSource;
  List<Widget> menuButtons; //菜单右边的几个按钮

  int _countCurrentPage = 0; //当前页数
  int _sortColumnIndex; //排序列索引
  bool _sortAscending = true; //升序
  bool _sortFlag = false; //排序操作的标志

  bool _initFlag = true; //初始化界面标志,作用是避免反复重刷

  @override
  bool get wantKeepAlive => true; //切换页面时，保持状态不刷新

  @override
  void initState() {
    super.initState();
  }

  /*
    onnectionState.none	当前没有连接到任何的异步任务
    ConnectionState.waiting	连接到异步任务并等待进行交互
    ConnectionState.active	连接到异步任务并开始交互
    ConnectionState.done	异步任务中止
  */
  @override
  Widget build(BuildContext context) {
    _str = Strings.of(context);
    if (_initFlag) {
      //只在初始化界面时作用，避免重复刷新
      _metaInfosFuture = _fetchMenus();
      menuButtons = buildMenuButtons();
      _initFlag = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(_str.valueOf("commitInfo.commit") +
              (_selectedMetaInfo == null ? _str.valueOf("commitInfo.info") : _selectedMetaInfo.map['name'])),
          actions: menuButtons,
        ),
        drawer: Drawer(
            child: Center(
                child: FutureBuilder<List<Entity>>(
          future: _metaInfosFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Entity>> snapshot) {
            try {
              if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                //if (snapshot.hasError) throw Exception(snapshot.error);
                _metaInfos = snapshot.data;
                return ListView(
                    children: _metaInfos.map<ListTile>((m) {
                  return ListTile(
                      leading: Icon(Icons.arrow_forward),
                      title: Text(m.map['name'] ?? 'null'),
                      //点击drawer菜单，立即从数据库中提取相对应的信息，显示在body表中//
                      onTap: () {
                        //name不能为null，因为下一步就是根据name从服务器提取bodyTable数据
                        if (m.map['name'] == null) return;
                        _selectedMetaInfo = m;
                        _colNames = _selectedMetaInfo.map.keys.toList();
                        _colNames..remove('type')..remove('name');
                        setState(() {});
                      });
                }).toList());
              }
            } catch (ex) {
              _showSnackBar(context, ex.toString());
            }
            return null; // unreachable
          },
        ))),
        body: Center(
            //正文表格
            child: FutureBuilder<List<Entity>>(
          future: _fetchRows(),
          builder: (BuildContext context, AsyncSnapshot<List<Entity>> snapshot) {
            try {
              if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                //if (snapshot.hasError) throw Exception(snapshot.error);
                if (snapshot.data == null) return Center(); //初始界面时、出现错误返回null数据时
                _sortFlag = false; //复原排序标志
                _dataSource = MyDataSource();
                return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: PaginatedDataTable(
                      header: Text(''),
                      rowsPerPage: _countPerPage,
                      initialFirstRowIndex: _countPerPage * _countCurrentPage,
                      availableRowsPerPage: [5, 10, 20],
                      sortAscending: _sortAscending,
                      sortColumnIndex: _sortColumnIndex,
                      source: _dataSource,
                      columns: _colNames.map<DataColumn>((txt) {
                        return DataColumn(
                            label: Text(
                              txt,
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            onSort: (int columnIndex, bool ascending) =>
                                _sort<String>((Entity d) => d.map[txt].toString(), columnIndex, ascending));
                      }).toList(),
                      onRowsPerPageChanged: (value) {
                        _countPerPage = value;
                        setState(() {});
                      },
                      onPageChanged: (value) {
                        _countCurrentPage = value ~/ _countPerPage; //整除
                        setState(() {});
                      },
                    ));
              }
            } catch (ex) {
              _showSnackBar(context, ex);
            }
            return null; // unreachable
          },
        )));
  }

  //建造菜单右边的几个动作按钮：刷新、插入、保存、删除
  List<Widget> buildMenuButtons() {
    return <Widget>[
      MyButton(
          iconData: Icons.refresh,
          label: _str.valueOf("commitInfo.label_refreshButton"),
          onPressed: () {
            _metaInfosFuture = _fetchMenus(); //刷新基础信息菜单
            _fetchRows(); //刷新表格数据
            //if ( _selectedMetaInfo?.map['name'] != null) _fetchRows();
            //_body = _startBuildTable();
            setState(() {});
          }),
      MyButton(
          iconData: Icons.add,
          label: _str.valueOf("commitInfo.label_insertButton"),
          onPressed: () {
            if (_rows == null) return;
            if (_rows.length > 0 && _dataSource._indexCurrent < 0) return;

            Entity e = new Entity(map: Map<String, dynamic>());
            e.map['type'] = _selectedMetaInfo.map['name'];
            if (_rows.length == 0)
              _rows.add(e);
            else
              _rows.insert(_dataSource._indexCurrent, e);
            _rowsCount = _rows.length;
            // _body = _buildTable();
            setState(() {});
          }),
      MyButton(
          iconData: Icons.save,
          label: _str.valueOf("commitInfo.label_saveButton"),
          onPressed: () {
            if (_rows == null) return;
            if (_dataSource._indexCurrent != _dataSource._editingIndex) return;

            if (_dataSource._editingRow.id == null) {
              _saveRow(context, 'insert',
                  tempEntity: _dataSource._editingRow, entity: _rows.elementAt(_dataSource._editingIndex));
            } else {
              _saveRow(context, 'update', tempEntity: _dataSource._editingRow);
            }
            _dataSource._editingRow = null;
            _dataSource._editingIndex = -1;
          }),
      MyButton(
          iconData: Icons.remove,
          label: _str.valueOf("commitInfo.label_removeButton"),
          onPressed: () async {
            if (_rows != null && _dataSource._indexCurrent > -1) {
              bool b = await _showDeleteConfirmDialog(context);
              if (!b) return;
              Entity entity = _rows.elementAt(_dataSource._indexCurrent);
              //直接删除，更新UI
              _rows.removeAt(_dataSource._indexCurrent);
              _rowsCount = _rows.length;
              //_body = _buildTable();
              setState(() {});
              //从服务器删除
              if (entity.id != null) {
                _saveRow(context, 'delete', id: entity.id);
              }
            }
          }),
    ];
  }

  //从数据库中提取菜单对应的基础信息info
  //如果把这个方法放在FutureBuilder的future中，则初始化界面时调用
  Future<List<Entity>> _fetchMenus() async {
    var v;
    try {
      var response = await _dio.get(_str.valueOf("commitInfo.URL_findMenus"));

      if (response.statusCode == HttpStatus.ok)
        v = (response.data as List<dynamic>).map<Entity>((m) {
          return Entity.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      print(ex);
      _showSnackBar(context, ex.toString());
    }
    return v;
  }

  //通过选定的基础信息名称，从数据库中提取基础信息的一般信息，填充到body中的表。
  //例如，通过 评价指标 这个名称，获取所有的评价指标
  Future<List<Entity>> _fetchRows() async {
    if (_selectedMetaInfo?.map['type'] == null) return null; //比如初始化界面时
    if (_sortFlag) return _rows; //如果是排序操作，则不需要从服务器更新数据，直接返回刚才排序后的数据

    try {
      var response = await Future.wait([
        _dio.get(_str.valueOf("commitInfo.URL_findInfoCount") + _selectedMetaInfo.map['name']),
        _dio.get(_str.valueOf("commitInfo.URL_findInfoByType") +
            _selectedMetaInfo.map['name'] +
            '/$_countCurrentPage/$_countPerPage')
      ]);
      if (response[0].statusCode == HttpStatus.ok) _rowsCount = (response[0].data as int);
      if (response[1].statusCode == HttpStatus.ok)
        _rows = (response[1].data as List<dynamic>).map<Entity>((m) {
          return Entity.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      _rowsCount = 0;
      _rows = null;
      print(ex);
      _showSnackBar(context, ex);
    }
    return _rows;
  }

  //排序
  void _sort<T>(Comparable<T> getField(Entity d), int columnIndex, bool ascending) {
    _dataSource._sort<T>(getField, ascending);
    setState(() {
      this._sortColumnIndex = columnIndex;
      this._sortAscending = ascending;
    });
    _sortFlag = true;
    // print('==== $ascending ${_rows[0].map['类别']} ${_rows[1].map['类别']}');
  }
}

class MyDataSource extends DataTableSource {
  int _indexCurrent = -1; //当前行,用于删除当前行功能
  Entity _editingRow; //正在编辑中的行的实体
  int _editingIndex = -1; //正在编辑的行的索引

  @override //根据索引获取内容行
  DataRow getRow(int index) {
    final Entity row = _rows[index % _countPerPage]; //取余
    //print('$index ${row.id} ${row.map['类别']}');
    return DataRow.byIndex(
      index: index,
      cells: _getCells(index, row),
    );
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
              if (_editingRow == null || _editingRow.id != rowInfo.id) {
                //_editingInfo = Info.fromJson(rowInfo.toJson());
                _editingRow = new Entity(map: Map<String, dynamic>());
                _editingRow.id = rowInfo.id;
                if (rowInfo.id == null) _editingRow.map['type'] = rowInfo.map['type'];
                _editingIndex = index;
              }
              _editingRow.map[colName] = val;
              rowInfo.map[colName] = val;
            },
            onTap: () {
              //鼠标点击进入录入框
              _indexCurrent = index;
              //notifyListeners();
            },
            onEditingComplete: () {},
            onFieldSubmitted: (val) {},
          ), onTap: () {
        //鼠标点击单元格(没有进入录入框)
      });
    }).toList();
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _rowsCount;

  @override //选中的行数
  int get selectedRowCount => 0;

  void _sort<T>(Comparable<T> getField(Entity e), bool ascending) {
    _rows.sort((Entity a, Entity b) {
      if (ascending) {
        final Entity c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
    //print('-- $ascending ${_rows.elementAt(0).map['类别']} ${_rows.elementAt(1).map['类别']}');
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

//保存修改变化的行数据到服务器,
//entit是修改的实体，tempEntity保存修改变化的值，不把全部值上传保存
//id是将要删除的entity的id
Future<dynamic> _saveRow(BuildContext context, String act, {Entity tempEntity, Entity entity, String id}) async {
  String t = _str.valueOf("commitInfo.tip_saveFail"); //提示信息
  dynamic n; //返回值
  String _URL_saveRow = _str.valueOf("commitInfo.URL_saveRow");
  Response response;
  try {
    switch (act) {
      case 'insert':
        {
          response = await _dio.post(_URL_saveRow, data: tempEntity);
          t = _str.valueOf("commitInfo.tip_insertSuccess");
          entity.id = response.data;
          n = response.data;
        }
        break;
      case 'update':
        {
          response = await _dio.patch(_URL_saveRow, data: tempEntity);
          t = _str.valueOf("commitInfo.tip_saveSuccess");
        }
        break;
      case 'delete':
        {
          response = await _dio.delete(_URL_saveRow + id);
          t = _str.valueOf("commitInfo.tip_deleteSuccess");
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
  _showSnackBar(context, t);
  return n;
}

//在底部显示消息提示栏
void _showSnackBar(BuildContext context, String title) {
  final snackBar = new SnackBar(
    content: new Text(title),
    backgroundColor: Colors.blue,
    duration: Duration(seconds: 5),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}

// 弹出对话框
Future<bool> _showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(_str.valueOf('commitInfo.tip_deleteTitle')),
        content: Text(_str.valueOf('commitInfo.tip_deleteContent')),
        actions: <Widget>[
          FlatButton(
            child: Text(_str.valueOf('commitInfo.tip_deleteFalse')),
            onPressed: () => Navigator.of(context).pop(false), // 关闭对话框
          ),
          FlatButton(
            child: Text(_str.valueOf('commitInfo.tip_deleteTrue')),
            onPressed: () {
              //关闭对话框并返回true
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web/domain/info.dart';
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
  Info _selectedMetaInfo;
  Dio _dio;
  Widget _drawer;
  Widget _body;

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
        title: Text(Strings.of(context).valueOf("commitInfo.commit") + (_selectedMetaInfo == null ? Strings.of(context).valueOf("commitInfo.info") : _selectedMetaInfo.name)),
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
      );

  //开始构建drawer菜单，
  FutureBuilder<List<Info>> _startBuildMenus() {
    return FutureBuilder<List<Info>>(
      future: _fetchMenusInfo(),
      builder: (BuildContext context, AsyncSnapshot<List<Info>> snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
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
  Future<List<Info>> _fetchMenusInfo() async {
    List<Info> _menusInfo;
    try {
      // var response = await _dio.get(M.URL_FindMetaInfoByType + '基础信息');
      var response = await _dio.get(Strings.of(context).valueOf("commitInfo.URL_findMenusInfo"));
      // print('${response.statusCode} : ${response.statusMessage} }' );
      if (response.statusCode == HttpStatus.ok)
        _menusInfo = (response.data as List<dynamic>).map<Info>((m) {
          return Info.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      _showSnackBar(ex.toString());
    }
    return _menusInfo ?? <Info>[];
  }

  Widget _buildMenus(List<Info> menusInfo) {
    List<ListTile> listTiles;
    listTiles = menusInfo.map<ListTile>((m) {
      return ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text(m.name),
          //点击drawer菜单，立即从数据库中提取相对应的信息，显示在body表中//
          onTap: () {
            _selectedMetaInfo = m;
            _body = _startBuildBodyTable(m);
            setState(() {});
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
  FutureBuilder<List<Info>> _startBuildBodyTable(Info selectedMetaInfo) {
    return FutureBuilder<List<Info>>(
      future: _fetchRowsInfo(selectedMetaInfo),
      builder: (BuildContext context, AsyncSnapshot<List<Info>> snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            /*   if (snapshot.hasError) {
              _showSnackBar(snapshot.error.toString());
              return null;
            }*/
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
  Future<List<Info>> _fetchRowsInfo(Info seletedMetaInfo) async {
    List<Info> _bodyTableInfo;
    try {
      var response = await _dio.get(Strings.of(context).valueOf("commitInfo.URL_findInfoByType") + seletedMetaInfo.name);
      if (response.statusCode == HttpStatus.ok)
        _bodyTableInfo = (response.data as List<dynamic>).map<Info>((m) {
          return Info.fromJson((m as Map<String, dynamic>));
        }).toList();
    } catch (ex) {
      _showSnackBar(ex.toString());
    }
    return _bodyTableInfo ?? <Info>[];
  }

  Widget _buildBodyTable(Info selectedMetaInfo, List<Info> rowsInfo) {
    List<String> _colNames = selectedMetaInfo.map.keys.toList();
    int _defalutRowPageCount = PaginatedDataTable.defaultRowsPerPage; //默认一页行数
    //分页表
    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Text(''),
      rowsPerPage: _defalutRowPageCount,
      onRowsPerPageChanged: (value) {
        _defalutRowPageCount = value;
        setState(() {});
      },
      initialFirstRowIndex: 0,
      availableRowsPerPage: [
        10,
        20
      ],
      onPageChanged: (value) {
        print('翻页： $value');
      },
      columns: _getCols(_colNames),
      source: BodyTableSource(_colNames, rowsInfo),
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
  List<Info> _rowsInfo;
  Info _editingInfo; //正在编辑中的
  int _editingIndex = -1;

  BodyTableSource(this._colNames, this._rowsInfo);

  //一行所有单元格
  List<DataCell> _getRow(int index, Info rowInfo) {
    return _colNames.map<DataCell>((colName) {
      return DataCell(
          TextFormField(
            key: UniqueKey(),
            initialValue: rowInfo.map[colName],
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (val) {
              //录入框值改变，将变化写入editing
              if (_editingInfo == null || _editingInfo.id != rowInfo.id) {
                //_editingInfo = Info.fromJson(rowInfo.toJson());
                _editingInfo = rowInfo.clone();
                _editingIndex = index;
              }
              _editingInfo.map[colName] = val;
            },
            onTap: () {
              //鼠标点击进入录入框，准备提交保存改变
              if (_editingIndex < 0 || _editingIndex == index) return;
              save();
              //print("=======录入框 ${rowInfo.id}");
            },
          ), onTap: () {
        //鼠标点击单元格(没有进入录入框)，准备提交保存改变
        if (_editingIndex < 0 || _editingIndex == index) return;
        save();
        //print("---单元格 ${rowInfo.id}");
      });
    }).toList();
  }

  @override //根据索引获取内容行
  DataRow getRow(int index) {
    final Info row = _rowsInfo[index];
    return DataRow.byIndex(index: index, cells: _getRow(index, row));
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _rowsInfo.length;

  @override //选中的行数
  int get selectedRowCount => 0;

  void save() {
    Info tmp = _rowsInfo[_editingIndex];
    /////////////////////================
    _editingInfo.map.keys.forEach((k) {
      if (_editingInfo.map[k].toString() == tmp.map[k].toString()) _editingInfo.map.remove(k);
    });

    print("----------------------");
    print(_editingInfo.id);
    print(_editingInfo.name);
    print(_editingInfo.type);
    _editingInfo.map.keys.forEach((k) {
      print(k + ': ' + _editingInfo.map[k]);
    });

    print("==================");
    print(tmp.id);
    print(tmp.name);
    print(tmp.type);
    tmp.map.keys.forEach((k) {
      print(k + ': ' + tmp.map[k]);
    });
    _editingIndex = -1;
    _editingInfo = null;
  }
}

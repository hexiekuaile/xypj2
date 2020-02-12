import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web/domain/info.dart';
import 'package:web/m.dart';
import 'package:web/i18n.dart';

//录入、提交信息视图
class CommitInfo extends StatefulWidget {
  @override
  _CommitInfoState createState() => _CommitInfoState();
}

class _CommitInfoState extends State<CommitInfo> with AutomaticKeepAliveClientMixin {
  //GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<Info> _menusMetaInfo;
  List<Info> _bodyTableInfo;
  Info _selectedMetaInfo;
  Dio _dio;
  Drawer _drawer;
  Widget _body;

  @override
  bool get wantKeepAlive => true; //切换页面时，保持状态不刷新

  @override
  void initState() {
    super.initState();
    _dio = new Dio();
    _fetchMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbar, drawer: _drawer == null ? CircularProgressIndicator() : _drawer, body: _body);
  }

  get _appbar => AppBar(
        title: Text(Strings.of(context).valueOf("commitInfo.commit") + (_selectedMetaInfo == null ? Strings.of(context).valueOf("commitInfo.info") : _selectedMetaInfo.name)),
      );

  //从数据库中提取基础信息，作为 drawer 菜单
  Future _fetchMenus() async {
    var response = await _dio.get(M.URL_FindMetaInfoByType + '基础信息');
    if (response.statusCode != HttpStatus.ok) return null;
    _menusMetaInfo = (response.data as List<dynamic>).map<Info>((m) {
      return Info.fromJson((m as Map<String, dynamic>));
    }).toList();
    if (_menusMetaInfo == null) _menusMetaInfo = <Info>[];
    List<ListTile> ll = _menusMetaInfo.map<ListTile>((m) {
      return ListTile(
          leading: Icon(Icons.info),
          title: Text(m.name),
          //点击drawer菜单，立即从数据库中提取相对应的信息，显示在body表中//
          onTap: () {
            _selectedMetaInfo = m;
            _body = _futureBodyTable(m);
            setState(() {});
          });
    }).toList();
    _drawer = Drawer(
      child: ListView(
        children: ll,
      ),
    );
    setState(() {});
  }

  //通过选定的基础信息名称，从数据库中提取基础信息的一般信息，填充到body中的表。
  //例如，通过 评价指标 这个名称，获取所有的评价指标
  Future<List<Info>> _fetchBodyTableInfo(Info seletedMetaInfo) async {
    var response = await _dio.get(M.URL_FindMetaInfoByType + seletedMetaInfo.name);
    if (response.statusCode != HttpStatus.ok) return null;
    _bodyTableInfo = (response.data as List<dynamic>).map<Info>((m) {
      return Info.fromJson((m as Map<String, dynamic>));
    }).toList();
    if (_bodyTableInfo == null) _bodyTableInfo = <Info>[];
    return _bodyTableInfo;
  }

  /*
    onnectionState.none	当前没有连接到任何的异步任务
    ConnectionState.waiting	连接到异步任务并等待进行交互
    ConnectionState.active	连接到异步任务并开始交互
    ConnectionState.done	异步任务中止
    */
  FutureBuilder<List<Info>> _futureBodyTable(Info selectedMetaInfo) {
    return FutureBuilder<List<Info>>(
      future: _fetchBodyTableInfo(selectedMetaInfo),
      builder: (BuildContext context, AsyncSnapshot<List<Info>> snapshot) {
        if (snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return _BodyTable(selectedMetaInfo, snapshot.data);
        }
        return null; // unreachable
      },
    );
  }

  Widget _BodyTable(Info selectedMetaInfo, List<Info> list) {
    List<Info> _rowsInfo = list == null ? <Info>[] : list;
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
        5,
        10,
        20
      ],
      columns: _getCols(_colNames),
      source: BodyTableSource(_colNames, _rowsInfo),
    ));
  }

  List<DataColumn> _getCols(List<String> colNames) {
    return colNames.map<DataColumn>((txt) {
      return DataColumn(label: Text(txt));
    }).toList();
  }
}

class BodyTableSource extends DataTableSource {
  List<String> _colNames;
  List<Info> _rowsInfo;

  BodyTableSource(this._colNames, this._rowsInfo);

  //一行所有单元格
  List<DataCell> _getRow(Info rowInfo) {
    return _colNames.map<DataCell>((txt) {
      return DataCell(Text(rowInfo.map[txt]));
    }).toList();
  }

  @override //根据索引获取内容行
  DataRow getRow(int index) {
    final Info row = _rowsInfo[index];
    return DataRow.byIndex(
      index: index,
      cells: _getRow(row),
    );
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _rowsInfo.length;

  @override //选中的行数
  int get selectedRowCount => 0;
}

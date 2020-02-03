import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/danWeiZhiBiaoFenShu.dart';
import '../m.dart';

//评价分数表格视图
class ViewZhiBiaoFenShu extends StatefulWidget {
  @override
  _ViewZhiBiaoFenShuState createState() => _ViewZhiBiaoFenShuState();
}

class _ViewZhiBiaoFenShuState extends State<ViewZhiBiaoFenShu> {
  // //默认一页行数
  int _defalutRowPageCount = PaginatedDataTable.defaultRowsPerPage;

  List<DataColumn> getColumn() {
    return [
      DataColumn(
        label: Text(M.danwei),
      ),
      DataColumn(
        label: Text(M.pjzb),
      ),
      DataColumn(
        label: Text(M.fenShu_qiyezhichaFenShu),
      ),
      DataColumn(
        label: Text(M.fenShu_xianjipinjiaFenShu),
      ),
      DataColumn(
        label: Text(M.fenShu_shijipinjiaFenShu),
      ),
      DataColumn(
        label: Text(M.fenShu_beiZhu),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }

  FutureBuilder<List<DanWeiZhiBiaoFenShu>> buildFutureBuilder() {
    return new FutureBuilder<List<DanWeiZhiBiaoFenShu>>(
      future: fetchBeans(),
      builder: (BuildContext context,
          AsyncSnapshot<List<DanWeiZhiBiaoFenShu>> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          print(snapshot.connectionState);
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            print("错误：${snapshot.error}");
            return Text('Error: ${snapshot.error}');
          } else {
            //snapshot.hasData
            //print('结果: ${snapshot.data}');
            return paginatedDataTable(beans: snapshot.data);
          }
        }
        return null; // unreachable
      },
    );
  }

  Widget paginatedDataTable({List<DanWeiZhiBiaoFenShu> beans}) {
    //分页表
    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Text(M.danWeiZhiBiaoFenShu),
      rowsPerPage: _defalutRowPageCount,
      onRowsPerPageChanged: (value) {
        setState(() {
          _defalutRowPageCount = value;
        });
      },
      initialFirstRowIndex: 0,
      availableRowsPerPage: [5, 10],
      onPageChanged: (value) {
        //print('翻页： $value');
      },
      columns: getColumn(),
      source: MyTable(beans),
    ));
  }
}

class MyTable extends DataTableSource {
  List<DanWeiZhiBiaoFenShu> _beans;

  MyTable(this._beans);

  @override
  DataRow getRow(int index) {
    //根据索引获取内容行
    final DanWeiZhiBiaoFenShu bean = _beans[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${bean.danWei.name}')),
        DataCell(Text('${bean.zhiBiao.name}')),
        DataCell(Text('${bean.qiyezhichaFenShu}')),
        DataCell(Text('${bean.xianjipinjiaFenShu}')),
        DataCell(Text('${bean.shijipinjiaFenShu}')),
        DataCell(Text('${bean.beiZhu}')),
      ],
    );
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _beans.length;

  @override //选中的行数
  int get selectedRowCount => 0;
}

Future<List<DanWeiZhiBiaoFenShu>> fetchBeans() async {
  //Dio dio = new Dio();
  //Response response = await dio.get('http://localhost:1112/pjzb');
  final response = await http.get(M.fenShu_GetUrl); //类型：Future<Response>
  //print('aaaa: ${response.runtimeType}');//类型：Response
  //print('bbb:  ${response}');
  //print('aaaa:  ${response.body.toString()}');
  return compute(_parseBeans, response.body.toString());
}

List<DanWeiZhiBiaoFenShu> _parseBeans(String responseBody) {
  //jsonDecode(s);json.decode(responseBody)
  var listDynamic = jsonDecode(responseBody); // List<dynamic>
  //显式类型转换 List<dynamic>   ->  List<Map<String, dynamic>>
  List<Map<String, dynamic>> listMap =
      new List<Map<String, dynamic>>.from(listDynamic);
//按照单位名称排序
  listMap.sort((a, b) => a['danWei']['name'].compareTo(b['danWei']['name']));

  List<DanWeiZhiBiaoFenShu> M = new List();
  listMap.forEach((m) => M.add(new DanWeiZhiBiaoFenShu.fromJson(m)));
  return M;
}

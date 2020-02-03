import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../m.dart';
import '../domain/danWei.dart';

//单位表格视图
class ViewDanwei extends StatefulWidget {
  @override
  _ViewDanweiState createState() => _ViewDanweiState();
}

class _ViewDanweiState extends State<ViewDanwei> {
  // //默认一页行数
  int _defalutRowPageCount = PaginatedDataTable.defaultRowsPerPage;

  List<DataColumn> getColumn() {
    return [
      DataColumn(
        label: Text(M.danweiXiaqu),
      ),
      DataColumn(
        label: Text(M.danweiName),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }

  FutureBuilder<List<DanWei>> buildFutureBuilder() {
    return new FutureBuilder<List<DanWei>>(
      future: fetchBeans(),
      builder: (BuildContext context, AsyncSnapshot<List<DanWei>> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          //print(snapshot.connectionState);
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

  Widget paginatedDataTable({List<DanWei> beans}) {
    //分页表
    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Text(M.danwei),
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
  List<DanWei> _beans;

  MyTable(this._beans);

  @override
  DataRow getRow(int index) {
    //根据索引获取内容行
    final DanWei bean = _beans[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${bean.xiaqu}')),
        DataCell(Text('${bean.name}'))
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

Future<List<DanWei>> fetchBeans() async {
  //Dio dio = new Dio();
  //Response response = await dio.get('http://localhost:1112/pjzb');
  final response = await http.get(M.danweiGetUrl); //类型：Future<Response>
  //print('aaaa: ${response.runtimeType}');//类型：Response
  //print('bbb:  ${response}');
  //print('aaaa:  ${response.body.toString()}');
  return compute(_parseBeans, response.body.toString());
}

List<DanWei> _parseBeans(String responseBody) {
  //jsonDecode(s);json.decode(responseBody)
  var listDynamic = jsonDecode(responseBody); // List<dynamic>
  //显式类型转换 List<dynamic>   ->  List<Map<String, dynamic>>
  List<Map<String, dynamic>> listMap =
      new List<Map<String, dynamic>>.from(listDynamic);

  List<DanWei> M = new List();
  listMap.forEach((m) => M.add(new DanWei.fromJson(m)));
  return M;
}

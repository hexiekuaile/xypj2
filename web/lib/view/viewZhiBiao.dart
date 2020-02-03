import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../m.dart';
import '../domain/zhiBiao.dart';

//评价指标表格视图
class ViewPjzb extends StatefulWidget {
  @override
  _ViewPjzbState createState() => _ViewPjzbState();
}

class _ViewPjzbState extends State<ViewPjzb> {
  // //默认一页行数
  int _defalutRowPageCount = PaginatedDataTable.defaultRowsPerPage;

  List<DataColumn> getColumn() {
    return [
      DataColumn(
        label: Text(M.pjzbType),
      ),
      DataColumn(
        label: Text(M.pjzbName),
      ),
      DataColumn(
        label: Text(M.pjzbValue),
      ),
      DataColumn(
        numeric: true,
        label: Text(M.pjzbZccl),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }

  FutureBuilder<List<ZhiBiao>> buildFutureBuilder() {
    return new FutureBuilder<List<ZhiBiao>>(
      future: fetchBeans(),
      builder: (BuildContext context, AsyncSnapshot<List<ZhiBiao>> snapshot) {
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

  Widget paginatedDataTable({List<ZhiBiao> beans}) {
    //分页表
    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Text(M.pjzbTitle),
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
  List<ZhiBiao> _beans;

  MyTable(this._beans);

  @override
  DataRow getRow(int index) {
    //根据索引获取内容行
    // if (index >= dataList.length || index < 0) throw FlutterError('取错数据了。');
    //如果索引不在商品列表里面，抛出一个异常
    final ZhiBiao bean = _beans[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${bean.type}')),
        DataCell(Text('${bean.name}')),
        DataCell(Text('${bean.value}')),
        DataCell(Text('${bean.zccl}')),
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

Future<List<ZhiBiao>> fetchBeans() async {
  //Dio dio = new Dio();
  //Response response = await dio.get('http://localhost:1112/pjzb');
  final response = await http.get(M.pjzbGetUrl); //类型：Future<Response>
  //print('aaaa: ${response.runtimeType}');//类型：Response
  //print('bbb:  ${response}');
  //print('aaaa:  ${response.body.toString()}');
  return compute(_parseBeans, response.body.toString());
}

List<ZhiBiao> _parseBeans(String responseBody) {
  //jsonDecode(s);json.decode(responseBody)
  var listDynamic = jsonDecode(responseBody); // List<dynamic>
  //显式类型转换 List<dynamic>   ->  List<Map<String, dynamic>>
  List<Map<String, dynamic>> listMap =
      new List<Map<String, dynamic>>.from(listDynamic);

  List<ZhiBiao> M = new List();
  listMap.forEach((m) => M.add(new ZhiBiao.fromJson(m)));
  return M;
}

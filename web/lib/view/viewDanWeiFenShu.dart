import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/danWeiFenShu.dart';
import '../m.dart';

//评价分数表格视图
class ViewDanWeiFenShu extends StatefulWidget {
  @override
  _ViewDanWeiFenShuState createState() => _ViewDanWeiFenShuState();
}

class _ViewDanWeiFenShuState extends State<ViewDanWeiFenShu>
    with AutomaticKeepAliveClientMixin {
  // //默认一页行数
  int _defalutRowPageCount = PaginatedDataTable.defaultRowsPerPage;

  List<DataColumn> getColumn() {
    return [
      DataColumn(
        label: Text(M.danwei),
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
  bool get wantKeepAlive => true;//切换页面时，保持页面状态，不再刷新

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }

  FutureBuilder<List<DanWeiFenShu>> buildFutureBuilder() {
    return new FutureBuilder<List<DanWeiFenShu>>(
      future: fetchBeans(),
      builder:
          (BuildContext context, AsyncSnapshot<List<DanWeiFenShu>> snapshot) {
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

  Widget paginatedDataTable({List<DanWeiFenShu> beans}) {
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
  List<DanWeiFenShu> _beans;

  MyTable(this._beans);

  @override
  DataRow getRow(int index) {
    //根据索引获取内容行
    final DanWeiFenShu bean = _beans[index];
    return DataRow.byIndex(
      index: index,
      selected: false,
      cells: <DataCell>[
        DataCell(Text('${bean.danWei.name}')),
        DataCell(Text('${bean.qiyezhichaFenShu}')),
        DataCell(Text('${bean.xianjipinjiaFenShu}')),
        DataCell(Text('${bean.shijipinjiaFenShu}')),
        DataCell(Text('${bean.beiZhu}')),
      ],
      onSelectChanged: (val){},
    );
  }

  @override //是否行数 不确定
  bool get isRowCountApproximate => false;

  @override //有多少行
  int get rowCount => _beans.length;

  @override //选中的行数
  int get selectedRowCount => 0;
}

Future<List<DanWeiFenShu>> fetchBeans() async {
  //Dio dio = new Dio();
  //Response response = await dio.get('http://localhost:1112/pjzb');
  final response = await http.get(M.fenShu_GetUrl); //类型：Future<Response>
  //print('aaaa: ${response.runtimeType}');//类型：Response
  //print('bbb:  ${response}');
  //print('aaaa:  ${response.body.toString()}');
  return compute(_parseBeans, response.body.toString());
}

List<DanWeiFenShu> _parseBeans(String responseBody) {
  //jsonDecode(s);json.decode(responseBody)
  var listDynamic = jsonDecode(responseBody); // List<dynamic>
  //显式类型转换 List<dynamic>   ->  List<Map<String, dynamic>>
  List<Map<String, dynamic>> listMap =
      new List<Map<String, dynamic>>.from(listDynamic);

  //按照单位名称排序
  //listMap.sort((a, b) => a['danWei']['name'].compareTo(b['danWei']['name']));

  List<DanWeiFenShu> listdwfs = new List();
//把每个单位的每项指标的三个分数(企业自查分,县级评分,市级评分)分别相加,得出每个单位的三个分数
  DanWeiFenShu d;
  listMap.forEach((lm) {
    if (d != null) {
      //中间过程中的每一个的处理方法, 同一个单位
      if (d.danWei.name == lm['danWei']['name']) {
        d.qiyezhichaFenShu += lm['qiyezichafenshu'];
        d.xianjipinjiaFenShu += lm['xianjipinjiafenshu'];
        d.shijipinjiaFenShu += lm['shijifuhefenshu'];
        if (lm['dafenshuoming'] != null) {
          if (d.beiZhu != null)
            d.beiZhu = d.beiZhu + ';' + lm['dafenshuoming'];
          else
            d.beiZhu = lm['dafenshuoming'];
        }
      } else {
        //遇到不是一个单位的
        if (d.beiZhu == null) d.beiZhu = '';
        listdwfs.add(d); //添加到列表中
        //再初始化一个 单位分数对象
        d = new DanWeiFenShu.fromJson(lm);
        d.qiyezhichaFenShu += 100;
        d.xianjipinjiaFenShu += 100;
        d.shijipinjiaFenShu += 100;
      }
    } else {
      //d==null 第一个处理方法
      d = new DanWeiFenShu.fromJson(lm);
      d.qiyezhichaFenShu += 100; //初始化 单位分数对象
      d.xianjipinjiaFenShu += 100;
      d.shijipinjiaFenShu += 100;
    }
  });
  //处理最后一个,防止数据库返回一个空列表
  if (d != null) {
    if (d.beiZhu == null) d.beiZhu = '';
    listdwfs.add(d); //添加到列表中
  }

  return listdwfs;
}

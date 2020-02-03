import 'package:flutter/material.dart';
import 'package:web/view/commitMetaInfo.dart';
import 'package:web/view/viewDanWeiFenShu.dart';
import 'package:web/view/viewDanWeiZhiBiaoFenShu.dart';

import 'view/childItemView.dart';
import 'm.dart';
import 'view/viewDanWei.dart';
import 'view/viewZhiBiao.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: M.appName,
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
      ),*/
      home: BotomeMenumBarPage(),
    );
  }
}

class BotomeMenumBarPage extends StatefulWidget {
  @override
  BotomeMenumBarPageState createState() => BotomeMenumBarPageState();
}

class BotomeMenumBarPageState extends State<BotomeMenumBarPage> {
  BotomeMenumBarPageState();

  @override
  Widget build(BuildContext context) {
    return buildBottomTabScaffold();
  }

  //当前显示页面的
  int currentIndex = 0;

  //点击导航项是要显示的页面
  final pages = [
    ChildItemView("首页"),
    ViewPjzb(), //显式指标
    ViewDanwei(), //显式单位表
    ViewZhiBiaoFenShu(), //显式指标分数表
    ViewDanWeiFenShu(), //显式单位分数表
    new CommitMetaInfo() //提交基本信息视图
  ];
  final items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
    BottomNavigationBarItem(icon: Icon(Icons.music_video), title: Text('指标')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('指标分数')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('单位分数')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('基础信息'))
  ];

  void onTap(int index) {
    print('qqqqqqqqqqqqqqq $index');
    setState(() {
      currentIndex = index;
    });
  }

  Widget buildBottomTabScaffold() {
    return SizedBox(
        height: 100,
        child: Scaffold(
          //对应的页面
          body: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          //pages[currentIndex],
          //appBar: AppBar(title: const Text('Bottom App Bar')),
          //悬浮按钮的位置
/*          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          //悬浮按钮
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              print("add press ");
            },
          ),*/
          //其他菜单栏
          bottomNavigationBar: BottomNavigationBar(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          /*BottomAppBar(
            //悬浮按钮 与其他菜单栏的结合方式
            shape: CircularNotchedRectangle(),
            // FloatingActionButton和BottomAppBar 之间的差距
            notchMargin: 6.0,
            color: Colors.blue,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildBotomItem(currentIndex, 0, Icons.home, "首页"),
                buildBotomItem(currentIndex, 1, Icons.library_music, M.pjzb),
                buildBotomItem(currentIndex, 2, Icons.person, M.danwei),
                //buildBotomItem(currentIndex, -1, null, "发现"),
                buildBotomItem(
                    currentIndex, 3, Icons.email, M.danWeiZhiBiaoFenShu),
                buildBotomItem(currentIndex, 4, Icons.email, M.danWeiFenShu),
                buildBotomItem(currentIndex, 5, Icons.email, M.metaInfo),
              ],
            ),
          ),*/
        ));
  }

// ignore: slash_for_doc_comments
  /**
   * @param selectIndex 当前选中的页面
   * @param index 每个条目对应的角标
   * @param iconData 每个条目对就的图标
   * @param title 每个条目对应的标题
   */
  buildBotomItem(int selectIndex, int index, IconData iconData, String title) {
    //未选中状态的样式
    TextStyle textStyle = TextStyle(fontSize: 12.0, color: Colors.grey);
    MaterialColor iconColor = Colors.grey;
    double iconSize = 20;
    EdgeInsetsGeometry padding = EdgeInsets.only(top: 5.0);

    if (selectIndex == index) {
      //选中状态的文字样式
      textStyle = TextStyle(fontSize: 13.0, color: Colors.blue);
      //选中状态的按钮样式
      iconColor = Colors.blue;
      iconSize = 25;
      padding = EdgeInsets.only(top: 10.0);
    }
    Widget padItem;
    if (iconData != null) {
      padItem = Padding(
        padding: padding,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: <Widget>[
                Icon(
                  iconData,
                  color: iconColor,
                  size: iconSize,
                ),
                Text(
                  title,
                  style: textStyle,
                )
              ],
            ),
          ),
        ),
      );
    }
    Widget item = Expanded(
      flex: 1,
      child: new GestureDetector(
        onTap: () {
          if (index != currentIndex) {
            setState(() {
              currentIndex = index;
            });
          }
        },
        child: SizedBox(
          height: 52,
          child: padItem,
        ),
      ),
    );
    return item;
  }
}


/*
  Text _tableHeadCell(String txt) {
    return Text(
      txt,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, height: 2),
    );
  }

Widget Mytable({MetaInfo m}) {
  List<Text> cells = m.map.keys.map<Text>((key) {
    return _tableHeadCell(key);
  }).toList();
  TableRow th = TableRow(
      decoration:
      new BoxDecoration(color: Color.fromARGB(255, 195, 221, 224)), //表头底色
      children: cells);

  return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
      child: new Column(
        children: <Widget>[
          Container(
              child: Text(
                '评 价 指 标',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 3),
              )),
          Listener(
              child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: new TableBorder.all(
                      width: 1.0,
                      color: Color.fromARGB(255, 169, 198, 201), //表格线颜色
                      style: BorderStyle.solid),
                  children: <TableRow>[
                    th, //表头
                    TableRow(
                      decoration: new BoxDecoration(color: bg), //表格底色
                      children: cells,
                    ),
                    TableRow(
                      decoration: new BoxDecoration(color: bg),
                      children: cells,
                    ),
                    TableRow(
                      decoration: new BoxDecoration(color: bg),
                      children: cells,
                    ),
                  ])),
        ],
      ));
}*/

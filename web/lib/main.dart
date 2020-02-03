import 'package:flutter/material.dart';
import 'package:web/view/commitInfo.dart';
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
      debugShowCheckedModeBanner: false,
      title: M.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//当前显示页面的
  int currentIndex = 0;

  //点击导航项是要显示的页面
  final pages = [
    ChildItemView("首页"),
    ViewPjzb(), //显式指标
    ViewDanwei(), //显式单位表
    ViewZhiBiaoFenShu(), //显式指标分数表
    ViewDanWeiFenShu(), //显式单位分数表
    new CommitMetaInfo() ,//提交基本信息视图
    new CommitInfo(),

  ];
  final menus = [
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
    BottomNavigationBarItem(icon: Icon(Icons.music_video), title: Text('指标')),
    BottomNavigationBarItem(icon: Icon(Icons.music_video), title: Text('单位')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('指标分数')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('单位分数')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('基础信息')),
    BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('信息')),
  ];
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.blue,
        items: menus,
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }

  void onTap(int index) {
    //print('qqqqqqqqqqqqqqq $index');
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}

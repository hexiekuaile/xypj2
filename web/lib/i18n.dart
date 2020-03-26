//import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Strings {
  //约定：国际化字符串必须放在这个目录下
  static const String _dir = './i18n/';
  Locale _loc;
  Map<String, dynamic> _map;

  Strings(Locale loc) {
    this._loc = loc;
  }

  //国际化json文件目录
  String get dir => _dir;

  //区域
  Locale get locale => _loc;

  //国际化字符串map
  Map<String, dynamic> get map => _map;

  //获取context中的Strings
  static Strings of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings);
  }

//获取国际化字符串类
  static Future<Strings> load(Locale loc) async {
    Strings strings = new Strings(loc);

    String p;
    if (loc?.countryCode?.isEmpty == true)
      p = '$_dir${loc.languageCode}.json';
    else
      p = '$_dir${loc.languageCode}_${loc.countryCode}.json';

    String data = await rootBundle.loadString(p);
    strings._map = json.decode(data);
    return strings;
  }

  String valueOf(String key, {List<String> args, Map<String, dynamic> namedArgs}) {
    String value;
    //1、支持嵌套功能：比如key=a.b.c
    if (key.contains('.')) {
      List<String> list = key.split('.');
      dynamic map = _map;
      for (var i = 0; i < list.length; i++) {
        if (!((map as Map).containsKey(list[i]))) return key;
        map = (map as Map)[list[i]];
        if (i < list.length - 1) {
          if (!(map is Map)) return key;
        } else if (i == list.length - 1) {
          if (map is Map)
            return key;
          else
            value = map.toString();
        }
      }
    }
    //以下json不嵌套
    //如果json文件不存在key，则返回key
    else {
      if (!_map.containsKey(key)) return key;
      value = _map[key].toString();
    }
    //2、支持插值功能：
    if (args != null || namedArgs != null) value = _interpolateValue(value, args, namedArgs);

    //3、增加变量功能：正则表达式，正向肯定预查、反向肯定预查，比如用ip=127.0.0.1 替换 a=http://<<ip>>/entity/ 中的ip
    RegExp reg = new RegExp(r"(?<=<<).*?(?=>>)");
    Iterable<Match> matches = reg.allMatches(value);
    if (matches.isNotEmpty) {
      matches.forEach((Match m) {
        String s2 = valueOf(m.group(0));
        String s1 = '<<${m.group(0)}>>';
        //print('$s1 $s2');
        value = value.replaceAll(s1, s2);
      });
    }

    return value;
  }

  //插值功能：
  // 支持用字符串替换 {0} {1}等等，序号从0开始;支持用Map value替换::Map key::
  //例子： "pushedTimes": "按键次数{0}xxx{1}"
  String _interpolateValue(String value, List<String> args, Map<String, dynamic> namedArgs) {
    for (int i = 0; i < (args?.length ?? 0); i++) {
      value = value.replaceAll("{$i}", args[i]);
    }

    if (namedArgs?.isNotEmpty == true) {
      namedArgs.forEach((entryKey, entryValue) => value = value.replaceAll("::$entryKey::", entryValue.toString()));
    }

    return value;
  }
}

class I18nDelegate extends LocalizationsDelegate<Strings> {
  //当前区域
  Locale _loc;
  //支持的国际化区域，对应提供的国际化json字符串文件
  static List<Locale> _supportedLocales = [Locale('zh', 'CN')];

  I18nDelegate(this._loc);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Strings> load(Locale locale) async {
    //每次程序回调本load方法时，：
    //1、当MaterialApp的supportedLocales属性值只有一个时，参数locale=supportedLocales[0];
    //2、当MaterialApp的supportedLocales属性值多于一个时，参数locale=安卓手机语言设置列表第0个;
    //即安卓手机语言设置列表项 依次 是否在MaterialApp的supportedLocales列表项里
    // app启动时：构造器传进来的_loc==null
    //手动更改语言时：构造器传进来的_loc !=null
    _loc = _loc ?? locale;
    Strings strings = await Strings.load(_loc);

    //_setSupportedLocales(strings.valueOf("supportedLocales"));
    return strings;
  }

  static void _setSupportedLocales(String str) {
    //"supportedLocales": "zh_CN,en_US,ja_JP",
    if (str?.isEmpty == true) return;
    List<String> str0 = str.split(',');
    if (str0.length <= _supportedLocales.length) return;
    _supportedLocales = str0.map<Locale>((str00) {
      List<String> str000 = str00.split('_');
      return Locale(str000[0], str000[1]);
    }).toList();
  }

  @override
  bool shouldReload(I18nDelegate old) => false;

  static List<Locale> get supportedLocales => _supportedLocales;
}

//信息类
class Info {
  String id;
  String name; //名称
  String type; //类型
  Map<String, dynamic> map; //更多信息

  Info({this.id, this.name, this.type, this.map});

  Info.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        type = map['type'],
        map = map['map'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'map': map,
      };
  Info clone() {
    Info tmp = new Info();
    tmp.id = id;
    tmp.name = name;
    tmp.type = type;
    tmp.map = new Map<String, dynamic>();
    map.keys.forEach((k) {
      tmp.map[k] = map[k].toString();
    });
    return tmp;
  }
}

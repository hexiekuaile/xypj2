//信息类
class Info {
  String id;
  String name; //名称
  String type; //类型
  Map<String, dynamic> map; //备注

  Info(this.id, this.name, this.type, this.map);

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
}

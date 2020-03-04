//实体类
class Entity {
  String id;
  Map<String, dynamic> map; //更多信息

  Entity({this.map});

  Entity.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        map = map['map'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'map': map,
      };
}

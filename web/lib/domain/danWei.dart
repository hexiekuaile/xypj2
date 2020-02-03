//单位类
class DanWei {
  final String id;
  final String xiaqu; //辖区
  final String name; //单位名称

  //({this.id, this.type, this.name, this.zccl, this.value});
  DanWei(this.id, this.xiaqu, this.name);

  DanWei.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        xiaqu = map['xiaqu'],
        name = map['name'];

  Map<String, dynamic> toJson() => {'id': id, 'type': xiaqu, 'name': name};
}

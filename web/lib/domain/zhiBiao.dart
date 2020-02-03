//评价指标类
class ZhiBiao {
  final String id;
  final String type; //指标分类
  final String name; //指标名称
  final String zccl; //需要的支撑材料
  final int value; //对应分值

  //Pjzb({this.id, this.type, this.name, this.zccl, this.value});
  ZhiBiao(this.id, this.type, this.name, this.zccl, this.value);

  ZhiBiao.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        type = map['type'],
        name = map['name'],
        zccl = map['zccl'],
        value = map['value'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'type': type, 'name': name, 'zccl': zccl, 'value': value};
}

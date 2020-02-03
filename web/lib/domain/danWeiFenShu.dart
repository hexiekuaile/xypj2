//单位类
import 'package:web/domain/danWei.dart';

//单位分数
class DanWeiFenShu {
  String id;
  DanWei danWei; //单位
  int qiyezhichaFenShu; //企业自查分数
  int xianjipinjiaFenShu; //县级评价分数
  int shijipinjiaFenShu; //市级评价分数
  String beiZhu; //备注

  //({this.id, this.type, this.name, this.zccl, this.value});
  DanWeiFenShu(this.id, this.danWei, this.qiyezhichaFenShu,
      this.xianjipinjiaFenShu, this.shijipinjiaFenShu, this.beiZhu);

  DanWeiFenShu.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        danWei = DanWei.fromJson(map['danWei']),
        qiyezhichaFenShu = map['qiyezichafenshu'],
        xianjipinjiaFenShu = map['xianjipinjiafenshu'],
        shijipinjiaFenShu = map['shijifuhefenshu'],
        beiZhu = map['dafenshuoming'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'danWei': danWei,
        'qiyezhichaFenShu': qiyezhichaFenShu,
        'xianjipinjiaFenShu': xianjipinjiaFenShu,
        'shijipinjiaFenShu': shijipinjiaFenShu,
        'beiZhu': beiZhu,
      };
}

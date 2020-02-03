//单位类
import 'package:web/domain/danWei.dart';
import 'package:web/domain/zhiBiao.dart';
//指标分数
class DanWeiZhiBiaoFenShu {
  final String id;
  final DanWei danWei; //单位
  final ZhiBiao zhiBiao; //指标
  final int qiyezhichaFenShu; //企业自查分数
  final int xianjipinjiaFenShu; //县级评价分数
  final int shijipinjiaFenShu; //市级评价分数
  final String beiZhu; //备注

  //({this.id, this.type, this.name, this.zccl, this.value});
  DanWeiZhiBiaoFenShu(this.id, this.danWei, this.zhiBiao, this.qiyezhichaFenShu,
      this.xianjipinjiaFenShu, this.shijipinjiaFenShu, this.beiZhu);

  DanWeiZhiBiaoFenShu.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        danWei = DanWei.fromJson(map['danWei']),
        zhiBiao = ZhiBiao.fromJson(map['pinjiazhibiao']),
        qiyezhichaFenShu = map['qiyezichafenshu'],
        xianjipinjiaFenShu = map['xianjipinjiafenshu'],
        shijipinjiaFenShu = map['shijifuhefenshu'],
        beiZhu = map['dafenshuoming'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'danWei': danWei,
        'zhiBiao': zhiBiao,
        'qiyezhichaFenShu': qiyezhichaFenShu,
        'xianjipinjiaFenShu': xianjipinjiaFenShu,
        'shijipinjiaFenShu': shijipinjiaFenShu,
        'beiZhu': beiZhu,
      };
}

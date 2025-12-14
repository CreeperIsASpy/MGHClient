import 'package:date_format/date_format.dart' as dtfmt;

String getReadableDate() {
  String origin = dtfmt.formatDate(DateTime.now(), [
    'yyyy',
    '年',
    'mm',
    '月',
    'dd',
    '日',
    ' ',
    '星期',
    'D',
  ]);
  origin = origin.replaceAll("星期Sun", "星期日");
  origin = origin.replaceAll("星期Mon", "星期一");
  origin = origin.replaceAll("星期Tue", "星期二");
  origin = origin.replaceAll("星期Wed", "星期三");
  origin = origin.replaceAll("星期Thu", "星期四");
  origin = origin.replaceAll("星期Fri", "星期五");
  origin = origin.replaceAll("星期Sat", "星期六");
  // date_format 有中文歧视，没招了。
  return origin;
}

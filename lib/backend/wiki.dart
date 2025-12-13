import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'dart:convert';

// 定义一个简单的模型类来存储分离后的数据
class WikiContent {
  final String? imageUrl;
  final String cleanedHtml;

  WikiContent({this.imageUrl, required this.cleanedHtml});
}

final wikiApiUrl = Uri(
  scheme: 'https',
  host: 'zh.minecraft.wiki',
  path: '/api.php',
  queryParameters: {
    'action': 'parse',
    'format': 'json',
    'page': 'Minecraft_Wiki',
  },
);
final wikiBaseUrl = Uri(scheme: 'https', host: 'zh.minecraft.wiki');

// 修改返回类型为 Future<WikiContent?>
Future<WikiContent?> fetchWikiData() async {
  try {
    var response = await http.get(wikiApiUrl);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var fullHtml = parse(jsonData['parse']['text']['*']);

      // 定位到特色条目区域
      var parent = fullHtml.querySelector(
        "div.mp-inline-sections > div.mp-left",
      );
      dom.Element? featuredArticleElement;

      if (parent != null && parent.children.length >= 5) {
        featuredArticleElement = parent.children[4];
        // 如果找到了元素，进行“剥离”处理
        return _processHtml(featuredArticleElement);
      }
      return null; // 或者返回一个表示“未找到”的 WikiContent
    } else {
      print("Response code != 200: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Fetch error: $e");
    return null;
  }
}

// 私有辅助函数：提取图片并清洗 HTML
WikiContent _processHtml(dom.Element element) {
  String? finalImageUrl;

  // 1. 寻找特色图片容器 (通常是 mp-featured-img)
  var imgContainer = element.querySelector('.mp-featured-img');

  if (imgContainer != null) {
    // 尝试提取 img 标签的 src
    var imgTag = imgContainer.querySelector('img');
    if (imgTag != null) {
      var src = imgTag.attributes['src'];
      if (src != null) {
        // 补全相对路径
        if (src.startsWith('/')) {
          finalImageUrl = "https://zh.minecraft.wiki$src";
        } else {
          finalImageUrl = src;
        }
      }
    }
    // 2. 关键：从 DOM 树中移除图片容器
    imgContainer.remove();
  }

  // 3. 返回结果
  return WikiContent(imageUrl: finalImageUrl, cleanedHtml: element.outerHtml);
}

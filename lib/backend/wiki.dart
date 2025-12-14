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

Future<WikiContent?> fetchWikiData() async {
  var response = await http.get(wikiApiUrl);
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    var fullHtml = parse(jsonData['parse']['text']['*']);

    // 定位到特色条目区域
    var parent = fullHtml.querySelector("div.mp-inline-sections > div.mp-left");
    dom.Element? featuredArticleElement;

    if (parent != null && parent.children.length >= 5) {
      featuredArticleElement = parent.children[4];
      // 剥离图片
      return _processHtml(featuredArticleElement);
    }
    return null;
  } else {
    throw Exception("Response code != 200: ${response.statusCode}");
  }
}

// 提取图片
WikiContent _processHtml(dom.Element element) {
  String? finalImageUrl;

  var imgContainer = element.querySelector('.mp-featured-img');

  if (imgContainer != null) {
    // 提取 src
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
    imgContainer.remove();
  }

  return WikiContent(imageUrl: finalImageUrl, cleanedHtml: element.outerHtml);
}

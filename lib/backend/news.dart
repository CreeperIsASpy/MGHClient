import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../widgets/mycard.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // 用于 kIsWeb

/* （引自新闻主页 API 文档）
GET https://news.bugjump.net/apis/versions/latest：
```
{
    "snapshot": {
        "version-type": "快照版",
        "intro": "收纳袋三行 削弱红石随机性 红石左路优先 数据包版本50",
        "version-image-link": "https://image.stapxs.cn/i/2024/08/21/24w34a-1170x500-1.jpg",
        "server-jar": "https://piston-data.mojang.com/v1/objects/ff16e26392a5ced7cfe52ffdc5461cd646b9b65d/server.jar",
        "translator": "最亮的信标",
        "official-link": "https://minecraft.net/article/minecraft-snapshot-24w34a",
        "wiki-link": "https://zh.minecraft.wiki/w/24w34a",
        "version-id": "24w34a",
        "title": "24w34a",
        "homepage-json-link": "https://news.bugjump.net/VersionDetail.json?ver=24w34a"
    },
    "release": {
        "version-type": "正式版",
        "intro": "增加了索西语与白俄罗斯语",
        "version-image-link": "https://image.stapxs.cn/i/2024/08/08/1.21.1_1170x500-1.jpg",
        "server-jar": "https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar",
        "translator": "最亮的信标",
        "official-link": "https://minecraft.net/article/minecraft-java-edition-1-21-1",
        "wiki-link": "https://zh.minecraft.wiki/w/Java版1.21.1",
        "version-id": "1.21.1",
        "title": "1.21.1",
        "homepage-json-link": "https://news.bugjump.net/VersionDetail.json?ver=1.21.1"
    }
}
```
（当最新版本为正式版时，不会返回快照版）。


*/

Uri getBaseUri() {
  if (kIsWeb) {
    final newsApiUrl = Uri.parse("/api-news/apis/versions/latest"); // 用代理绕 cors
    return newsApiUrl;
  } else {
    final newsApiUrl = Uri(
      scheme: 'https',
      host: 'news.bugjump.net',
      path: 'apis/versions/latest',
    );
    return newsApiUrl;
  }
}

Future<Map<String, dynamic>> fetchLatestNewsJson() async {
  var response = await http.get(getBaseUri());
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    return jsonData;
  } else {
    throw Exception("Response code != 200: ${response.statusCode}");
  }
}

Widget buildVersionInfoCard(Map<String, dynamic> data) {
  final release = data['release'];
  final snapshot = data['snapshot'];

  // 结构：[图标] --间距-- [标题/副标题列]
  Widget buildVersionItem({
    required String iconPath,
    required Map<String, dynamic> releaseObj,
  }) {
    Widget introObj;
    if (releaseObj['intro'] != null) {
      introObj = Text(
        releaseObj['intro'],
        style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.2),
      );
    } else {
      introObj = HtmlWidget(
        "请前往<a href='${releaseObj['wiki-link']}'>Minecraft Wiki</a>查看详细更新内容。",
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              releaseObj['version-image-link']!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) =>
                  const Text("图片加载失败", style: TextStyle(color: Colors.grey)),
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图标
              Image.asset(iconPath, width: 42, height: 42, fit: BoxFit.contain),
              const SizedBox(width: 16), // 图标与文字的间距
              // 右侧文字区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：类型 - 版本号
                    Text(
                      "最新${releaseObj['version-type']} - ${releaseObj['version-id']}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 第二行：简介
                    introObj,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. 构建子组件列表
  List<Widget> cardChildren = [];

  // --- 处理正式版 (Release) ---
  if (release != null) {
    cardChildren.add(
      buildVersionItem(
        iconPath: "assets/icons/release.png",
        releaseObj: release,
      ),
    );
  }

  // --- 处理快照版 (Snapshot) ---
  // 只有当 snapshot 字段存在且不为空时才渲染
  if (snapshot != null) {
    // 如果上面有正式版，中间加一个间距
    if (cardChildren.isNotEmpty) {
      cardChildren.add(const SizedBox(height: 16));
    }

    cardChildren.add(
      buildVersionItem(
        iconPath: "assets/icons/snapshot.png",
        releaseObj: snapshot,
      ),
    );
  }

  // 4. 返回 MyCard
  return MyCard(title: "最新版本", isCollapsible: true, children: cardChildren);
}

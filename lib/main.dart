import 'package:flutter/material.dart';
import 'widgets/mycard.dart';
import 'backend/wiki.dart'; // 确保这里能引用到上面修改后的 wiki.dart
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Card Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
        fontFamilyFallback: const [
          'LXGW-WenKai',
          'Microsoft YaHei',
          'PingFang SC',
          'Heiti SC',
          'sans-serif',
        ],
      ),
      home: const MainWindow(),
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  // 修改 Future 类型为 WikiContent?
  late Future<WikiContent?> _wikiFuture;

  @override
  void initState() {
    super.initState();
    _wikiFuture = fetchWikiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("杂志主页", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        elevation: 2,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const MyCard(
                    title: "Welcome Card",
                    children: [Text("Example welcome card (can't swap)")],
                  ),

                  FutureBuilder<WikiContent?>(
                    // 修改泛型
                    future: _wikiFuture,
                    builder: (context, snapshot) {
                      // case 1: 正在等待数据
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const MyCard(
                          title: "Wiki 测试",
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            Text(
                              "正在从后端加载数据...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        );
                      }

                      // case 2: 出错了
                      if (snapshot.hasError) {
                        return MyCard(
                          title: "Wiki 测试",
                          children: [
                            Text(
                              "加载失败: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _wikiFuture = fetchWikiData();
                                });
                              },
                              child: const Text("重试"),
                            ),
                          ],
                        );
                      }

                      // case 3: 成功获取数据
                      // 注意：fetchWikiData 现在可能返回 null (未找到或解析失败)
                      final wikiData = snapshot.data;

                      if (wikiData == null) {
                        return const MyCard(
                          title: "Wiki 测试",
                          children: [Text("未能获取到有效数据。")],
                        );
                      }

                      return MyCard(
                        title: "Wiki 测试",
                        isCollapsible: true,
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // A. 如果有图片，使用原生渲染
                                if (wikiData.imageUrl != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      wikiData.imageUrl!,
                                      width: double.infinity, // 强制占满宽度
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Text(
                                            "图片加载失败",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // B. 剩下的 HTML 文本
                                HtmlWidget(
                                  wikiData.cleanedHtml,
                                  baseUrl:
                                      wikiApiUrl, // 注意：这里可能需要传 Uri 或 String，看 flutter_widget_from_html 版本，建议 Uri.parse("https://zh.minecraft.wiki/") 更稳
                                  // 简单的样式修正，不需要复杂的 Flex 处理了
                                  customStylesBuilder: (element) {
                                    // 确保主容器是 block，防止任何意外的 flex
                                    if (element.classes.contains(
                                      'mp-section',
                                    )) {
                                      return {
                                        'display': 'block',
                                        'width': '100%',
                                        'height': 'auto',
                                      };
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

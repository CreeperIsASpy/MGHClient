import 'package:flutter/material.dart';
import 'widgets/mycard.dart';
import 'backend/wiki.dart';
import 'backend/news.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'backend/utils.dart' as utils;

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
  late Future<WikiContent?> _wikiFuture;
  late Future<Map<String, dynamic>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _wikiFuture = fetchWikiData();
    _newsFuture = fetchLatestNewsJson();
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
        fit: StackFit.expand,
        children: [
          // 1. 背景图
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),

          // 2. 滚动内容
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  MyCard(
                    title: "欢迎使用杂志主页客户端",
                    children: [Text("今天是${utils.getReadableDate()}，祝您有美好的一天！")],
                  ),

                  FutureBuilder<WikiContent?>(
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
                      // 注意：fetchWikiData -> nullable
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
                                if (wikiData.imageUrl != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      wikiData.imageUrl!,
                                      //  width: double.infinity,
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

                                HtmlWidget(
                                  wikiData.cleanedHtml,
                                  baseUrl: wikiApiUrl, // baseUrl 解析相对链接
                                  customStylesBuilder: (element) {
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
                  FutureBuilder<Map<String, dynamic>>(
                    future: _newsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const MyCard(
                          title: "新闻主页 API",
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

                      if (snapshot.hasError) {
                        return MyCard(
                          title: "新闻主页 API",
                          children: [
                            Text(
                              "加载失败: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _newsFuture = fetchLatestNewsJson();
                                });
                              },
                              child: const Text("重试"),
                            ),
                          ],
                        );
                      }

                      final newsData = snapshot.data;
                      if (newsData == null) {
                        return const Center(
                          child: MyCard(
                            title: "新闻主页 API",
                            children: [Text("出错。")],
                          ),
                        );
                      }

                      return buildVersionInfoCard(newsData);
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

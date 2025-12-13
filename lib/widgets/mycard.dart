import 'package:flutter/material.dart';

class MyCard extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool isCollapsible;

  const MyCard({
    super.key,
    required this.title,
    required this.children,
    this.isCollapsible = false,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  // 不依赖 context 的初始化放在这里，依赖 context 的逻辑放在 build 里

  bool _isHovering = false;
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final mainThemeColor = colorScheme.primary;
    final titleColorNormal =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;

    final currentColor = _isHovering ? mainThemeColor : titleColorNormal;
    final currentBg = _isHovering
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.8);

    final currentShadow = _isHovering
        ? [
            BoxShadow(
              color: mainThemeColor.withValues(alpha: 0.4),
              offset: const Offset(0.5, 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0.5, 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ];

    return Container(
      width: _calculateWidth(context),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: currentBg,
            borderRadius: BorderRadius.circular(6),
            boxShadow: currentShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeader(currentColor), _buildCollapsibleBody()],
          ),
        ),
      ),
    );
  }

  /// 计算宽度逻辑
  double _calculateWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.8;
  }

  /// 构建标题栏
  Widget _buildHeader(Color currentColor) {
    return GestureDetector(
      onTap: widget.isCollapsible
          ? () => setState(() => _isCollapsed = !_isCollapsed)
          : null,
      behavior: HitTestBehavior.opaque, // 扩大点击区域
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: currentColor,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              fontFamilyFallback: Theme.of(
                context,
              ).textTheme.bodyMedium?.fontFamilyFallback,
            ),
            child: Text(widget.title),
          ),
          if (widget.isCollapsible)
            AnimatedRotation(
              turns: _isCollapsed ? 0.25 : 0.75,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: currentColor,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建可折叠的内容区域
  Widget _buildCollapsibleBody() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutQuad,
      alignment: Alignment.topCenter,
      child: SizedBox(
        // 这里用 height 控制显隐，配合 AnimatedSize 自动做高度动画
        height: _isCollapsed ? 0 : null,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  StickyTabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(StickyTabDelegate oldDelegate) => false;
}
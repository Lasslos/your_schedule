import 'package:flutter/material.dart';

class Collapsable extends StatefulWidget {
  const Collapsable({
    required this.child,
    required this.isExpanded,
    super.key,
  });

  final Widget child;
  final bool isExpanded;

  @override
  State<Collapsable> createState() => _CollapsableState();
}

class _CollapsableState extends State<Collapsable>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeInOut,
    );
  }

  void runExpandCheck() {
    if (widget.isExpanded) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant Collapsable oldWidget) {
    super.didUpdateWidget(oldWidget);
    runExpandCheck();
  }

  @override
  void dispose() {
    super.dispose();
    expandController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}

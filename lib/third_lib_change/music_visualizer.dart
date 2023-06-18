library music_visualizer;

import 'package:flutter/material.dart';

class MusicVisualizer extends StatelessWidget {
  final int? duration;
  final int? barCount;
  final Color? color;
  final Curve? curve;

  const MusicVisualizer({
    required this.duration,
    required this.barCount,
    required this.color,
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        barCount!,
        (index) => VisualComponent(
          curve: curve!,
          duration: duration,
          color: color,
          index: index,
        ),
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  final int? duration;
  final Color? color;
  final Curve? curve;
  final int index;

  const VisualComponent({
    required this.duration,
    required this.color,
    required this.curve,
    required this.index,
  });

  @override
  State<VisualComponent> createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  void dispose() {
    animation!.removeListener(() {});
    animation!.removeStatusListener((status) {});
    animationController!.dispose();
    super.dispose();
  }

  void animate() {
    animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration!), vsync: this);
    final curvedAnimation =
        CurvedAnimation(parent: animationController!, curve: widget.curve!);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation)
      ..addListener(() {
        update();
      });
    animationController!.repeat(reverse: true);
  }

  void update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.18,
      // height: (animation!.value + widget.index) * 10.0 + 2.0,
      height: (10.0 * animation!.value + 2.0 + widget.index * 5) % 12.0,
      decoration: BoxDecoration(
          color: widget.color, borderRadius: BorderRadius.circular(10.0)),
    );
  }
}

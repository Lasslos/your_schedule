///TODO: This is not working at the time, dont expect it to work any time soon.
/*import 'package:flutter/material.dart';

double? _onScaleStartSize;

class PinchToZoom extends StatelessWidget {
  PinchToZoom.builder({
    required this.builder,
    this.initialSize = 600,
    this.minimumSize = 300,
    this.maximumSize = 1200,
    super.key,
  })  : assert(
          initialSize >= (minimumSize ?? initialSize),
          'initialSize must be greater than minimumSize',
        ),
        assert(
          initialSize <= (maximumSize ?? initialSize),
          'initialSize must be less than maximumSize',
        ),
        assert(
          (minimumSize ?? initialSize) <= (maximumSize ?? initialSize),
          'minimumSize must be less than maximumSize',
        );

  final double initialSize;
  final double? minimumSize;
  final double? maximumSize;
  final Widget Function(BuildContext context, double height) builder;

  final GlobalKey<_ChangeableHeightWidgetState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (ScaleStartDetails details) {
        _onScaleStartSize = _key.currentState!.size;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        var newSize = _onScaleStartSize! * details.scale;
        if (minimumSize != null && newSize < minimumSize!) {
          newSize = minimumSize!;
        }
        if (maximumSize != null && newSize > maximumSize!) {
          newSize = maximumSize!;
        }
        _key.currentState!.size = newSize;
      },
      onScaleEnd: (_) {
        _onScaleStartSize = null;
      },
      child: _ChangeableHeightWidget(
        key: _key,
        initialHeight: initialSize,
        builder: builder,
      ),
    );
  }
}

class _ChangeableHeightWidget extends StatefulWidget {
  const _ChangeableHeightWidget({
    required this.initialHeight,
    required this.builder,
    super.key,
  });

  final double initialHeight;
  final Widget Function(BuildContext context, double height) builder;

  @override
  State<_ChangeableHeightWidget> createState() =>
      _ChangeableHeightWidgetState();
}

class _ChangeableHeightWidgetState extends State<_ChangeableHeightWidget> {
  late double _size;

  double get size => _size;

  set size(double value) {
    setState(() {
      _size = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _size = widget.initialHeight;
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, size);
}
*/
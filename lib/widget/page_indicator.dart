import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final double page;
  final int pageLength;

  const PageIndicator(
      {Key key, @required this.page, @required this.pageLength})
      : assert(page != null),
        assert(pageLength != null || pageLength > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageLength, (index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            radius: 6.0,
            backgroundColor: Color.lerp(
              Colors.white30,
              Colors.white,
              (1 - (index - page??0.0).abs().clamp(0.0, 1.0)),
            ),
          ),
        );
      }),
    );
  }
}

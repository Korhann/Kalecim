import 'package:flutter/cupertino.dart';
import 'package:kiralik_kaleci/responsive/responsivedesign.dart';

class PageContainerDesktop extends StatelessWidget {
  final Widget child;

  const PageContainerDesktop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveDesign.isDesktop(context) ? 1300.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

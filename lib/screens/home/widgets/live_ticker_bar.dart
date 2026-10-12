import 'package:flutter/material.dart';
import '../../../core/widgets/ticker_marquee.dart';

class LiveTickerBar extends StatelessWidget {
  final List<String> notices;

  const LiveTickerBar({
    super.key,
    required this.notices,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: TickerMarquee(notices: notices),
    );
  }
}

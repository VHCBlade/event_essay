import 'package:event_essay/src/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_bloc/event_bloc.dart';

class ScrollbarProvider extends StatefulWidget {
  final Widget Function(ScrollController controller, BuildContext context)
      builder;
  final bool isAlwaysShown;
  final double? thickness;

  const ScrollbarProvider(
      {Key? key,
      required this.builder,
      this.isAlwaysShown = false,
      this.thickness})
      : super(key: key);

  @override
  State<ScrollbarProvider> createState() => _ScrollbarProviderState();
}

class _ScrollbarProviderState extends State<ScrollbarProvider> {
  late final ScrollController controller;
  late final BlocEventChannel channel;

  bool _updating = false;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();

    /// Assume that there will always be a Provider Event Channel, probably fix
    /// this later.
    channel = BlocEventChannel(context.read<BlocEventChannel>());
    channel.addEventListener(EssayEvent.updateScroll.event, (event, val) {
      event.propagate = false;
      if (_updating) {
        return;
      }
      _updating = true;
      // This forces the controller to update.
      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        if (!isDisposed) {
          controller.position.didUpdateScrollPositionBy(-0.1);
          _updating = false;
        }
      });
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
    controller.dispose();
    channel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
        value: channel,
        child: Scrollbar(
            thumbVisibility: true,
            controller: controller,
            thickness: widget.thickness,
            child: widget.builder(controller, context)));
  }
}

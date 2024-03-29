import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../event_essay.dart';

const assetImagePath = 'assets/img/';
const assetTextPath = ['assets', 'text'];

class EssayLayout extends StatelessWidget {
  final Widget child;

  /// Correctly layouts the child inside a SignleChildScrollView for an Essay.
  const EssayLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        constraints: const BoxConstraints(minWidth: double.infinity),
      ),
      Center(child: child)
    ]);
  }
}

class EssayScroll extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;
  final BoxConstraints constraints;

  const EssayScroll({
    Key? key,
    required this.child,
    this.alignment = Alignment.center,
    this.constraints = const BoxConstraints(maxWidth: 1200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollbarProvider(
      isAlwaysShown: true,
      builder: (controller, _) => Align(
        alignment: alignment,
        child: SingleChildScrollView(
          controller: controller,
          child: EssayLayout(
            child: Container(
                constraints: constraints,
                padding: const EdgeInsets.all(30),
                child: child),
          ),
        ),
      ),
    );
  }
}

/// Requires that you place your images in 'assets/image/' and your markdown in 'assets/text/'
///
/// Requires that you place a [TextRepository] somewhere in the [BuildContext]
class EssayScreen extends StatefulWidget {
  final List<String> path;
  final List<Widget> leading;
  final List<Widget> trailing;

  /// Builds the essay screen with the [path] used to take the files from assets.
  ///
  /// [leading] is placed in a row before the content loaded in the manifest.
  /// [trailing] is placed in a row after the content loaded in the manifest.
  const EssayScreen({
    Key? key,
    required this.path,
    this.trailing = const [],
    this.leading = const [],
  }) : super(key: key);

  @override
  State<EssayScreen> createState() => _EssayScreenState();
}

class _EssayScreenState extends State<EssayScreen> {
  late final BlocEventChannel eventChannel;

  List<String> get textPath => <String>[...assetTextPath, ...widget.path];

  @override
  void didUpdateWidget(EssayScreen screen) {
    super.didUpdateWidget(screen);

    eventChannel.fireEvent(EssayEvent.updateEssayPath.event, textPath);
  }

  @override
  Widget build(BuildContext context) {
    return EssayScroll(
      child: BlocProvider(
        create: (context, channel) {
          final repo = context.read<TextRepository>();
          final bloc = PageTextBloc(
              parentChannel: channel, repository: repo, path: textPath);

          eventChannel = bloc.eventChannel;
          bloc.eventChannel
              .fireEvent<void>(EssayEvent.loadTextFile.event, null);

          bloc.blocUpdated.add(() => bloc.eventChannel
              .fireEvent<void>(EssayEvent.updateScroll.event, null));
          return bloc;
        },
        child: EssayContent(
          imagePath: "$assetImagePath${widget.path.reduce((a, b) => '$a/$b')}",
          trailing: widget.trailing,
          leading: widget.leading,
        ),
      ),
    );
  }
}

class EssayContent extends StatelessWidget {
  final String imagePath;
  final List<Widget> trailing;
  final List<Widget> leading;

  /// The Actual Content of the essay
  const EssayContent(
      {Key? key,
      required this.imagePath,
      required this.trailing,
      required this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<BlocNotifier<PageTextBloc>>().bloc;

    if (!bloc.loaded) {
      return const CircularProgressIndicator();
    }

    if (bloc.value.isEmpty) {
      return const EssayTitleText(text: "Ooops!!! Failed to load this page!");
    }

    return LoadedEssayContent(
      value: bloc.value,
      leading: leading,
      trailing: trailing,
    );
  }
}

class LoadedEssayContent extends StatelessWidget {
  final String value;
  final List<Widget> leading;
  final List<Widget> trailing;

  const LoadedEssayContent({
    super.key,
    required this.value,
    required this.leading,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final page = <Widget>[];

    page.addAll(leading);
    page.add(Markdown(
      selectable: true,
      data: value,
      onTapLink: (text, href, title) =>
          context.fireEvent<String>(EssayEvent.url.event, href!),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        a: Theme.of(context).textTheme.titleMedium?.copyWith(
            decoration: TextDecoration.underline,
            color: Theme.of(context).primaryColor),
        p: Theme.of(context).textTheme.titleMedium,
      ),
    ));
    page.addAll(trailing);

    return Wrap(runSpacing: 10, spacing: 10, children: page);
  }
}

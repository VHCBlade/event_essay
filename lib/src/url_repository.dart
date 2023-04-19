import 'package:event_bloc/event_bloc.dart';
import 'package:event_essay/event_essay.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherRepository extends Repository {
  final bool launchExternal;

  UrlLauncherRepository({this.launchExternal = true});

  /// Generates the listener map that this [Repository] will add to the
  @override
  List<BlocEventListener> generateListeners(BlocEventChannel eventChannel) => [
        eventChannel.addEventListener<String>(
            EssayEvent.url.event, (_, val) => launchTarget(val)),
      ];

  void launchTarget(String target) {
    launchUrl(Uri.parse(prefixIfNecessary(target)),
        mode: launchExternal
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault);
  }

  String prefixIfNecessary(String target) {
    RegExp regExp = RegExp(r'^.+:\/\/.+');
    if (regExp.hasMatch(target)) {
      return target;
    }

    return "https://$target";
  }
}

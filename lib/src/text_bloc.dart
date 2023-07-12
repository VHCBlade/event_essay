import 'package:event_essay/event_essay.dart';
import 'package:event_bloc/event_bloc.dart';

class PageTextBloc extends Bloc {
  final TextRepository repository;
  final List<String> path;

  bool loaded = false;
  bool _loading = false;
  String value = "";

  String get stringPath => path.reduce((a, b) => "$a/$b");

  PageTextBloc(
      {super.parentChannel, required this.repository, required this.path}) {
    eventChannel.addEventListener(
        EssayEvent.loadTextFile.event, (_, val) => _retrieveTextFiles());
    eventChannel.addEventListener(
        EssayEvent.updateEssayPath.event, (_, val) => _updateEssayPath(val));
  }

  void _updateEssayPath(List<String> newPath) {
    _loading = false;
    path
      ..clear()
      ..addAll(newPath);
    _retrieveTextFiles();
  }

  void _retrieveTextFiles() async {
    if (_loading) {
      return;
    }
    final currentPath = [...path];

    value = await repository.loadText(path);
    if (currentPath.join('/') != path.join('/')) {
      return;
    }

    _loading = false;
    loaded = true;
    updateBloc();
    return;
  }
}

import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/services.dart';

abstract class TextRepository extends Repository {
  Future<String> loadText(List<String> path);
}

class DefaultTextRepository extends TextRepository {
  final String errorResult;

  DefaultTextRepository({
    this.errorResult = '# Sorry, we were unable to find the provided text...',
  });

  /// Loads all text files from the given path.
  @override
  Future<String> loadText(List<String> path) async {
    assert(path.isNotEmpty);

    final fullPath = path.reduce((a, b) => "$a/$b");
    final mdFile = "$fullPath.md";

    return await rootBundle
        .loadString(mdFile)
        .onError((error, stackTrace) => errorResult);
  }

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [];
}

class DelayedDefaultTextRepository extends TextRepository {
  final DefaultTextRepository defaultRepository = DefaultTextRepository();

  @override
  Future<String> loadText(List<String> path) async {
    await Future.delayed(const Duration(seconds: 1));
    return await defaultRepository.loadText(path);
  }

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [];
}

import 'package:event_bloc/event_bloc.dart';

enum EssayEvent<T> {
  updateScroll<void>(),
  loadTextFile<void>(),
  updateEssayPath<List<String>>(),
  url<String>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<T> debounceTransformer<T>(Duration duration) {
  return (events, mapper) => events
      .debounce(duration, leading: true, trailing: true)
      .switchMap(mapper);
}

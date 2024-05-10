part of 'regions_list.bloc.dart';

sealed class RegionsListEvent extends Equatable {
  const RegionsListEvent();

  @override
  List<Object?> get props => [];
}

final class FetchRegions extends RegionsListEvent {
  const FetchRegions();
}

final class RefreshRegions extends RegionsListEvent {
  const RefreshRegions(this.args);

  final FindRegionsArgs? args;

  @override
  List<Object?> get props => [args];
}

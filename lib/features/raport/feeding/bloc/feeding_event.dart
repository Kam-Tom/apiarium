part of 'feeding_bloc.dart';

sealed class FeedingEvent extends Equatable {
  const FeedingEvent();

  @override
  List<Object> get props => [];
}
final class LoadFeedingData extends FeedingEvent {
  const LoadFeedingData();
}

final class SaveFeedingRaport extends FeedingEvent {
  const SaveFeedingRaport();
}
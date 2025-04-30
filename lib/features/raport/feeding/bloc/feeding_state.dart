part of 'feeding_bloc.dart';

sealed class FeedingState extends Equatable {
  const FeedingState();
  
  @override
  List<Object> get props => [];
}

final class FeedingInitial extends FeedingState {}

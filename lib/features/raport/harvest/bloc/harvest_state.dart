part of 'harvest_bloc.dart';

sealed class HarvestState extends Equatable {
  const HarvestState();
  
  @override
  List<Object> get props => [];
}

final class HarvestInitial extends HarvestState {}

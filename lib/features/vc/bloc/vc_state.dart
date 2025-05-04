part of 'vc_bloc.dart';

enum VcModelStatus { initial, checking, notSet, downloading, ready, error, disposed }

class VcState extends Equatable {
  final VcModelStatus status;
  final String currentLanguage;
  final Map<String, String>? selectedModel;
  final String? errorMessage;
  final String? downloadStatus;
  final bool wasDownloading;
  
  const VcState({
    this.status = VcModelStatus.initial,
    this.currentLanguage = '',
    this.selectedModel,
    this.errorMessage,
    this.downloadStatus,
    this.wasDownloading = false,
  });
  
  VcState copyWith({
    VcModelStatus? status,
    String? currentLanguage,
    Map<String, String>? selectedModel,
    String? errorMessage,
    String? downloadStatus,
    bool? wasDownloading,
  }) {
    return VcState(
      status: status ?? this.status,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      selectedModel: selectedModel ?? this.selectedModel,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      wasDownloading: wasDownloading ?? this.wasDownloading,
    );
  }
  
  @override
  List<Object?> get props => [status, currentLanguage, selectedModel, errorMessage, downloadStatus, wasDownloading];
}

final class VcInitial extends VcState {}

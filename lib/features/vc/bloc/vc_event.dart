part of 'vc_bloc.dart';

sealed class VcEvent extends Equatable {
  const VcEvent();

  @override
  List<Object> get props => [];
}

class CheckVcModelStatus extends VcEvent {}

class DownloadVcModel extends VcEvent {
  final Map<String, String> modelInfo;
  final Function(String status)? onProgress;
  
  const DownloadVcModel({
    required this.modelInfo,
    this.onProgress,
  });
  
  @override
  List<Object> get props => [modelInfo];
}

class SetVcLanguage extends VcEvent {
  final String language;
  
  const SetVcLanguage(this.language);
  
  @override
  List<Object> get props => [language];
}

class CancelDownload extends VcEvent {}

class DisposeVcService extends VcEvent {}

enum ReportType {
  inspection;
  
  String get name {
    switch (this) {
      case ReportType.inspection: return 'inspection';
    }
  }
  
  static ReportType fromName(String name) {
    switch (name.toLowerCase()) {
      case 'inspection': return ReportType.inspection;
      default: return ReportType.inspection;
    }
  }
}

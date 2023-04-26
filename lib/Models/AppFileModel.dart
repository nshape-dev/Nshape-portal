// ignore_for_file: public_member_api_docs, sort_constructors_first
enum AppFileType { image, video }

class AppFileModel {
  var baseURL = "";
  var name = "";
  var isUploaded = false;
  var currentUploadPrecentage = 0.0;
  AppFileType fileType = AppFileType.image;
  var index = 0;
  AppFileModel({
    required this.baseURL,
    required this.name,
    required this.isUploaded,
    required this.currentUploadPrecentage,
    required this.fileType,
    required this.index,
  });

  
}

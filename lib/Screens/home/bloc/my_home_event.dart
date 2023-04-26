// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_home_bloc.dart';

@immutable
abstract class MyHomeEvent {}

class ClearCachedDataForHome extends MyHomeEvent {}

class PhoneValueChangedForHome extends MyHomeEvent {
  final String phoneValue;
  PhoneValueChangedForHome({
    required this.phoneValue,
  });
}

class UserPressedLogin extends MyHomeEvent {
  final String phoneNumber;
  final String password;

  UserPressedLogin(this.phoneNumber, this.password);
}

class UploadTrasFiles extends MyHomeEvent {
  List<AppFileModel> images;
  String token;
  UploadTrasFiles({
    required this.images,
    required this.token,
  });
}

class UploadReelFiles extends MyHomeEvent {
  List<AppFileModel> reels;
  String token;
  UploadReelFiles({
    required this.reels,
    required this.token,
  });
}

class UploadFileUpdate extends MyHomeEvent {
  AppFileModel file;
  UploadFileUpdate({
    required this.file,
  });
}

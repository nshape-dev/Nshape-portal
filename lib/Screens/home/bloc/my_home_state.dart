// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_home_bloc.dart';

@immutable
abstract class MyHomeState {}

class MyHomeStateError extends MyHomeState {}

class MyHomeInitial extends MyHomeState {
  final bool isUserLoggedIn;

  MyHomeInitial(this.isUserLoggedIn);
}

class HomaChangePasswordValue extends MyHomeState {
  final String newValue;

  HomaChangePasswordValue({
    required this.newValue,
  });
}

class UserLoggedIn extends MyHomeState {
  final String token;

  UserLoggedIn(this.token);

}

class UploadingFileUpdateState extends MyHomeState {
  final AppFileModel file;

  UploadingFileUpdateState(this.file);

}

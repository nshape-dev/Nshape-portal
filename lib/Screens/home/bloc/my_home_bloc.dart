import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nshape_portal/Screens/home/bloc/my_home_repo.dart';

import '../../../Models/AppFileModel.dart';

part 'my_home_event.dart';
part 'my_home_state.dart';

class MyHomeBloc extends Bloc<MyHomeEvent, MyHomeState> {
  final MyHomeRepo repo = MyHomeRepo();
  MyHomeBloc() : super(MyHomeInitial(false)) {
    on<MyHomeEvent>(_mapMyHomeEventToState);
    on<PhoneValueChangedForHome>(_mapPhoneValueChangedToState);
    on<UserPressedLogin>(_mapLoginEventToState);
    on<UploadTrasFiles>(_mapUploadTrasFilesToState);
    on<UploadFileUpdate>(_mapUploadFileUpdateToState);
    on<UploadReelFiles>(_mapUploadReelsFilesToState);
  }

  void _mapMyHomeEventToState(MyHomeEvent event, Emitter<MyHomeState> state) {}
  void _mapPhoneValueChangedToState(
      PhoneValueChangedForHome event, Emitter<MyHomeState> state) {
    emit(HomaChangePasswordValue(
        newValue: "Nshape${event.phoneValue.substring(8)}"));
  }

  void _mapLoginEventToState(
      UserPressedLogin event, Emitter<MyHomeState> state) async {
    try {
      final String token =
          await repo.loginUser(event.phoneNumber, event.password);
      emit(UserLoggedIn(token));
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(MyHomeStateError());
    }
  }

  void _mapUploadTrasFilesToState(
      UploadTrasFiles event, Emitter<MyHomeState> emit) async {
    var index = 0;

    uploadProgress(AppFileModel element, int precentage, int total) {
      element.currentUploadPrecentage = precentage.toDouble();
      if (precentage == total) {
        element.isUploaded = true;
      }
      print("file: ${element.name} , Precent: $precentage");

      add(UploadFileUpdate(file: element));
    }

    for (var index = 0; index < event.images.length; ++index) {
        repo.uploadImageFile(event.images[index], event.token, uploadProgress);
    }

  }

  void _mapUploadReelsFilesToState(
      UploadReelFiles event, Emitter<MyHomeState> emit) async {
    var index = 0;

    uploadProgress(AppFileModel element, int precentage, int total) {
      element.currentUploadPrecentage = precentage.toDouble();
      if (precentage == total) {
        element.isUploaded = true;
      }
      print("file: ${element.name} , Precent: $precentage");

      add(UploadFileUpdate(file: element));
    }

    for (var index = 0; index < event.reels.length; ++index) {
        repo.uploadVideoFile(event.reels[index], event.token, uploadProgress);
    }

  }

  FutureOr<void> _mapUploadFileUpdateToState(
      UploadFileUpdate event, Emitter<MyHomeState> emit) {
    emit(UploadingFileUpdateState(event.file));
  }
}

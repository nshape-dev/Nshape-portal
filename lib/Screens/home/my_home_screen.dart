import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nshape_portal/Models/AppFileModel.dart';
import 'package:nshape_portal/Screens/home/bloc/my_home_bloc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isLoggedIn = false;
  String LoggedInUser = "";
  String token = "";
  String userName = "";
  String password = "";
  var passwordTextController = new TextEditingController();
  FilePickerResult? selectedFilesResult;
  List<AppFileModel> images = <AppFileModel>[];
  List<AppFileModel> reels = <AppFileModel>[];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MyHomeBloc(),
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Column(
              children: [
                Expanded(flex: 1, child: buildLoginView()),
                Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: buildTransformationsTable()),
                        Expanded(flex: 1, child: buildReelsTable()),
                      ],
                    ))
              ],
            )));
  }

  Future<void> openFilesBrowser() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'mp4', 'png', 'jpeg'],
    );
    if (result != null) {
      List<AppFileModel> tempImages = <AppFileModel>[];
      List<AppFileModel> tempReels = <AppFileModel>[];
      for (var file in result.files) {
        AppFileType fileType = AppFileType.image;
        if (file.extension?.contains("mp4") ?? false) {
          AppFileModel newFile = AppFileModel(
              baseURL: file.path ?? "",
              name: file.name,
              isUploaded: false,
              currentUploadPrecentage: 0,
              fileType: AppFileType.video,
              index: tempReels.length);
          tempReels.add(newFile);
        } else {
          AppFileModel newFile = AppFileModel(
              baseURL: file.path ?? "",
              name: file.name,
              isUploaded: false,
              currentUploadPrecentage: 0,
              fileType: fileType,
              index: tempImages.length);
          tempImages.add(newFile);
        }
      }

      setState(() {
        selectedFilesResult = result;
        images = tempImages;
        reels = tempReels;
      });
    }
    print(result);
  }

  Widget buildLoginView() {
    return BlocBuilder<MyHomeBloc, MyHomeState>(
      buildWhen: (previous, current) =>
          current is HomaChangePasswordValue ||
          current is MyHomeInitial ||
          current is UserLoggedIn,
      builder: (context, state) {
        if (state is HomaChangePasswordValue) {
          passwordTextController.text = (state).newValue;
        } else if (state is UserLoggedIn) {
          isLoggedIn = true;
          LoggedInUser = userName;
          token = state.token;
        }

        return Container(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: "Coach User Name",
                      hintText: "Enter Coach User Name"),
                  onChanged: (text) {
                    userName = text;
                    if (text.length == 11) {
                      // Update Password
                      context
                          .read<MyHomeBloc>()
                          .add(PhoneValueChangedForHome(phoneValue: text));
                      // setState(() {
                      //   password = "Nshape${text.substring(8)}";
                      //   passwordTextController.text = password;
                      // });
                    }
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: "Coach Password",
                      hintText: "Enter Coach Password"),
                  controller: passwordTextController,
                  onChanged: (text) {
                    password = text;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<MyHomeBloc>()
                            .add(UserPressedLogin(userName, password));
                      },
                      child: const Text("Login"),
                    ),
                    buildLoginStatus()
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        openFilesBrowser();
                      },
                      child: const Text("Browse")))
            ],
          ),
        );
      },
    );
  }

  Widget buildLoginStatus() {
    if (isLoggedIn) {
      return Text("Logged as: $LoggedInUser");
    } else {
      return Text("Status: Not logged in");
    }
  }

  Widget buildTransformationsTable() {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                const Text("Transformations"),
                const SizedBox(width: 20),
                BlocBuilder<MyHomeBloc, MyHomeState>(
                  builder: (context, state) {
                    return TextButton(
                        onPressed: () {
                          context.read<MyHomeBloc>().add(
                              UploadTrasFiles(images: images, token: token));
                        },
                        child: const Text("Upload"));
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: BlocBuilder<MyHomeBloc, MyHomeState>(
                builder: (context, state) {
                  if (state is UploadingFileUpdateState &&
                      state.file.fileType == AppFileType.image) {
                    images[state.file.index] = state.file;
                  }
                  return Table(
                    border: TableBorder.all(
                        color: Colors.blueGrey,
                        style: BorderStyle.solid,
                        width: 1.0),
                    children: buildTrasformationsTableRows().toList(),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  List<TableRow> buildTrasformationsTableRows() {
    List<TableRow> rows = <TableRow>[];

    var header = TableRow(children: [
      TableCell(
          child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          "Image Name ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          "Uploaded",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          "Precentage",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
    ]);

    rows.add(header);
    for (var index = 0; index < images.length; ++index) {
      AppFileModel file = images[index];
      rows.add(TableRow(children: [
        TableCell(
            child: Container(
                padding: const EdgeInsets.all(8), child: Text(file.name))),
        BlocBuilder<MyHomeBloc, MyHomeState>(
          builder: (context, state) {
            String text = file.isUploaded ? "Uploaded" : "Not Yet";
            TextStyle style =
                TextStyle(color: file.isUploaded ? Colors.green : Colors.grey);
            return TableCell(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      text,
                      style: style,
                    )));
          },
        ),
        TableCell(
            child: Container(
                padding: const EdgeInsets.all(8),
                child: Text("${file.currentUploadPrecentage}%"))),
      ]));
    }

    return rows;
  }

  Widget buildIsUploadedText(int fileIndex) {
    return BlocBuilder<MyHomeBloc, MyHomeState>(builder: (context, state) {
      if (state is HomaChangePasswordValue && fileIndex == 3) {
        return Text("Not Yet 3");
      } else if (state is HomaChangePasswordValue && fileIndex == 2) {
        return Text("Not Yet 2");
      } else if (state is UserLoggedIn && fileIndex == 3) {
        return Text("Uploaded");
      } else {
        return Text("Not Yet");
      }
    });
  }

  Widget buildReelsTable() {
    return Container(
      padding: EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                const Text("Reels"),
                const SizedBox(width: 20),
                BlocBuilder<MyHomeBloc, MyHomeState>(
                  builder: (context, state) {
                    return TextButton(
                        onPressed: () {
                          context
                              .read<MyHomeBloc>()
                              .add(UploadReelFiles(reels: reels, token: token));
                        },
                        child: const Text("Upload"));
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: BlocBuilder<MyHomeBloc, MyHomeState>(
                builder: (context, state) {
                  if (state is UploadingFileUpdateState &&
                      state.file.fileType == AppFileType.video) {
                    reels[state.file.index] = state.file;
                  }
                  return Table(
                    border: TableBorder.all(
                        color: Colors.blueGrey,
                        style: BorderStyle.solid,
                        width: 1.0),
                    children: buildReelsTableRows().toList(),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  List<TableRow> buildReelsTableRows() {
    List<TableRow> rows = <TableRow>[];

    var header = TableRow(children: [
      TableCell(
          child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          "Video Name ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          "Uploaded",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          "Precentage",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
    ]);

    rows.add(header);
    for (var index = 0; index < reels.length; ++index) {
      AppFileModel file = reels[index];
      rows.add(TableRow(children: [
        TableCell(
            child: Container(
                padding: const EdgeInsets.all(8), child: Text(file.name))),
        BlocBuilder<MyHomeBloc, MyHomeState>(
          builder: (context, state) {
            String text = file.isUploaded ? "Uploaded" : "Not Yet";
            TextStyle style =
                TextStyle(color: file.isUploaded ? Colors.green : Colors.grey);
            return TableCell(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      text,
                      style: style,
                    )));
          },
        ),
        TableCell(
            child: Container(
                padding: const EdgeInsets.all(8),
                child: Text("${file.currentUploadPrecentage}%"))),
      ]));
    }

    return rows;
  }
}

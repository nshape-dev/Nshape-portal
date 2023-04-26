import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:nshape_portal/Models/AppFileModel.dart';

class MyHomeRepo {
  MyHomeRepo(
      {http.Client? httpClient,
      this.baseUrl = "34.79.204.21:8080" //"http://104.155.64.11:8080/api",
      })
      : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final Client _httpClient;

  // let Transformation_URI = "/profile/coach/add-transformation"
  //   let Reels_URI = "/profile/coach/add-reel"

  Future<String> loginUser(String uName, String password) async {
    final loginUri = Uri.http(baseUrl, "api/user/login");
    Map<String, String> headers = {
      'Content-Type': 'application/json'
    }; //'authorization':'Basic c3R1ZHlkb3RlOnN0dWR5ZG90ZTEyMw=='};
    final body = jsonEncode({
      "phoneNumber": ("+2$uName"),
      "password": password,
    });

    var response =
        await _httpClient.post(loginUri, body: body, headers: headers);
    if (response.statusCode == 200 && response.body.isEmpty == false) {
      var jsonResponse = json.decode(response.body);
      String token = jsonResponse["token"];
      return token;
    } else {
      throw ErrorEmptyResponse();
    }
  }

  Future<void> uploadImageFile(
      AppFileModel file, String token, Function updater) async {
    // for (var index = 1; index <= 10; ++index) {
    //   var rng = Random();
    //   var sec = rng.nextInt(3) + 1;
    //   // sleep(Duration(microseconds: (5 * 1000).toInt()));
    //   Future.delayed(Duration(seconds: index), () {
    //     updater(file, index * 10, 100);
    //     return 1;
    //   });
    // }
    // updater(100, 100);

    final fileUri = Uri.parse(file.baseURL);
    final imageUri = Uri.http(baseUrl, "api/profile/coach/add-transformation");
    Map<String, String> headers = {'authorization': "Bearer $token"};

    var request = new http.MultipartRequest("POST", imageUri);
    request.headers.addAll(headers);

    var multiPartFile = http.MultipartFile.fromBytes(
        "transformation", await File.fromUri(fileUri).readAsBytes(),
        contentType: MediaType('image', 'jpeg'), filename: file.name);

    request.files.add(multiPartFile);
    request.fields["description"] = "{\"description\": \"string\"}";
    Future<StreamedResponse> response = request.send();
    response.then((result) {
        if (result.statusCode == 200) {
        updater(file, 100, 100);
        print("Uploaded!");
      } else {
        print("Resp: $response");
      }
    });

    response.asStream().listen((event) {
      print(event.toString());
    });

    // .request
    // .send()
    // .then((response) {
    //   if (response.statusCode == 200) {
    //     updater(file, 100, 100);
    //     print("Uploaded!");
    //   } else {
    //     print("Resp: $response");
    //   }
    // });
  }

  Future<void> uploadVideoFile(
      AppFileModel file, String token, Function updater) async {
    // for (var index = 1; index <= 10; ++index) {
    //   var rng = Random();
    //   var sec = rng.nextInt(3) + 1;
    //   // sleep(Duration(microseconds: (5 * 1000).toInt()));
    //   Future.delayed(Duration(seconds: index), () {
    //     updater(file, index * 10, 100);
    //     return 1;
    //   });
    // }
    // updater(100, 100);

    final fileUri = Uri.parse(file.baseURL);
    final videoUri = Uri.http(baseUrl, "api/profile/coach/add-reel");
    Map<String, String> headers = {'authorization': "Bearer $token"};

    var request = new http.MultipartRequest("POST", videoUri);
    request.headers.addAll(headers);

    var multiPartFile = http.MultipartFile.fromBytes(
        "reel", await File.fromUri(fileUri).readAsBytes(),
        contentType: MediaType('video', 'mp4'), filename: file.name);

    request.files.add(multiPartFile);
    request.fields["description"] = "{\"description\": \"string\"}";
    Future<StreamedResponse> response = request.send();
    response.then((result) {
        if (result.statusCode == 200) {
        updater(file, 100, 100);
        print("Uploaded!");
      } else {
        print("Resp: $response");
      }
    });

    response.asStream().listen((event) {
      print(event.toString());
    });

    // .request
    // .send()
    // .then((response) {
    //   if (response.statusCode == 200) {
    //     updater(file, 100, 100);
    //     print("Uploaded!");
    //   } else {
    //     print("Resp: $response");
    //   }
    // });
  }

  /*static Future<String> fileUploadMultipart(
      {File file, OnUploadProgressCallback onUploadProgress}) async {
    assert(file != null);

    final url = '$baseUrl/api/file';

    final httpClient = getHttpClient();

    final request = await httpClient.postUrl(Uri.parse(url));

    int byteCount = 0;

    var multipart = await http.MultipartFile.fromPath(fileUtil.basename(file.path), file.path);

    // final fileStreamFile = file.openRead();

    // var multipart = MultipartFile("file", fileStreamFile, file.lengthSync(),
    //     filename: fileUtil.basename(file.path));

    var requestMultipart = http.MultipartRequest("", Uri.parse("uri"));

    requestMultipart.files.add(multipart);

    var msStream = requestMultipart.finalize();

    var totalByteLength = requestMultipart.contentLength;

    request.contentLength = totalByteLength;

    request.headers.set(
        HttpHeaders.contentTypeHeader, requestMultipart.headers[HttpHeaders.contentTypeHeader]);

    Stream<List<int>> streamUpload = msStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);

          byteCount += data.length;

          if (onUploadProgress != null) {
            onUploadProgress(byteCount, totalByteLength);
            // CALL STATUS CALLBACK;
          }
        },
        handleError: (error, stack, sink) {
          throw error;
        },
        handleDone: (sink) {
          sink.close();
          // UPLOAD DONE;
        },
      ),
    );

    await request.addStream(streamUpload);

    final httpResponse = await request.close();
//
    var statusCode = httpResponse.statusCode;

    if (statusCode ~/ 100 != 2) {
      throw Exception('Error uploading file, Status code: ${httpResponse.statusCode}');
    } else {
      return await readResponseAsString(httpResponse);
    }
  }
*/
  // static HttpClient getHttpClient() {
  //   HttpClient httpClient = new HttpClient()
  //     ..connectionTimeout = const Duration(seconds: 10)
  //     ..badCertificateCallback =
  //         ((X509Certificate cert, String host, int port) => trustSelfSigned);

  //   return httpClient;
  // }
}

class ErrorEmptyResponse implements Exception {}

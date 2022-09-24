import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/models/profile_data.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/core/api/timetable_manager.dart';
import 'package:your_schedule/core/exceptions.dart';
import 'package:your_schedule/util/logger.dart';

enum PersonType {
  schoolClass("Klasse"),
  student("Schüler"),
  teacher("Lehrer"),
  subject("Fach"),
  room("Raum"),
  unknown("");

  const PersonType(this.readableName);

  final String readableName;
}

class UserSession {
  final Logger log = getLogger();

  final String appName;
  String _sessionId = "";
  int _loggedPersonId = -1;
  int _schoolClassId = -1;
  PersonType _loggedPersonType = PersonType.unknown;

  int _timetablePersonId = -1;
  PersonType _timetablePersonType = PersonType.unknown;

  final String school;

  String get schoolBase64 => base64Encode(utf8.encode(school));

  ///Die base url von allen API Endpunkten.
  final String apiBaseUrl = "https://herakles.webuntis.com";

  ///JsonRPC endpoint. Überlicherweise: https://hepta.webuntis.com/WebUntis/jsonrpc.do?school=bbs1-mainz
  String rpcUrl = "";
  bool _sessionIsValid = false;

  // Empfindliche Variablen:

  String _username = "";
  String _password = "";

  //Token für API
  String _bearerToken = "";

  ProfileData? _cachedProfileData = null;
  TimeTableManager? _manager = null;
  PeriodSchedule? _periodSchedule = null;

  UserSession(this.school, this.appName);

  Future<void> createSession(String username, String password,
      [String token = ""]) async {
    _manager = TimeTableManager(this);

    if (_sessionIsValid) {
      throw UserAlreadyLoggedInException(
          "Der Benutzer ist bereits eingeloggt. Versuche eine neues User Objekt zu erstellen oder die Funktion 'logout()' vorher aufzurufen!");
    }
    if (username == "" || password == "") {
      throw MissingCredentialsException(
          "Bitte gib einen Benutzernamen und ein Passwort an");
    }

    RPCResponse response = await _queryRPC("authenticate",
        {"user": username, "password": password, "client": _appName});
  }

  Future<RPCResponse> _queryRPC(String method, Map<String, dynamic> params,
      {bool validateSession = true, String overwriteUrl = ""}) async {
    Map<String, dynamic> requestBody = {
      "id": appName,
      "method": method,
      "params": params,
      "jsonrpc": "2.0",
    };

    RPCResponse response = RPCResponse.fromHttpResponse(
      await http.Client().post(
        Uri.parse(overwriteUrl.isEmpty ? rpcUrl : overwriteUrl),
        headers: {
          "Content-type": "application/json",
          "Cookie": _buildAuthCookie(),
        },
        body: jsonEncode(requestBody),
      ),
    );

    if (!validateSession || response.errorCode != -8520 || !_sessionIsValid) {
      return response;
    }

    log.v("Validation Session");
    await _validateSession();

    ///TODO: That is very dangerous recursion. Lets see tomorrow.
  }

  String _buildAuthCookie() {
    if (!_sessionIsValid) return "";
    return "JSESSIONID=$_sessionId; schoolname=${schoolBase64.replaceAll("=", "%3D")}";
  }
}

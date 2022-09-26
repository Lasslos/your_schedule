import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:your_schedule/core/api/cached_timetable_week_data.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/models/profile_data.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/core/api/timetable_manager.dart';
import 'package:your_schedule/core/api/timetable_time_span.dart';
import 'package:your_schedule/core/exceptions.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

enum PersonType {
  schoolClass("Klasse"),
  teacher("Lehrer"),
  subject("Fach"),
  room("Raum"),
  student("Schüler"),
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

  ProfileData? _cachedProfileData;
  TimeTableManager? _manager;
  PeriodSchedule? _periodSchedule;

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
        {"user": username, "password": password, "client": appName});

    if (response.isHttpError) {
      if (response.httpResponse == 501) {
        throw ApiConnectionError(
            "$apiBaseUrl nicht verfügbar. Bitte versuche es später erneut.");
      } else {
        throw ApiConnectionError(
            "Ein http Fehler ist aufegteten: ${response.statusMessage}(${response.httpResponse})");
      }
    }

    if (response.isApiError) {
      if (response.errorCode == RPCResponse.rpcWrongCredentials) {
        throw WrongCredentialsException(
            "Die eingegebenen Zugangsdaten sind falsch.");
      } else {
        throw ApiConnectionError(
            "Ein Fehler ist aufgetreten: ${response.statusMessage}(${response.errorCode})");
      }
    }

    _sessionId = response.payload["sessionId"];
    _loggedPersonId = response.payload["personId"];
    _timetablePersonId = _loggedPersonId;
    _schoolClassId = response.payload["schoolClassId"];
    _loggedPersonType = PersonType.values[response.payload["personType"] - 1];
    _timetablePersonType = _loggedPersonType;

    _sessionIsValid = true;
    _username = username;
    _password = password;

    ///Check if two-factor authentication is enabled
    http.Response twoFactor = await _queryURL(
      "/WebUntis/j_spring_security_check",
      needsAuthorization: true,
      body: {
        "j_username": username,
        "j_password": password,
        "school": schoolBase64,
        "token": token,
      },
    );
    if (twoFactor.body.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(twoFactor.body);
      if (json["state"] == "TOKEN_REQUIRED") {
        if (json["invalidToken"] == true) {
          throw InvalidSecurityToken(
              "Zwei-Faktor Authentifizierung fehlgeschlagen. Bitte versuche es erneut");
        } else {
          throw SecurityTokenRequired(
              "Dieses Profil ist mit Zwei-Faktor Authentifizierung versehen. Bitte gib deinen Zwei-Faktor Authentifizierungscode ein");
        }
      }
    }

    await regenerateSessionBearerToken();
    _cachedProfileData = await getProfileData(loadFromCache: false);

    PeriodSchedule schedule = await getPeriodSchedule();
    _periodSchedule = schedule;
    if (_manager != null) {
      _manager!.periodSchedule = schedule;
    }
  }

  Future<RPCResponse> logout() async {
    RPCResponse response =
        await _queryRPC("logout", {}, validateSession: false);
    _sessionIsValid = false;
    _sessionId = "";
    _username = "";
    _password = "";
    _loggedPersonId = -1;
    _schoolClassId = -1;
    _loggedPersonType = PersonType.unknown;
    _bearerToken = "";
    _manager?.clearCache();
    return response;
  }

  Future<TimeTableTimeSpan> getTimeTable(
      DateTime from, DateTime to, CachedTimeTableWeekData weekData,
      {int personID = -1, PersonType personType = PersonType.unknown}) async {
    if (!_sessionIsValid) {
      throw Exception("Session is not valid");
    }

    return TimeTableTimeSpan(
      from,
      to,
      weekData,
      await _queryRPC(
        "getTimetable",
        {
          "options": {
            "startDate": from.convertToUntisDate,
            "endDate": to.convertToUntisDate(),
            "element": {
              "id": personID == -1
                  ? (_timetablePersonId == -1
                      ? _loggedPersonId
                      : _timetablePersonId)
                  : personID,
              "type": (personType == PersonType.unknown
                      ? (_timetablePersonType == PersonType.unknown
                          ? _loggedPersonType.index
                          : _timetablePersonType.index)
                      : personType.index) +
                  1,
            },
            "showLsText": true,
            "showPeText": true,
            "showStudentgroup": true,
            "showLsNumber": true,
            "showSubstText": true,
            "showInfo": true,
            "showBooking": true,
            "klasseFields": ['id', 'name', 'longname', 'externalkey'],
            "roomFields": ['id', 'name', 'longname', 'externalkey'],
            "subjectFields": ['id', 'name', 'longname', 'externalkey'],
            "teacherFields": ['id', 'name', 'longname', 'externalkey']
          }
        },
      ),
    );
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

    await _validateSession();
    if (_sessionIsValid) {
      return RPCResponse.fromHttpResponse(
        await http.Client().post(
          Uri.parse(overwriteUrl.isEmpty ? rpcUrl : overwriteUrl),
          headers: {
            "Content-type": "application/json",
            "Cookie": _buildAuthCookie(),
          },
          body: jsonEncode(requestBody),
        ),
      );
    } else {
      throw Exception(
          "Session validation failed. Please log out and try again.");
    }
  }

  Future<http.Response> _queryURL(String url,
      {bool needsAuthorization = false, dynamic body}) async {
    if (needsAuthorization && !isApiAuthorized()) {
      log.w("Failed to fetch bearer token. Retrying ...");
      await regenerateSessionBearerToken();
    }

    Map<String, String> headers = {
      "Content-type": "application/json",
      "Cookie": _buildAuthCookie(),
      if (needsAuthorization) "Authorization": "Bearer $_bearerToken"
    };

    if (body == null) {
      return http.Client().get(Uri.parse(apiBaseUrl + url), headers: headers);
    } else {
      return http.Client()
          .post(Uri.parse(apiBaseUrl + url), headers: headers, body: body);
    }
  }

  bool isApiAuthorized() {
    return _bearerToken.isNotEmpty;
  }

  FutureOr<ProfileData> getProfileData({bool loadFromCache = true}) async {
    if (loadFromCache && _cachedProfileData != null) {
      return _cachedProfileData!;
    }

    http.Response response = await _queryURL(
        "/WebUntis/api/rest/view/v1/app/data",
        needsAuthorization: true);
    _cachedProfileData = ProfileData.fromJSON(jsonDecode(response.body));
    return _cachedProfileData!;
  }

  Future<PeriodSchedule> getPeriodSchedule() async {
    if (!isApiAuthorized()) {
      throw ApiConnectionError("The user is not logged in!");
    }
    try {
      http.Response response = await _queryURL(
          "/WebUntis/api/rest/view/v1/timegrid",
          needsAuthorization: true);
      log.i("Successfully fetched period schedule");
      return PeriodSchedule.fromJSON(jsonDecode(response.body));
    } catch (e) {
      log.e("Failed to fetch period schedule", e);
      rethrow;
    }
  }

  Future<void> regenerateSessionBearerToken() async {
    log.d("Regenerating bearer token ...");
    http.Response response = await _queryURL(
      "/WebUntis/api/token/new",
      needsAuthorization: false,
    );
    if (response.statusCode == 200) {
      _bearerToken = response.body;
    } else {
      log.w(
          "Warning: Failed to fetch api token. Unable to call 'getNews()' and 'getProfileData()'");
    }
  }

  Future<void> _validateSession() async {
    _sessionIsValid = false;
    log.v("Revalidation active session");
    await createSession(_username, _password);
  }

  String _buildAuthCookie() {
    if (!_sessionIsValid) {
      return "";
    }
    return "JSESSIONID=$_sessionId; schoolname=${schoolBase64.replaceAll("=", "%3D")}";
  }
}

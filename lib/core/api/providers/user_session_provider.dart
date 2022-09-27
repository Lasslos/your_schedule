import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:your_schedule/core/api/models/profile_data.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/core/exceptions.dart';
import 'package:your_schedule/util/logger.dart';
import 'package:your_schedule/util/secure_storage_util.dart';

@immutable
class UserSession {
  const UserSession(
      {this.school = "",
      this.appName = "",
      this.sessionID = "",
      this.loggedInPersonID = -1,
      this.schoolClassID = -1,
      this.loggedInPersonType = PersonType.unknown,
      this.timeTablePersonID = -1,
      this.timeTablePersonType = PersonType.unknown,
      this.sessionIsValid = false,
      this.username = "",
      String password = "",
      this.bearerToken = "",
      this.profileData})
      : _password = password;

  UserSession copyWith(
      {String? appName,
      String? sessionID,
      int? loggedInPersonID,
      int? schoolClassID,
      PersonType? loggedInPersonType,
      int? timeTablePersonID,
      PersonType? timeTablePersonType,
      String? school,
      bool? sessionIsValid,
      String? username,
      String? password,
      String? bearerToken,
      ProfileData? profileData}) {
    return UserSession(
        appName: appName ?? this.appName,
        sessionID: sessionID ?? this.sessionID,
        loggedInPersonID: loggedInPersonID ?? this.loggedInPersonID,
        schoolClassID: schoolClassID ?? this.schoolClassID,
        loggedInPersonType: loggedInPersonType ?? this.loggedInPersonType,
        timeTablePersonID: timeTablePersonID ?? this.timeTablePersonID,
        timeTablePersonType: timeTablePersonType ?? this.timeTablePersonType,
        school: school ?? this.school,
        sessionIsValid: sessionIsValid ?? this.sessionIsValid,
        username: username ?? this.username,
        password: password ?? _password,
        bearerToken: bearerToken ?? this.bearerToken,
        profileData: profileData ?? this.profileData);
  }

  final String appName;

  final String sessionID;
  final int loggedInPersonID;
  final int schoolClassID;
  final PersonType loggedInPersonType;

  final int timeTablePersonID;
  final PersonType timeTablePersonType;

  final String school;

  String get schoolBase64 => base64Encode(utf8.encode(school));

  ///Base url of all API calls. This might be different for different schools.
  final String apiBaseURL = "https://herakles.webuntis.com";

  ///JsonRPC endpoint.
  String get rpcURL => "$apiBaseURL/WebUntis/jsonrpc.do?school=$school";

  final bool sessionIsValid;

  final String username;
  final String _password;

  ///TOKEN for API
  final String bearerToken;
  final ProfileData? profileData;

  bool get isLoggedIn =>
      sessionIsValid && sessionID.isNotEmpty && loggedInPersonID != -1;

  bool get isRPCAuthorized => sessionID.isNotEmpty && loggedInPersonID != -1;

  bool get isAPIAuthorized => bearerToken.isNotEmpty;
}

class UserSessionNotifier extends StateNotifier<UserSession> {
  UserSessionNotifier() : super(const UserSession());

  Future<void> createSession(String username, String password, String school,
      [String token = ""]) async {
    getLogger().i("Creating session for $username");
    state = state.copyWith(school: school);
    if (state.sessionIsValid) {
      throw UserAlreadyLoggedInException(
          "Der Benutzer ist bereits eingeloggt. Versuche eine neues User Objekt zu erstellen oder die Funktion 'logout()' vorher aufzurufen!");
    }
    if (username.isEmpty || password.isEmpty || school.isEmpty) {
      throw MissingCredentialsException(
          "Bitte gib einen Benutzernamen, ein Passwort und eine Schule an");
    }

    RPCResponse response = await queryRPC("authenticate",
        {"user": username, "password": password, "client": state.appName});

    if (response.isHttpError) {
      if (response.httpResponse == 501) {
        throw ApiConnectionError(
            "${state.apiBaseURL} nicht verfügbar. Bitte versuche es später erneut.");
      } else {
        throw ApiConnectionError(
            "Ein http Fehler ist aufgetreten: ${response.statusMessage}(${response.httpResponse})");
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

    state = state.copyWith(
      sessionID: response.payload["sessionId"],
      loggedInPersonID: response.payload["personId"],
      timeTablePersonID: response.payload["personId"],
      schoolClassID: response.payload["schoolClassId"],
      loggedInPersonType: response.payload["personType"] != null
          ? PersonType.values[response.payload["personType"] - 1]
          : null,
      timeTablePersonType: response.payload["personType"] != null
          ? PersonType.values[response.payload["personType"] - 1]
          : null,
      sessionIsValid: true,
      username: username,
      password: password,
      school: school,
    );

    ///Check if two-factor authentication is enabled
    http.Response twoFactor = await queryURL(
      "/WebUntis/j_spring_security_check",
      needsAuthorization: true,
      body: {
        "j_username": username,
        "j_password": password,
        "school": state.schoolBase64,
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
    state = state.copyWith(profileData: await _getProfileData());
    getLogger().i("Successfully created session!");
    secureStorage
      ..write(key: usernameKey, value: username)
      ..write(key: passwordKey, value: password)
      ..write(key: schoolKey, value: school);
  }

  Future<RPCResponse> logout() async {
    getLogger().i("Logging out");
    RPCResponse response = await queryRPC("logout", {}, validateSession: false);
    state = state.copyWith(
      sessionIsValid: false,
      sessionID: "",
      username: "",
      password: "",
      loggedInPersonID: -1,
      schoolClassID: -1,
      loggedInPersonType: PersonType.unknown,
      bearerToken: "",
      profileData: null,
    );
    return response;
  }

  FutureOr<ProfileData> _getProfileData() async {
    http.Response response = await queryURL(
        "/WebUntis/api/rest/view/v1/app/data",
        needsAuthorization: true);
    return ProfileData.fromJSON(jsonDecode(response.body));
  }

  Future<RPCResponse> queryRPC(String method, Map<String, dynamic> params,
      {bool validateSession = true, String overwriteUrl = ""}) async {
    Map<String, dynamic> requestBody = {
      "id": state.appName,
      "method": method,
      "params": params,
      "jsonrpc": "2.0",
    };

    RPCResponse response = RPCResponse.fromHttpResponse(
      await http.Client().post(
        Uri.parse(overwriteUrl.isEmpty ? state.rpcURL : overwriteUrl),
        headers: {
          "Content-type": "application/json",
          "Cookie": _buildAuthCookie(),
        },
        body: jsonEncode(requestBody),
      ),
    );

    if (!validateSession ||
        response.errorCode != -8520 ||
        !state.sessionIsValid) {
      return response;
    }

    await _validateSession();
    if (state.sessionIsValid) {
      return RPCResponse.fromHttpResponse(
        await http.Client().post(
          Uri.parse(overwriteUrl.isEmpty ? state.rpcURL : overwriteUrl),
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

  Future<http.Response> queryURL(String url,
      {bool needsAuthorization = false, dynamic body}) async {
    if (needsAuthorization && !state.isAPIAuthorized) {
      getLogger().w("Failed to fetch bearer token. Retrying ...");
      await regenerateSessionBearerToken();
    }

    Map<String, String> headers = {
      "Content-type": "application/json",
      "Cookie": _buildAuthCookie(),
      if (needsAuthorization) "Authorization": "Bearer ${state.bearerToken}"
    };

    if (body == null) {
      return http.Client()
          .get(Uri.parse(state.apiBaseURL + url), headers: headers);
    } else {
      return http.Client().post(Uri.parse(state.apiBaseURL + url), body: body);
    }
  }

  String _buildAuthCookie() {
    if (!state.sessionIsValid) {
      return "";
    }
    return "JSESSIONID=${state.sessionID}; schoolname=${state.schoolBase64.replaceAll("=", "%3D")}";
  }

  Future<void> _validateSession() async {
    state = state.copyWith(sessionIsValid: false);
    getLogger().v("Revalidation active session");
    await createSession(state.username, state._password, state.school);
  }

  Future<void> regenerateSessionBearerToken() async {
    getLogger().d("Regenerating bearer token ...");
    http.Response response = await queryURL(
      "/WebUntis/api/token/new",
      needsAuthorization: false,
    );
    if (response.statusCode == 200) {
      state = state.copyWith(bearerToken: response.body);
    } else {
      getLogger().w(
          "Warning: Failed to fetch api token. Unable to call 'getNews()' and 'getProfileData()'");
    }
  }
}

final userSessionProvider =
    StateNotifierProvider<UserSessionNotifier, UserSession>((ref) {
  return UserSessionNotifier();
});

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

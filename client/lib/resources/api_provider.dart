import 'dart:convert';

import 'package:client/dashboard_screen.dart';
import 'package:client/models/generate_report_form_model.dart';
import 'package:client/models/patient_list_object_model.dart';
import 'package:client/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider {
  Client client = Client();

  dynamic auth(BuildContext context, String email, {String otp = ''}) async {
    final url = Uri.parse("https://nutrihelpb.herokuapp.com/auth");

    final jsonBody = otp == ''
        ? jsonEncode({
            'email': email,
          })
        : jsonEncode({
            'email': email,
            'otp': otp,
          });

    // var decodedBody = jsonDecode(jsonBody);
    // print(decodedBody['token']);

    final res = await client.post(
      url,
      body: jsonBody,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final status = data['msg'].toString();
      final userId = data['userid'].toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(status)));
      if (otp != '' && data['ok'] == true) {
        final SharedPreferences isLogin = await SharedPreferences.getInstance();
        isLogin.setBool('login', true);
        isLogin.setString('userId', userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashBoardScreen(),
          ),
        );
      }
    }
  }
}

void postPatient(BuildContext context, String name, String gender, int age,
    String mobile) async {
  final url = Uri.parse("https://nutrihelpb.herokuapp.com/patients");
  final SharedPreferences localStorage = await SharedPreferences.getInstance();
  final String userid = localStorage.getString('userId');
  final jsonBody = jsonEncode({
    "userid": userid,
    "patient": {"age": age, "gender": gender, "mobile": mobile, "name": name}
  });

  final res = await http.post(
    url,
    body: jsonBody,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final status = data['msg'].toString();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Something wrong')));
  }
}

void generateReport(BuildContext context, GenerateReport _reportObject,
    Patient _patientObject) async {
  final SharedPreferences localStorage = await SharedPreferences.getInstance();
  final String userid = localStorage.getString('userId');
  final patientId = _patientObject.id;
  final putUrl =
      Uri.parse("https://nutrihelpb.herokuapp.com/patients/$userid/$patientId");

  final jsonBody = _patientObject.gender == 'F'
      ? jsonEncode({
          "stats": {
            "family_diabetes": _reportObject.familyMember,
            "bp": _reportObject.bloodPressure,
            "physically_active": _reportObject.physicallyActive,
            "weight": _reportObject.weight,
            "height": _reportObject.height,
            "smoke": _reportObject.smoking,
            "alcolol": _reportObject.alcohol,
            "sleep": _reportObject.averageSleep,
            "sound_sleep": _reportObject.soundSleep,
            "medicine": _reportObject.medicineRegularly,
            "junk_food": _reportObject.junkFood,
            "stress": _reportObject.stress,
            "pregnancies": _reportObject.pregnancies,
            "gestational": _reportObject.gestational,
            "urination": _reportObject.urinationFreq
          }
        })
      : jsonEncode({
          "stats": {
            "family_diabetes": _reportObject.familyMember,
            "bp": _reportObject.bloodPressure,
            "physically_active": _reportObject.physicallyActive,
            "weight": _reportObject.weight,
            "height": _reportObject.height,
            "smoke": _reportObject.smoking,
            "alcolol": _reportObject.alcohol,
            "sleep": _reportObject.averageSleep,
            "sound_sleep": _reportObject.soundSleep,
            "medicine": _reportObject.medicineRegularly,
            "junk_food": _reportObject.junkFood,
            "stress": _reportObject.stress,
            "urination": _reportObject.urinationFreq
          }
        });

  final res = await http.put(
    putUrl,
    body: jsonBody,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (res.statusCode == 200) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(
          patientId: _patientObject.id,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Something wrong')));
  }
}

void deletePatient(BuildContext context, String patientId) async {
  final SharedPreferences localStorage = await SharedPreferences.getInstance();
  final String userId = localStorage.getString('userId');
  final url =
      Uri.parse("https://nutrihelpb.herokuapp.com/patients/$userId/$patientId");

  final res = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final status = data['msg'].toString();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashBoardScreen(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Something wrong')));
  }
}

void deleteReport(BuildContext context, String reportId) async {
  final SharedPreferences localStorage = await SharedPreferences.getInstance();
  final String userId = localStorage.getString('userId');
  final url =
      Uri.parse("https://nutrihelpb.herokuapp.com/reports/$userId/$reportId");

  final res = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final status = data['msg'].toString();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashBoardScreen(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Something wrong')));
  }
}

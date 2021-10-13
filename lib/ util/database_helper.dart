

import 'dart:io';
import 'package:flutter2/models/contact.dart';
import 'package:async/async.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

// a dart file to communicate with back end code- here are the crud opertion command codes follows up

class DatabaseHelper {
  static const _databaseVersion = 1;

  

  //singleton class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();


 
  //contact - insert
Future<int> insertContact(Contact contact) async {
   int message;
   print(contact.toJson());
   Response response;
  Dio dio = new Dio();
  try{ 

    // attach your backend server port

    response= await dio.post<Map<String,dynamic>>("http://192.168.29.215:8080/api/contact1",data:contact.toJson());
    message=response.statusCode;
}
catch(e)
{
  print('Error $e');
  message=500;
}
  return message;
}
// //contact - update
Future<int> updateContact(Contact contact,int id) async {
 Response response;
 print(contact.toJson());
  Dio dio = new Dio();
  response=await dio.put("http://192.168.29.215:8080/api/contact1/$id",data:contact.toJson());
  return response.statusCode;
}

Future<List<Contact>> fetchContacts() async {
 
  Response response;
  Dio dio = new Dio();
  response= await dio.get("http://192.168.29.215:8080/api/contact1");
  
  return (response.data as List).map((x)=>Contact.fromJson(x)).toList();
 
}

Future<int> deleteContact( int id) async {
Response response;
// ignore: avoid_print

Dio dio = new Dio();
response = await dio.delete("http://192.168.29.215:8080/api/contact1/$id");
return response.statusCode;
}


}




// the basic initialising page to get the contact details

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'contact.g.dart';

@JsonSerializable()
class Contact {


  Contact({required this.id,required this.name,required this.mobile});

  int  id =0;
  String name = "";
  String mobile ="";

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  

}
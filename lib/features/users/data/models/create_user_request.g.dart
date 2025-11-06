// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateUserRequestImpl _$$CreateUserRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateUserRequestImpl(
  name: json['name'] as String,
  email: json['email'] as String,
  gender: json['gender'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$$CreateUserRequestImplToJson(
  _$CreateUserRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'gender': instance.gender,
  'status': instance.status,
};

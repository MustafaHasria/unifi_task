import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String gender;
  final String status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, email, gender, status];

  bool get isActive => status.toLowerCase() == 'active';
}


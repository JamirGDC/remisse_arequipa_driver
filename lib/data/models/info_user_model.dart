import '../../domain/entities/user.dart';

class InfoUserModel extends User {
  InfoUserModel({required super.id, required String super.name, required String super.lastName});

  factory InfoUserModel.fromJson(Map<String, dynamic> json) {
    return InfoUserModel(id: json['id'], name: json['name'], lastName: json['lastName']);
  }
}

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? password;
  final String? carModel;
  final String? carColor;
  final String? carPlate;
  final String? perfilPhoto;
  UserModel({required this.uid, required this.email, this.name, this.phone, this.password, this.carModel, this.carColor, this.carPlate, this.perfilPhoto});
}
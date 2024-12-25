import 'package:remisse_arequipa_driver/data/models/auth_login_user_model.dart';

abstract class AuthRepository {
  Future<AuthLoginUserModel> login(String email, String password);
}

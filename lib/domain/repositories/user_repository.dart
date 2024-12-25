import 'package:remisse_arequipa_driver/data/models/info_user_model.dart';

abstract class UserRepository {
  Future<InfoUserModel> getUserInfo();
}

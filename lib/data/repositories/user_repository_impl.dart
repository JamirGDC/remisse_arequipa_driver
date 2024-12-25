import 'package:remisse_arequipa_driver/data/datasources/user_remote_data_source.dart';
import 'package:remisse_arequipa_driver/data/models/info_user_model.dart';
import 'package:remisse_arequipa_driver/domain/repositories/user_repository.dart';


class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<InfoUserModel> getUserInfo() async {
    return await remoteDataSource.getUserInfo();
  }








}
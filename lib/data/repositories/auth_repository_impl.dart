import 'package:remisse_arequipa_driver/data/datasources/auth_remote_data_source.dart';
import 'package:remisse_arequipa_driver/data/models/auth_login_user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthLoginUserModel> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }
}
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> execute(String email, String password) async {
    try {
      final user = await repository.login(email, password);
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.code));
    }
  }
}


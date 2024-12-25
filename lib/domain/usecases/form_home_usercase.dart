import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remisse_arequipa_driver/data/models/info_user_model.dart';
import 'package:remisse_arequipa_driver/domain/repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class FormHomeUseCase {
  final UserRepository repository;

  FormHomeUseCase(this.repository);

  Future<Either<Failure, InfoUserModel>> getUserInfo() async {
    try {
      final user = await repository.getUserInfo();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.code));
    }
  }



}


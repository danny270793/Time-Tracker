import '../repositories/auth_repository.dart';

class UpdateEmailUsecase {
  UpdateEmailUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String newEmail}) =>
      _repository.updateEmail(newEmail);
}

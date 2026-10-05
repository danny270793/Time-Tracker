import '../repositories/auth_repository.dart';

class UpdatePasswordUsecase {
  UpdatePasswordUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String newPassword}) =>
      _repository.updatePassword(newPassword);
}

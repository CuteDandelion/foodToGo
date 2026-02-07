import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Base use case class with parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base use case class without parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Empty parameters class
class NoParams {
  const NoParams();
}

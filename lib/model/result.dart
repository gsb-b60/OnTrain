import 'package:ontrain/model/error.dart';

class Result<T> {
  final T? data;
  final RepoError? error;

  Result({this.data, this.error});

  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;

  bool get isSuccess => data != null && error == null;
  bool get isError => error != null && data == null;
}
abstract interface class Usecase<R, P> {
  // R = Return, P = Parameter
  Future<R> call(P params);
}

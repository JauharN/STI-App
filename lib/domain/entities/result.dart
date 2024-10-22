sealed class Result<T> {
  // Ini adalah kelas abstrak yang menjadi dasar untuk Result.
  // Generic type T memungkinkan Result untuk bekerja dengan berbagai tipe data.

  const Result();
  // Konstruktor const untuk efisiensi memori.

  // Factory constructors untuk membuat instance Success atau Failed
  const factory Result.success(T value) = Success;
  const factory Result.failed(String message) = Failed;

  // Getter untuk mengecek apakah Result adalah Success
  bool get isSuccess => this is Success<T>;

  // Getter untuk mengecek apakah Result adalah Failed
  bool get isFailed => this is Failed<T>;

  // Getter untuk mengambil nilai jika Success, null jika Failed
  T? get resultValue => isSuccess ? (this as Success<T>).value : null;

  // Getter untuk mengambil pesan error jika Failed, null jika Success
  String? get errorMessage => isFailed ? (this as Failed<T>).message : null;
}

// Kelas turunan untuk representasi hasil sukses
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

// Kelas turunan untuk representasi hasil gagal
class Failed<T> extends Result<T> {
  final String message;
  const Failed(this.message);
}

part of 'delete_progres_hafalan.dart';

class DeleteProgresHafalanParams {
  final String id;
  final String userId;
  final String currentUserRole;

  DeleteProgresHafalanParams({
    required this.id,
    required this.userId,
    required this.currentUserRole,
  }) {
    // Validasi input
    if (id.isEmpty) {
      throw ArgumentError('ID progres hafalan tidak boleh kosong');
    }

    if (userId.isEmpty) {
      throw ArgumentError('ID user tidak boleh kosong');
    }
  }
}

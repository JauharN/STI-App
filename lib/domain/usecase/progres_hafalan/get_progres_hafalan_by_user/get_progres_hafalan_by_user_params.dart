part of 'get_progres_hafalan_by_user.dart';

class GetProgresHafalanByUserParams {
  final String userId;
  final String requestingUserId;
  final String currentUserRole;
  final String? programId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetProgresHafalanByUserParams({
    required this.userId,
    required this.requestingUserId,
    required this.currentUserRole,
    this.programId,
    this.startDate,
    this.endDate,
  }) {
    // Validasi ID santri
    if (userId.isEmpty) {
      throw ArgumentError('ID santri tidak boleh kosong');
    }

    // Validasi ID requester
    if (requestingUserId.isEmpty) {
      throw ArgumentError('ID requester tidak boleh kosong');
    }

    // Validasi role
    if (!['admin', 'superAdmin', 'santri'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid');
    }

    // Validasi program ID jika ada
    if (programId != null && !['TAHFIDZ', 'GMM'].contains(programId)) {
      throw ArgumentError('Program ID tidak valid');
    }

    // Validasi date range jika keduanya diisi
    if (startDate != null && endDate != null) {
      if (startDate!.isAfter(endDate!)) {
        throw ArgumentError('Tanggal awal tidak boleh setelah tanggal akhir');
      }
    }
  }
}

class GetUpcomingSesiParams {
  // ID program yang ingin dilihat sesi mendatangnya
  final String programId;

  // Opsional: batasan jumlah sesi yang ingin ditampilkan
  final int? limit;

  GetUpcomingSesiParams({
    required this.programId,
    this.limit,
  });
}

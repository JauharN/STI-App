import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/news_model.dart';

part 'news_provider.g.dart';

@riverpod
List<News> newsList(NewsListRef ref) {
  return [
    News(
      id: '1',
      title: 'Kegiatan Bulan Ini',
      description: 'Jadwal kegiatan bersama santri dan pengajar.',
      imageUrl: null,
      date: DateTime.now(),
    ),
    News(
      id: '2',
      title: 'Pengumuman Libur',
      description: 'Hari libur nasional akan dimulai pada 25 Desember.',
      imageUrl: null,
      date: DateTime.now(),
    ),
  ];
}

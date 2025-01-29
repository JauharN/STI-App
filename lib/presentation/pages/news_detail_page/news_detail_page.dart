import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../misc/constants.dart';
import '../../models/news_model.dart';

class NewsDetailPage extends StatelessWidget {
  final News news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Berita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  news.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              news.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Diterbitkan: ${news.date.toLocal().toString().split(' ')[0]}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              news.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

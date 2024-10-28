import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../misc/constants.dart';
import '../providers/user_data/user_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBar extends ConsumerWidget {
  final int selectedPage;

  const CustomAppBar({
    super.key,
    required this.selectedPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title;
    IconData? leadingIcon;
    IconData? trailingIcon;

    switch (selectedPage) {
      case 0:
        title = 'Assalamu\'alaikum';
        leadingIcon = null;
        trailingIcon = Icons.notifications_none_rounded;
        break;
      case 1:
        title = 'Presensi';
        leadingIcon = Icons.calendar_today_rounded;
        trailingIcon = Icons.history_rounded;
        break;
      case 2:
        title = 'Progres Hafalan';
        leadingIcon = Icons.auto_graph_rounded;
        trailingIcon = Icons.filter_list_rounded;
        break;
      case 3:
        title = 'Profil';
        leadingIcon = null;
        trailingIcon = Icons.settings_outlined;
        break;
      default:
        title = '';
        leadingIcon = null;
        trailingIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: AppColors.neutral800),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: selectedPage == 0
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: selectedPage == 0 ? 16 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    if (selectedPage == 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        ref.watch(userDataProvider).valueOrNull?.name ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingIcon != null) ...[
                IconButton(
                  onPressed: () {
                    // Handle trailing icon tap
                  },
                  icon: Icon(trailingIcon, color: AppColors.neutral800),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

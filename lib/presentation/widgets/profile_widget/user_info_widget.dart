import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../user_management_widget/role_badge_widget.dart';

List<Widget> userInfo(WidgetRef ref) => [
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.neutral100,
          border: Border.all(color: AppColors.neutral200, width: 2),
          image: DecorationImage(
            image: ref.watch(userDataProvider).valueOrNull?.photoUrl != null
                ? NetworkImage(
                        ref.watch(userDataProvider).valueOrNull!.photoUrl!)
                    as ImageProvider
                : const AssetImage('assets/profile-placeholder.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      verticalSpace(16),
      Text(
        ref.watch(userDataProvider).valueOrNull?.name ?? '',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
      ),
      verticalSpace(4),
      Text(
        ref.watch(userDataProvider).valueOrNull?.email ?? '',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.neutral600,
        ),
      ),
      verticalSpace(8),
      if (ref.watch(userDataProvider).valueOrNull?.role != null)
        RoleBadgeWidget(
          role: ref.watch(userDataProvider).valueOrNull!.role,
        ),
    ];

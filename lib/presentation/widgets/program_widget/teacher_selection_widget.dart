import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../domain/entities/user.dart';
import '../../misc/constants.dart';
import '../../providers/user/available_teachers_provider.dart';

class TeacherSelectionWidget extends ConsumerWidget {
  final List<String> selectedTeacherIds;
  final List<String> selectedTeacherNames;
  final ValueChanged<List<String>> onTeacherIdsChanged;
  final ValueChanged<List<String>> onTeacherNamesChanged;
  final bool showLabel;
  final int maxTeachers;

  const TeacherSelectionWidget({
    super.key,
    required this.selectedTeacherIds,
    required this.selectedTeacherNames,
    required this.onTeacherIdsChanged,
    required this.onTeacherNamesChanged,
    this.showLabel = true,
    this.maxTeachers = 3,
  });

  void _handleTeacherSelection(
    BuildContext context,
    User teacher,
    bool selected,
  ) {
    // Handle selection with max teachers validation
    if (selected && selectedTeacherIds.length >= maxTeachers) {
      context.showErrorSnackBar(
        'Maksimal $maxTeachers pengajar per program',
      );
      return;
    }

    // Create new lists to trigger state update
    final newIds = List<String>.from(selectedTeacherIds);
    final newNames = List<String>.from(selectedTeacherNames);

    if (selected) {
      newIds.add(teacher.uid);
      newNames.add(teacher.name);
    } else {
      final index = newIds.indexOf(teacher.uid);
      if (index != -1) {
        newIds.removeAt(index);
        newNames.removeAt(index);
      }
    }

    // Update parent
    onTeacherIdsChanged(newIds);
    onTeacherNamesChanged(newNames);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(availableTeachersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            'Pengajar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        teachersAsync.when(
          data: (teachers) => _buildTeacherChips(context, teachers),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, _) => Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        if (selectedTeacherIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${selectedTeacherIds.length}/$maxTeachers pengajar dipilih',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.neutral600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTeacherChips(BuildContext context, List<User> teachers) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: teachers.map((teacher) {
        final isSelected = selectedTeacherIds.contains(teacher.uid);
        return FilterChip(
          selected: isSelected,
          label: Text(teacher.name),
          avatar: teacher.photoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(teacher.photoUrl!),
                  radius: 12,
                )
              : null,
          onSelected: (selected) => _handleTeacherSelection(
            context,
            teacher,
            selected,
          ),
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: GoogleFonts.plusJakartaSans(
            color: isSelected ? AppColors.primary : AppColors.neutral800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}

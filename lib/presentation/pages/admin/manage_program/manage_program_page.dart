import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageProgramPage extends ConsumerStatefulWidget {
  const ManageProgramPage({super.key});

  @override
  ConsumerState<ManageProgramPage> createState() => _ManageProgramPageState();
}

class _ManageProgramPageState extends ConsumerState<ManageProgramPage> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize program data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Program',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProgramDialog(),
          ),
        ],
      ),
      body: _buildProgramList(),
    );
  }

  Widget _buildProgramList() {
    // TODO: Implement program list with ListView.builder
    return Container();
  }

  Future<void> _showAddProgramDialog() async {
    // TODO: Implement add program dialog
  }

  Future<void> _showEditProgramDialog(String programId) async {
    // TODO: Implement edit program dialog
  }

  Future<void> _showDeleteConfirmation(String programId) async {
    // TODO: Implement delete confirmation dialog
  }
}

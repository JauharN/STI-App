import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../misc/constants.dart';
import '../../../extensions/extensions.dart';
import '../../../providers/user_data/user_data_provider.dart';

class ManageSantriPage extends ConsumerStatefulWidget {
  const ManageSantriPage({super.key});

  @override
  ConsumerState<ManageSantriPage> createState() => _ManageSantriPageState();
}

class _ManageSantriPageState extends ConsumerState<ManageSantriPage> {
  // TODO: Add state variables for filtering and sorting
  String searchQuery = '';
  String filterProgram = 'all';
  String sortBy = 'name'; // name, program, status

  @override
  void initState() {
    super.initState();
    // TODO: Initialize santri data
    // TODO: Load program list for filter
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add santri list provider watch
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Santri',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // TODO: Add search action
          // TODO: Add filter action
          // TODO: Add sort action
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddSantriDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _buildSantriList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSantriDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    // TODO: Implement search bar with filter options
    return Container();
  }

  Widget _buildFilterChips() {
    // TODO: Implement filter chips for programs
    return Container();
  }

  Widget _buildSantriList() {
    // TODO: Implement santri list with ListView.builder
    return Container();
  }

  Future<void> _showAddSantriDialog() async {
    // TODO: Implement add santri dialog
  }

  Future<void> _showEditSantriDialog(String santriId) async {
    // TODO: Implement edit santri dialog
  }

  Future<void> _showDeleteConfirmation(String santriId) async {
    // TODO: Implement delete confirmation dialog
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/recording_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/waveform_painter.dart';
import '../../widgets/recording_timer.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddBookmarkDialog() {
    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        recordingProvider: Provider.of<RecordingProvider>(
          context,
          listen: false,
        ),
      ),
    );
  }

  void _showSaveRecordingDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveRecordingDialog(
        titleController: _titleController,
        descriptionController: _descriptionController,
        recordingProvider: Provider.of<RecordingProvider>(
          context,
          listen: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _showExitConfirmationDialog();
          },
        ),
        title: const Text(
          'Sedang Merekam',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add, color: Colors.white),
            onPressed: _showAddBookmarkDialog,
            tooltip: 'Tambah Bookmark',
          ),
        ],
      ),
      body: Consumer<RecordingProvider>(
        builder: (context, recordingProvider, child) {
          return Column(
            children: [
              // Waveform Section
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Recording Animation
                      // Recording Animation
                      Pulse(
                        infinite: true,
                        duration: const Duration(milliseconds: 1500),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF87CEEB).withOpacity(0.2),
                            border: Border.all(
                              color: const Color(0xFF87CEEB),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.mic,
                            size: 40,
                            color: Color(0xFF87CEEB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Waveform
                      Container(
                        height: 150,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomPaint(
                          size: const Size(double.infinity, 150),
                          painter: WaveformPainter(
                            waveformData: recordingProvider.waveformData,
                            color: const Color(0xFF87CEEB),
                            isPaused: !recordingProvider.isRecording,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Recording Timer
                      RecordingTimer(
                        duration: recordingProvider.recordingDuration,
                        isRecording: recordingProvider.isRecording,
                      ),
                      const SizedBox(height: 20),

                      // Recording Status
                      Text(
                        recordingProvider.isRecording
                            ? 'Sedang merekam...'
                            : 'Rekaman dijeda',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bookmark List
                    if (recordingProvider.bookmarks.isNotEmpty) ...[
                      _buildBookmarksList(recordingProvider),
                      const SizedBox(height: 20),
                    ],

                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pause/Resume Button
                        _buildControlButton(
                          icon: recordingProvider.isRecording
                              ? Icons.pause
                              : Icons.play_arrow,
                          label: recordingProvider.isRecording
                              ? 'Jeda'
                              : 'Lanjut',
                          color: const Color(0xFFFFB84D),
                          onPressed: recordingProvider.toggleRecording,
                        ),

                        // Stop Button
                        _buildControlButton(
                          icon: Icons.stop,
                          label: 'Stop',
                          color: const Color(0xFFFF6B6B),
                          onPressed: _showSaveRecordingDialog,
                        ),

                        // Bookmark Button
                        _buildControlButton(
                          icon: Icons.bookmark_add,
                          label: 'Bookmark',
                          color: const Color(0xFF4CAF50),
                          onPressed: _showAddBookmarkDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookmarksList(RecordingProvider recordingProvider) {
    return Container(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bookmarks:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recordingProvider.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = recordingProvider.bookmarks[index];
                return _buildBookmarkChip(bookmark, index, recordingProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkChip(
    Map<String, dynamic> bookmark,
    int index,
    RecordingProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Helpers.getPriorityColor(
          bookmark['priority'] ?? 'medium',
        ).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Helpers.getPriorityColor(bookmark['priority'] ?? 'medium'),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Helpers.formatDuration(bookmark['timestamp']),
            style: TextStyle(
              color: Helpers.getPriorityColor(bookmark['priority'] ?? 'medium'),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (bookmark['title'] != null && bookmark['title'].isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              '• ${bookmark['title']}',
              style: TextStyle(
                color: Helpers.getPriorityColor(
                  bookmark['priority'] ?? 'medium',
                ),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => provider.removeBookmark(index),
            child: Icon(
              Icons.close,
              size: 14,
              color: Helpers.getPriorityColor(bookmark['priority'] ?? 'medium'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hentikan Rekaman?'),
        content: const Text(
          'Rekaman yang belum disimpan akan hilang. Apakah Anda yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close recording screen
            },
            child: const Text('Hentikan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddBookmarkDialog extends StatefulWidget {
  final RecordingProvider recordingProvider;

  const AddBookmarkDialog({super.key, required this.recordingProvider});

  @override
  State<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedPriority = 'medium';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Bookmark'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Waktu: ${Helpers.formatDuration(widget.recordingProvider.recordingDuration.inSeconds)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF87CEEB),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Bookmark (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Prioritas:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityOption('high', 'Tinggi', const Color(0xFFFF6B6B)),
                const SizedBox(width: 8),
                _buildPriorityOption(
                  'medium',
                  'Sedang',
                  const Color(0xFFFFD700),
                ),
                const SizedBox(width: 8),
                _buildPriorityOption('low', 'Rendah', const Color(0xFF87CEEB)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.recordingProvider.addBookmark(
              timestamp: widget.recordingProvider.recordingDuration.inSeconds,
              title: _titleController.text.trim(),
              note: _noteController.text.trim(),
              priority: _selectedPriority,
            );
            Navigator.pop(context);
            Helpers.showSnackBar(context, 'Bookmark berhasil ditambahkan!');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF87CEEB),
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(String value, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _selectedPriority == value
                ? color.withOpacity(0.2)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedPriority == value ? color : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.circle, color: color, size: 16),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: _selectedPriority == value ? color : Colors.grey,
                  fontSize: 12,
                  fontWeight: _selectedPriority == value
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SaveRecordingDialog extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final RecordingProvider recordingProvider;

  const SaveRecordingDialog({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.recordingProvider,
  });

  @override
  State<SaveRecordingDialog> createState() => _SaveRecordingDialogState();
}

class _SaveRecordingDialogState extends State<SaveRecordingDialog> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Simpan Rekaman'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Durasi: ${Helpers.formatDuration(widget.recordingProvider.recordingDuration.inSeconds)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF87CEEB),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Rekaman *',
                border: OutlineInputBorder(),
                hintText: 'Contoh: Kuliah Kalkulus - Pertemuan 1',
              ),
              maxLength: 255,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
                hintText: 'Deskripsi singkat tentang rekaman ini...',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 12),
            // TODO: Add category selection when categories are available
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: widget.titleController.text.trim().isEmpty
              ? null
              : () {
                  _saveRecording();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF87CEEB),
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _saveRecording() async {
    try {
      await widget.recordingProvider.stopRecording(
        title: widget.titleController.text.trim(),
        description: widget.descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
      );

      if (!mounted) return;

      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Close recording screen

      Helpers.showSnackBar(context, 'Rekaman berhasil disimpan!');
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(
        context,
        'Error menyimpan rekaman: $e',
        isError: true,
      );
    }
  }
}

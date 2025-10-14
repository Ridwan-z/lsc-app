import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/audio_recorder_service.dart';

class RecordingProvider with ChangeNotifier {
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  final ApiService _apiService = ApiService();

  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;
  List<double> _waveformData = [];
  List<Map<String, dynamic>> _bookmarks = [];

  Duration get recordingDuration => _recordingDuration;
  bool get isRecording => _isRecording;
  List<double> get waveformData => _waveformData;
  List<Map<String, dynamic>> get bookmarks => _bookmarks;

  RecordingProvider() {
    _initializeRecorder();
  }

  void _initializeRecorder() async {
    await _audioRecorder.initialize();
  }

  Future<void> startRecording() async {
    try {
      await _audioRecorder.startRecording();
      _isRecording = true;
      _startTimer();
      _startWaveformSimulation();
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal memulai rekaman: $e');
    }
  }

  Future<void> stopRecording({
    required String title,
    String? description,
    String? categoryId,
  }) async {
    try {
      _stopTimer();
      _stopWaveformSimulation();
      _isRecording = false;

      final audioPath = await _audioRecorder.stopRecording();
      
      if (audioPath == null) {
        throw Exception('Tidak ada file audio yang direkam');
      }

      // Simulate file upload to server
      await _simulateUploadToServer(
        audioPath: audioPath,
        title: title,
        description: description,
        categoryId: categoryId,
      );

      // Reset state
      _resetRecording();
      
    } catch (e) {
      throw Exception('Gagal menghentikan rekaman: $e');
    }
  }

  void toggleRecording() {
    if (_isRecording) {
      pauseRecording();
    } else {
      resumeRecording();
    }
  }

  void pauseRecording() {
    _audioRecorder.pauseRecording();
    _isRecording = false;
    _stopTimer();
    _stopWaveformSimulation();
    notifyListeners();
  }

  void resumeRecording() {
    _audioRecorder.resumeRecording();
    _isRecording = true;
    _startTimer();
    _startWaveformSimulation();
    notifyListeners();
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _startWaveformSimulation() {
    // Simulate waveform data for visualization
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Generate random waveform data for simulation
      final random = _waveformData.isEmpty ? 0.1 : _waveformData.last;
      final newValue = (random + (0.5 - _random().nextDouble()) * 0.3)
          .clamp(0.1, 1.0);
      
      _waveformData.add(newValue);
      
      // Keep only last 100 data points for performance
      if (_waveformData.length > 100) {
        _waveformData.removeAt(0);
      }
      
      notifyListeners();
    });
  }

  void _stopWaveformSimulation() {
    _waveformData.clear();
    notifyListeners();
  }

  Random _random() {
    return Random(DateTime.now().millisecondsSinceEpoch);
  }

  void addBookmark({
    required int timestamp,
    String? title,
    String? note,
    String priority = 'medium',
  }) {
    final bookmark = {
      'timestamp': timestamp,
      'title': title,
      'note': note,
      'priority': priority,
      'color': _getPriorityColor(priority),
      'created_at': DateTime.now(),
    };

    _bookmarks.add(bookmark);
    _bookmarks.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
    notifyListeners();
  }

  void removeBookmark(int index) {
    if (index >= 0 && index < _bookmarks.length) {
      _bookmarks.removeAt(index);
      notifyListeners();
    }
  }

  String _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return '#FF6B6B';
      case 'medium':
        return '#FFD700';
      case 'low':
        return '#87CEEB';
      default:
        return '#87CEEB';
    }
  }

  Future<void> _simulateUploadToServer({
    required String audioPath,
    required String title,
    String? description,
    String? categoryId,
  }) async {
    // Simulate API call to save recording
    await Future.delayed(const Duration(seconds: 2));

    // In real implementation, you would upload the file to your server
    // and save the recording data along with bookmarks
    print('Recording saved:');
    print('Title: $title');
    print('Duration: ${_recordingDuration.inSeconds} seconds');
    print('Bookmarks: ${_bookmarks.length}');
    print('Audio path: $audioPath');
  }

  void _resetRecording() {
    _stopTimer();
    _stopWaveformSimulation();
    _recordingDuration = Duration.zero;
    _isRecording = false;
    _waveformData.clear();
    _bookmarks.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    _audioRecorder.dispose();
    super.dispose();
  }
}

// Helper class for random number generation
class Random {
  final int seed;
  
  Random(this.seed);
  
  double nextDouble() {
    // Simple pseudo-random number generator
    final x = (seed * 9301 + 49297) % 233280;
    return x / 233280.0;
  }
}
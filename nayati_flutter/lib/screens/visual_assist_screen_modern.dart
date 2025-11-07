import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../providers/object_detection_provider.dart';
import '../utils/logger_util.dart';
import '../widgets/emergency_sos_button.dart';

class VisualAssistScreenModern extends StatefulWidget {
  const VisualAssistScreenModern({super.key});

  @override
  State<VisualAssistScreenModern> createState() =>
      _VisualAssistScreenModernState();
}

class _VisualAssistScreenModernState extends State<VisualAssistScreenModern>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isScanning = false;
  bool _isInitialized = false;
  bool _isFullscreen = false;
  Timer? _captureTimer;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopContinuousCapture();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        await _initializeCameraController();
      }
    } catch (e) {
      CameraLogger.error('Failed to initialize camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  Future<void> _initializeCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      CameraLogger.error('Failed to initialize camera controller: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera controller failed: $e')),
        );
      }
    }
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _startContinuousCapture();
    } else {
      _stopContinuousCapture();
    }
  }

  void _startContinuousCapture() {
    _captureTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _captureAndDetect();
    });
  }

  void _stopContinuousCapture() {
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_isInitialized || !_isScanning) return;

    try {
      if (!_cameraController!.value.isInitialized) {
        CameraLogger.warning('Camera not initialized, skipping capture');
        return;
      }

      final image = await _cameraController!.takePicture();
      if (!mounted) return; // Guard context use after async gap
      final provider =
          Provider.of<ObjectDetectionProvider>(context, listen: false);
      await provider.detectObjects(image.path);
    } catch (e) {
      CameraLogger.error('Failed to capture and detect: $e');
      if (e.toString().contains('Camera') ||
          e.toString().contains('Device error')) {
        _stopContinuousCapture();
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Camera error occurred. Please restart the camera.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final wasScanning = _isScanning;
      if (_isScanning) {
        setState(() {
          _isScanning = false;
        });
        _stopContinuousCapture();
      }

      await _cameraController?.dispose();
      _cameraController = null;
      _isInitialized = false;

      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

      await _initializeCameraController();

      if (wasScanning && _isInitialized) {
        if (!mounted) return; // Safety: setState after async
        setState(() {
          _isScanning = true;
        });
        _startContinuousCapture();
      }
    } catch (e) {
      CameraLogger.error('Failed to switch camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to switch camera: $e')),
        );
      }
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return _buildFullscreenView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Visual Assist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          if (_isInitialized)
            IconButton(
              icon: const Icon(Icons.fullscreen, size: 24),
              onPressed: _toggleFullscreen,
              tooltip: 'Fullscreen',
            ),
          const InlineSOSButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCameraCard(),
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 20),
            _buildControlButtons(),
            const SizedBox(height: 20),
            _buildDetectionResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen camera
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 0,
                  height: _cameraController!.value.previewSize?.width ?? 0,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            _buildCameraPlaceholder(),

          // Detection overlay
          Consumer<ObjectDetectionProvider>(
            builder: (context, detectionProvider, child) {
              return _buildDetectionOverlay(detectionProvider);
            },
          ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: _toggleFullscreen,
                        ),
                        const InlineSOSButton(),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isScanning ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isScanning
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isScanning ? 'Scanning' : 'Paused',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen_exit,
                          color: Colors.white),
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_cameras != null && _cameras!.length > 1)
                      _buildModernButton(
                        icon: Icons.switch_camera,
                        onPressed: _switchCamera,
                        tooltip: 'Switch Camera',
                      ),
                    _buildModernButton(
                      icon: Icons.camera_alt,
                      onPressed: _captureAndDetect,
                      tooltip: 'Capture & Detect',
                      isPrimary: true,
                    ),
                    _buildModernButton(
                      icon: _isScanning ? Icons.stop : Icons.play_arrow,
                      onPressed: _toggleScanning,
                      tooltip: _isScanning ? 'Stop Scanning' : 'Start Scanning',
                      backgroundColor:
                          _isScanning ? Colors.red : const Color(0xFF2563EB),
                      isPrimary: true,
                    ),
                    _buildModernButton(
                      icon: Icons.clear_all,
                      onPressed: () {
                        final provider = Provider.of<ObjectDetectionProvider>(
                            context,
                            listen: false);
                        provider.clearDetections();
                      },
                      tooltip: 'Clear Detections',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Camera preview
            if (_isInitialized && _cameraController != null)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize?.height ?? 0,
                    height: _cameraController!.value.previewSize?.width ?? 0,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else
              _buildCameraPlaceholder(),

            // Detection overlay
            Consumer<ObjectDetectionProvider>(
              builder: (context, detectionProvider, child) {
                return _buildDetectionOverlay(detectionProvider);
              },
            ),

            // Fullscreen button
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: _toggleFullscreen,
                  tooltip: 'Fullscreen',
                ),
              ),
            ),

            // Status indicator
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isScanning ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isScanning ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isScanning ? 'Scanning' : 'Paused',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<ObjectDetectionProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Objects Detected',
                '${provider.detections.length}',
                Icons.visibility,
                const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Processing Time',
                provider.processingTime > 0
                    ? '${provider.processingTime.toStringAsFixed(0)}ms'
                    : '0ms',
                Icons.speed,
                const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Camera',
                _cameras != null
                    ? '${_cameras!.length} Available'
                    : '0 Available',
                Icons.camera_alt,
                const Color(0xFFEA580C),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.camera_alt,
                label: 'Capture',
                onPressed: _captureAndDetect,
                color: const Color(0xFF2563EB),
              ),
              _buildControlButton(
                icon: _isScanning ? Icons.stop : Icons.play_arrow,
                label: _isScanning ? 'Stop' : 'Start',
                onPressed: _toggleScanning,
                color: _isScanning ? Colors.red : const Color(0xFF16A34A),
                isPrimary: true,
              ),
              if (_cameras != null && _cameras!.length > 1)
                _buildControlButton(
                  icon: Icons.switch_camera,
                  label: 'Switch',
                  onPressed: _switchCamera,
                  color: const Color(0xFFEA580C),
                ),
              _buildControlButton(
                icon: Icons.clear_all,
                label: 'Clear',
                onPressed: () {
                  final provider = Provider.of<ObjectDetectionProvider>(context,
                      listen: false);
                  provider.clearDetections();
                },
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: isPrimary ? Colors.white : color, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isPrimary ? color : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionResults() {
    return Consumer<ObjectDetectionProvider>(
      builder: (context, provider, child) {
        if (provider.detections.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 48,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No objects detected yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start scanning to detect objects',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detected Objects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.detections.length} found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.detections.map((detection) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${detection.name} (${(detection.confidence * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? backgroundColor,
    bool isPrimary = false,
  }) {
    final defaultColor = isPrimary
        ? const Color(0xFF2563EB)
        : Colors.black.withValues(alpha: 0.6);

    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor ?? defaultColor,
          elevation: 0,
          child: Icon(
            icon,
            color: Colors.white,
            size: isPrimary ? 28 : 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionOverlay(ObjectDetectionProvider detectionProvider) {
    if (detectionProvider.detections.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: DetectionPainter(detectionProvider.detections),
      child: Container(),
    );
  }
}

class DetectionPainter extends CustomPainter {
  final List<dynamic> detections;

  DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final detection in detections) {
      final bounds = detection.bounds as Map<String, double>;
      final x = bounds['x']! * size.width;
      final y = bounds['y']! * size.height;
      final width = bounds['width']! * size.width;
      final height = bounds['height']! * size.height;

      final rect = Rect.fromLTWH(x, y, width, height);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, paint);

      final label =
          '${detection.name} (${(detection.confidence * 100).toStringAsFixed(0)}%)';
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        x,
        y - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final labelPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.fill;
      canvas.drawRect(labelRect, labelPaint);

      textPainter.paint(
        canvas,
        Offset(x + 4, y - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

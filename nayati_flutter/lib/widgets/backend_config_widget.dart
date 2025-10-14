import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/config_service.dart';
import '../services/api_service.dart';
import '../utils/logger_util.dart';

class BackendConfigWidget extends StatefulWidget {
  const BackendConfigWidget({super.key});

  @override
  State<BackendConfigWidget> createState() => _BackendConfigWidgetState();
}

class _BackendConfigWidgetState extends State<BackendConfigWidget> {
  String? _currentUrl;
  bool _isLoading = false;
  bool _isTesting = false;
  String? _testResult;
  final TextEditingController _customUrlController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() => _isLoading = true);
    try {
      _currentUrl = await ConfigService.getBackendUrl();
      setState(() {});
    } catch (e) {
      AppLogger.error('Failed to load config: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load configuration: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection(String url) async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      // Temporarily set the URL for testing
      await ConfigService.setBackendUrl(url);
      await _apiService.updateBaseUrl();
      
      final result = await _apiService.testConnection();
      
      setState(() {
        _testResult = result['success'] == true 
            ? 'Connection successful! (${result['responseTime']}ms)'
            : 'Connection failed: ${result['error']}';
      });
      
      if (result['success'] == true) {
        _currentUrl = url;
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _testResult = 'Test failed: $e';
      });
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _selectConfig(ConfigOption option) async {
    if (option.isCustom) {
      _showCustomUrlDialog();
      return;
    }

    final url = option.url ?? await ConfigService.getBackendUrl();
    await _testConnection(url);
  }

  void _showCustomUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Backend URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your backend server URL:'),
            const SizedBox(height: 16),
            TextField(
              controller: _customUrlController,
              decoration: const InputDecoration(
                labelText: 'Backend URL',
                hintText: 'http://192.168.1.100:8000/api',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = _customUrlController.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                _testConnection(url);
              }
            },
            child: const Text('Test & Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Backend Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadCurrentConfig,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current URL display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Backend URL:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _currentUrl ?? 'Loading...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Configuration options
            const Text(
              'Quick Configuration:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            ...ConfigService.getAvailableConfigs().map((option) => 
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    option.isDefault ? Icons.auto_awesome : 
                    option.isCustom ? Icons.edit : Icons.computer,
                    color: option.isDefault ? Colors.green : Colors.blue,
                  ),
                  title: Text(option.name),
                  subtitle: Text(option.description),
                  trailing: option.url != null && option.url == _currentUrl
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: _isTesting 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow),
                          onPressed: _isTesting ? null : () => _selectConfig(option),
                        ),
                  onTap: _isTesting ? null : () => _selectConfig(option),
                ),
              ),
            ),
            
            // Test result
            if (_testResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.contains('successful') 
                      ? Colors.green[50] 
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testResult!.contains('successful') 
                        ? Colors.green[300]! 
                        : Colors.red[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult!.contains('successful') 
                          ? Icons.check_circle 
                          : Icons.error,
                      color: _testResult!.contains('successful') 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          color: _testResult!.contains('successful') 
                              ? Colors.green[800] 
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Configuration Tips:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Auto-detect will try to find the best backend URL\n'
                    '• Use "Custom" to enter your specific IP address\n'
                    '• Make sure your Django backend is running on the specified URL\n'
                    '• Test the connection before saving',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

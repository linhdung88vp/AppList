import 'package:flutter/material.dart';
import '../services/app_service.dart';

class UpdateProgressWidget extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final VoidCallback? onUpdateComplete;
  final VoidCallback? onUpdateFailed;

  const UpdateProgressWidget({
    super.key,
    required this.updateInfo,
    this.onUpdateComplete,
    this.onUpdateFailed,
  });

  @override
  State<UpdateProgressWidget> createState() => _UpdateProgressWidgetState();
}

class _UpdateProgressWidgetState extends State<UpdateProgressWidget> {
  double _downloadProgress = 0.0;
  String _currentStatus = 'Đang tải xuống...';
  bool _isDownloading = true;
  bool _isInstalling = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startUpdate();
  }

  Future<void> _startUpdate() async {
    try {
      // Bước 1: Tải xuống APK
      setState(() {
        _isDownloading = true;
        _currentStatus = 'Đang tải xuống bản cập nhật...';
        _downloadProgress = 0.0;
      });

      final apkPath = await AppService.downloadUpdate(
        widget.updateInfo.downloadUrl,
        (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      if (apkPath == null) {
        throw Exception('Không thể tải xuống file cập nhật');
      }

      // Bước 2: Cài đặt APK
      setState(() {
        _isDownloading = false;
        _isInstalling = true;
        _currentStatus = 'Đang cài đặt...';
        _downloadProgress = 1.0;
      });

      final installSuccess = await AppService.installApk(apkPath);

      if (installSuccess) {
        setState(() {
          _isInstalling = false;
          _currentStatus = 'Cập nhật thành công!';
        });
        
        // Đợi 2 giây rồi gọi callback
        await Future.delayed(const Duration(seconds: 2));
        widget.onUpdateComplete?.call();
      } else {
        throw Exception('Không thể cài đặt bản cập nhật');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _currentStatus = 'Lỗi cập nhật';
        _isDownloading = false;
        _isInstalling = false;
      });
      
      widget.onUpdateFailed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _hasError ? Icons.error : Icons.system_update,
            color: _hasError ? Colors.red : Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text('Cập nhật ứng dụng'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasError) ...[
            // Thông tin phiên bản
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Phiên bản mới: ${widget.updateInfo.version}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.updateInfo.changelog,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              children: [
                Text(
                  _currentStatus,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isInstalling ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_downloadProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Hiển thị lỗi
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        if (_hasError) ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onUpdateFailed?.call();
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = '';
              });
              _startUpdate();
            },
            child: const Text('Thử lại'),
          ),
        ] else if (!_isDownloading && !_isInstalling) ...[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onUpdateComplete?.call();
            },
            child: const Text('Hoàn tất'),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/gara.dart';
import '../providers/gara_provider.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import '../services/freeimage_service.dart';
import '../services/validation_service.dart';
import '../services/image_compression_service.dart';
import '../services/permission_service.dart';
import '../providers/auth_provider.dart';

class AddGaraScreen extends StatefulWidget {
  const AddGaraScreen({super.key});

  @override
  State<AddGaraScreen> createState() => _AddGaraScreenState();
}

class _AddGaraScreenState extends State<AddGaraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedStatus = 'Hoạt động';
  final List<String> _statusOptions = [
    'Hoạt động',
    'Tạm ngưng',
    'Đang sửa chữa',
  ];
  
  GeoPoint _location = const GeoPoint(0.0, 0.0);
  List<String> _imageUrls = [];
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isGettingLocation = false;
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    _initializePermissionsAndLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializePermissionsAndLocation() async {
    // Kiểm tra và yêu cầu quyền trước
    bool hasPermissions = await PermissionService.checkAndRequestPermissions(context);
    
    if (hasPermissions) {
      // Nếu có quyền, tự động lấy vị trí
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _location = GeoPoint(location['latitude']!, location['longitude']!);
        });
        
        // Lấy địa chỉ từ tọa độ
        final address = await LocationService.getAddressFromCoordinates(
          location['latitude']!,
          location['longitude']!,
        );
        if (address != null) {
          _addressController.text = address;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lấy vị trí: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Kiểm tra quyền camera trước khi chụp
      bool hasCameraPermission = await PermissionService.checkCameraPermission();
      if (!hasCameraPermission) {
        hasCameraPermission = await PermissionService.requestCameraPermission();
        if (!hasCameraPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cần quyền camera để chụp ảnh'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final photo = await CameraService.takePhoto();
      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
        await _uploadImageToImgBB(photo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Future<void> _uploadImageToImgBB(File imageFile) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      // Kiểm tra và nén ảnh nếu cần
      final bool needsCompression = await ImageCompressionService.needsCompression(imageFile);
      File processedImage = imageFile;
      
      if (needsCompression) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang nén ảnh để tối ưu upload...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
        processedImage = await ImageCompressionService.compressImageIfNeeded(imageFile);
      }
      
      final imageUrl = await FreeImageService.uploadImage(processedImage);
      if (imageUrl != null) {
        setState(() {
          _imageUrls.add(imageUrl);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(needsCompression 
                  ? 'Upload ảnh thành công! (Đã nén)'
                  : 'Upload ảnh thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload ảnh thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
      if (index < _selectedImages.length) {
        _selectedImages.removeAt(index);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Bắt buộc phải có ảnh được chụp
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Bắt buộc chụp ít nhất một ảnh gara trước khi lưu'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse số điện thoại
      final phoneText = _phoneController.text.trim();
      final phoneNumbers = phoneText
          .split(',')
          .map((phone) => phone.trim())
          .where((phone) => phone.isNotEmpty)
          .toList();

      if (phoneNumbers.isEmpty) {
        throw Exception('Vui lòng nhập ít nhất một số điện thoại');
      }

      // Kiểm tra trùng lặp trước khi thêm
      final existingGaras = context.read<GaraProvider>().garas;
      final newGara = Gara.create(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phoneNumbers: phoneNumbers,
        location: _location,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        status: _selectedStatus,
      );

      final duplicates = ValidationService.checkDuplicateGara(newGara, existingGaras);
      if (duplicates.isNotEmpty) {
        // Hiển thị dialog cảnh báo trùng lặp
        bool shouldContinue = await _showDuplicateWarningDialog(duplicates);
        if (!shouldContinue) {
          return;
        }
      }

      // Tạo gara mới với ảnh đã upload và thông tin user
      final currentUser = context.read<AuthProvider>().user;
      final garaWithImages = newGara.copyWith(
        imageUrls: _imageUrls,
        createdBy: currentUser?.uid,
        createdByEmail: currentUser?.email,
        createdByName: currentUser?.displayName,
      );

      await context.read<GaraProvider>().addGara(garaWithImages);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Thêm gara thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Sử dụng Future.delayed để tránh lỗi navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi thêm gara: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Gara Mới'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin cơ bản
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),
              
              // Tên gara
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên gara *',
                  hintText: 'Nhập tên gara',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên gara';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Chủ gara
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên chủ gara/quản lý *',
                  hintText: 'Nhập tên chủ gara hoặc người quản lý',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên chủ gara';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Số điện thoại
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  hintText: 'Nhập số điện thoại, phân cách bằng dấu phẩy',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Địa chỉ
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ *',
                  hintText: 'Nhập địa chỉ chi tiết của gara',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ gara';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trạng thái
              Row(
                children: [
                  const Text(
                    'Trạng thái: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),



              // Ghi chú
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Nhập ghi chú (không bắt buộc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Phần ảnh
              _buildSectionTitle('Ảnh gara *'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Bắt buộc chụp ảnh trực tiếp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Không được tải ảnh từ thư viện\n• Phải chụp ảnh trực tiếp tại gara\n• Ít nhất 1 ảnh để lưu gara',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nút chụp ảnh (chỉ cho phép chụp)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploadingImages ? null : _takePhoto,
                    icon: _isUploadingImages 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt, size: 24),
                    label: Text(
                      _isUploadingImages ? 'Đang upload...' : 'Chụp ảnh gara',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hiển thị ảnh đã chọn
              if (_imageUrls.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Đã chụp ${_imageUrls.length} ảnh - Có thể lưu gara',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey[600],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Hiển thị placeholder khi chưa có ảnh
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa chụp ảnh nào',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bắt buộc chụp ảnh trực tiếp để lưu gara',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Lưu Gara'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  /// Hiển thị dialog cảnh báo trùng lặp
  Future<bool> _showDuplicateWarningDialog(List<String> duplicates) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cảnh báo trùng lặp'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Phát hiện thông tin trùng lặp:'),
              const SizedBox(height: 8),
              ...duplicates.map((duplicate) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $duplicate'),
              )),
              const SizedBox(height: 16),
              const Text(
                'Bạn có muốn tiếp tục thêm gara này không?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}

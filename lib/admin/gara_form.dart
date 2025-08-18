import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gara.dart';
import '../config/firebase_config.dart';

class GaraForm extends StatefulWidget {
  final Gara? gara;
  const GaraForm({super.key, this.gara});

  @override
  State<GaraForm> createState() => _GaraFormState();
}

class _GaraFormState extends State<GaraForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _owner = TextEditingController();
  final _phones = TextEditingController();
  final _imageUrls = TextEditingController();
  String _status = 'Hoạt động';

  @override
  void initState() {
    super.initState();
    final g = widget.gara;
    if (g != null) {
      _name.text = g.name;
      _address.text = g.address;
      _owner.text = g.ownerName;
      _phones.text = g.phoneNumbers.join(', ');
      _imageUrls.text = g.imageUrls.join('\n');
      _status = g.status ?? 'Hoạt động';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gara == null ? 'Thêm gara' : 'Sửa gara')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Tên gara'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên gara' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập địa chỉ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _owner,
                decoration: const InputDecoration(labelText: 'Chủ gara'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập chủ gara' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phones,
                decoration: const InputDecoration(labelText: 'Số điện thoại (ngăn cách bằng dấu ,)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrls,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Danh sách URL ảnh (mỗi dòng 1 URL)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')),
                  DropdownMenuItem(value: 'Tạm ngưng', child: Text('Tạm ngưng')),
                  DropdownMenuItem(value: 'Đang sửa chữa', child: Text('Đang sửa chữa')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'Hoạt động'),
                decoration: const InputDecoration(labelText: 'Trạng thái'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _onSubmit,
                child: Text(widget.gara == null ? 'Tạo' : 'Lưu'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final phones = _phones.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final images = _imageUrls.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final data = {
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'ownerName': _owner.text.trim(),
      'phoneNumbers': phones,
      'imageUrls': images,
      'location': const GeoPoint(0, 0),
      'status': _status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (!FirebaseConfig.isInitialized) {
        if (mounted) Navigator.pop(context, true);
        return;
      }
      if (widget.gara?.id == null) {
        await FirebaseConfig.garasCollection.add(data);
      } else {
        await FirebaseConfig.garasCollection.doc(widget.gara!.id).update(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _form = GlobalKey<FormState>();
  late String _name;
  late String _phone;
  late String _address;
  bool _saving = false;

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'Vui lòng điền thông tin'
        : null;
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        name: _name,
        phone: _phone,
        address: _address,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa lưu được hồ sơ.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ giao hàng')),
      body: user == null
          ? const SizedBox.shrink()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    initialValue: user.name,
                    decoration: const InputDecoration(
                      labelText: 'Tên người nhận',
                    ),
                    validator: _required,
                    onSaved: (value) => _name = value!.trim(),
                  ),
                  TextFormField(
                    initialValue: user.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _required,
                    onSaved: (value) => _phone = value!.trim(),
                  ),
                  TextFormField(
                    initialValue: user.address,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ giao hàng',
                    ),
                    validator: _required,
                    onSaved: (value) => _address = value!.trim(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Lưu hồ sơ'),
                  ),
                ],
              ),
            ),
    );
  }
}

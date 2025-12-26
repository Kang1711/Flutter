import 'package:flutter/material.dart';

class EditDescriptionModal extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic> newData) onSave;

  const EditDescriptionModal({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<EditDescriptionModal> createState() => _EditDescriptionModalState();
}

class _EditDescriptionModalState extends State<EditDescriptionModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late String _selectedGender;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _birthdayController = TextEditingController(text: widget.initialData['birthday'] ?? '2000-01-01');

    final bool? genderRaw = widget.initialData['gender'] as bool?;
    _selectedGender = genderRaw == true ? 'Nam' : (genderRaw == false ? 'Nữ' : 'Nam'); 

    _selectedRole = widget.initialData['role'] ?? 'USER'; 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'birthday': _birthdayController.text,
        'gender': _selectedGender == 'Nam', 
        'role': _selectedRole,
      };
      widget.onSave(newData);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (value) => value!.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        ),
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Vui lòng chọn $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa Mô tả', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField(_nameController, 'Tên'),
              _buildTextField(_emailController, 'Email', type: TextInputType.emailAddress, validator: (value) {
                if (value == null || value.isEmpty) return 'Vui lòng nhập Email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email không hợp lệ';
                return null;
              }),
              _buildTextField(_phoneController, 'Điện thoại', type: TextInputType.phone),
              _buildTextField(_birthdayController, 'Ngày sinh (YYYY-MM-DD)', validator: (value) {
                if (value == null || value.isEmpty) return 'Vui lòng nhập Ngày sinh';
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return 'Định dạng ngày sinh không hợp lệ';
                return null;
              }),
              _buildDropdownField(
                'Giới tính',
                _selectedGender,
                const ['Nam', 'Nữ'],
                (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),
              _buildDropdownField(
                'Vai trò',
                _selectedRole,
                const ['USER', 'ADMIN'], 
                (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Hủy', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _saveForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class EditListModal extends StatefulWidget {
  final String title; 
  final List<String> initialList;
  final Function(List<String> newList) onSave;

  const EditListModal({
    super.key,
    required this.title,
    required this.initialList,
    required this.onSave,
  });

  @override
  State<EditListModal> createState() => _EditListModalState();
}

class _EditListModalState extends State<EditListModal> {
  late List<String> _editingList;
  final TextEditingController _newItemController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editingList = List.from(widget.initialList);
  }

  @override
  void dispose() {
    _newItemController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final newItem = _newItemController.text.trim();
    if (newItem.isNotEmpty && !_editingList.contains(newItem)) {
      setState(() {
        _editingList.add(newItem);
        _newItemController.clear();
        _focusNode.requestFocus(); 
      });
    } else if (_editingList.contains(newItem)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mục này đã tồn tại.')),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _editingList.removeAt(index);
    });
  }
  void _saveForm() {
    widget.onSave(_editingList); 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa ${widget.title}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: 'Thêm ${widget.title.substring(0, widget.title.length - 1)} mới',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                  onPressed: _addItem,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Các mục hiện tại:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _editingList.length,
                itemBuilder: (context, index) {
                  final item = _editingList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Hủy', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _saveForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
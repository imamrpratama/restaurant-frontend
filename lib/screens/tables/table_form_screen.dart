import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/table.dart';
import '../../providers/table_provider.dart';

class TableFormScreen extends StatefulWidget {
  final TableModel? table;

  const TableFormScreen({Key? key, this.table}) : super(key: key);

  @override
  State<TableFormScreen> createState() => _TableFormScreenState();
}

class _TableFormScreenState extends State<TableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tableNumberController;
  late TextEditingController _capacityController;
  String _status = 'available';

  @override
  void initState() {
    super.initState();
    _tableNumberController =
        TextEditingController(text: widget.table?.tableNumber ?? '');
    _capacityController =
        TextEditingController(text: widget.table?.capacity.toString() ?? '4');
    _status = widget.table?.status ?? 'available';
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TableProvider>(context, listen: false);
    final data = {
      'table_number': _tableNumberController.text.trim(),
      'capacity': int.parse(_capacityController.text),
      'status': _status,
    };

    bool success;
    if (widget.table != null) {
      success = await provider.updateTable(widget.table!.id, data);
    } else {
      success = await provider.createTable(data);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.table != null ? 'Table updated' : 'Table created',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Operation failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table != null ? 'Edit Table' : 'New Table'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tableNumberController,
              decoration: const InputDecoration(
                labelText: 'Table Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.table_bar),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter table number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
              value: _status,
              items: const [
                DropdownMenuItem(
                  value: 'available',
                  child: Text('Available'),
                ),
                DropdownMenuItem(
                  value: 'occupied',
                  child: Text('Occupied'),
                ),
                DropdownMenuItem(
                  value: 'reserved',
                  child: Text('Reserved'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            Consumer<TableProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.table != null ? 'Update' : 'Create'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

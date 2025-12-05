import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu.dart';
import '../../models/table.dart';
import '../../models/order_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/order_provider.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  TableModel? _selectedTable;
  final List<OrderItem> _orderItems = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MenuProvider>(context, listen: false).fetchMenus();
      Provider.of<TableProvider>(context, listen: false).fetchTables();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addItem(Menu menu) {
    setState(() {
      final existingIndex =
          _orderItems.indexWhere((item) => item.menuId == menu.id);

      if (existingIndex >= 0) {
        _orderItems[existingIndex] = OrderItem(
          menuId: menu.id,
          quantity: _orderItems[existingIndex].quantity + 1,
          price: menu.price,
          menu: menu,
        );
      } else {
        _orderItems.add(OrderItem(
          menuId: menu.id,
          quantity: 1,
          price: menu.price,
          menu: menu,
        ));
      }
    });
  }

  void _removeItem(int menuId) {
    setState(() {
      final index = _orderItems.indexWhere((item) => item.menuId == menuId);
      if (index >= 0) {
        if (_orderItems[index].quantity > 1) {
          _orderItems[index] = OrderItem(
            menuId: _orderItems[index].menuId,
            quantity: _orderItems[index].quantity - 1,
            price: _orderItems[index].price,
            menu: _orderItems[index].menu,
          );
        } else {
          _orderItems.removeAt(index);
        }
      }
    });
  }

  double _getTotalAmount() {
    return _orderItems.fold(0, (sum, item) => sum + item.total);
  }

  Future<void> _submitOrder() async {
    if (_selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a table'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final data = {
      'table_id': _selectedTable!.id,
      'items': _orderItems.map((item) => item.toJson()).toList(),
      'notes': _notesController.text.trim(),
    };

    final success = await provider.createOrder(data);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
      ),
      body: Column(
        children: [
          // Table Selection - FIXED
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Consumer<TableProvider>(
              builder: (context, tableProvider, _) {
                if (tableProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final availableTables = tableProvider.tables
                    .where((t) => t.status == 'available')
                    .toList();

                // Check if there are available tables
                if (availableTables.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No available tables.  Please create a table first or free up an occupied table.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Reset selected table if it's no longer available
                if (_selectedTable != null &&
                    !availableTables.any((t) => t.id == _selectedTable!.id)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedTable = null;
                    });
                  });
                }

                return DropdownButtonFormField<TableModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Table',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedTable,
                  hint: const Text('Choose a table'),
                  isExpanded: true,
                  items: availableTables.map((table) {
                    return DropdownMenuItem<TableModel>(
                      value: table,
                      child: Text(
                        'Table ${table.tableNumber} (${table.capacity} seats)',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTable = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a table';
                    }
                    return null;
                  },
                );
              },
            ),
          ),

          // Menu Selection
          Expanded(
            child: Consumer<MenuProvider>(
              builder: (context, menuProvider, _) {
                if (menuProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (menuProvider.menus.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No menus available'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => menuProvider.fetchMenus(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: menuProvider.menus.length,
                  itemBuilder: (context, index) {
                    final menu = menuProvider.menus[index];

                    if (!menu.isAvailable) {
                      return const SizedBox.shrink();
                    }

                    final orderItem = _orderItems.firstWhere(
                      (item) => item.menuId == menu.id,
                      orElse: () => OrderItem(
                        menuId: 0,
                        quantity: 0,
                        price: 0,
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(menu.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (menu.description != null)
                              Text(
                                menu.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${menu.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: orderItem.quantity > 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeItem(menu.id),
                                    color: Colors.red,
                                  ),
                                  Text(
                                    '${orderItem.quantity}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _addItem(menu),
                                    color: Colors.green,
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () => _addItem(menu),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Order Summary
          if (_orderItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_orderItems.length} item(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: Rp ${_getTotalAmount().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Extra spicy, No onions',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Consumer<OrderProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: provider.isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Place Order',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

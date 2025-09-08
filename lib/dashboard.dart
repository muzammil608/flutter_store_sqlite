import 'package:flutter/material.dart';
import 'database_helper.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;

  const DashboardPage({super.key, required this.userEmail});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  int? _editingItemId; // Track if editing an existing item

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.instance.getItems(widget.userEmail);
    setState(() {
      _items = data;
    });
  }

  Future<void> _addOrUpdateItem() async {
    final name = _itemController.text.trim();
    final qty = _quantityController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty || qty.isEmpty || priceText.isEmpty) return;

    final price = double.tryParse(priceText) ?? 0.0;

    if (_editingItemId == null) {
      // Add new item
      await DatabaseHelper.instance.insertItem(
        widget.userEmail,
        name,
        qty,
        price,
      );
    } else {
      // Update existing item
      await DatabaseHelper.instance.updateItem(
        _editingItemId!,
        name,
        qty,
        price,
      );
      _editingItemId = null;
    }

    _itemController.clear();
    _quantityController.clear();
    _priceController.clear();
    await _loadItems();
  }

  void _editItem(Map<String, dynamic> item) {
    _itemController.text = item['itemName'];
    _quantityController.text = item['quantity'];
    _priceController.text = item['price'].toString();
    _editingItemId = item['id'] as int;
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome, ${widget.userEmail}!",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _styledInput("Item Name", _itemController, Icons.shopping_bag),
                const SizedBox(height: 14),
                _styledInput(
                  "Quantity",
                  _quantityController,
                  Icons.confirmation_number,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _styledInput(
                  "Price",
                  _priceController,
                  Icons.attach_money,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _addOrUpdateItem,
                  child: Text(
                    _editingItemId == null ? "Add Item" : "Update Item",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Saved Items",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _items.isEmpty
                    ? const Text(
                        "No items yet. Add something.",
                        style: TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        children: _items.map((item) {
                          return Card(
                            color: Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['itemName'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Qty: ${item['quantity']} | Rs.${item['price']}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _editItem(item),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueAccent,
                                        ),
                                        label: const Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Colors.blueAccent,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _deleteItem(item['id'] as int),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        label: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../constants/app_constants.dart';

class CustomerProvider extends ChangeNotifier {
  late Box<Customer> _box;
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  // Get customer names for dropdown
  List<String> get customerNames =>
      _customers.map((c) => c.nama).toList()..sort();

  CustomerProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Customer>(AppConstants.hiveBoxCustomers);
    await loadCustomers();
    await _initializeDefaultCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    _customers = _box.values.toList();
    _customers.sort((a, b) => a.nama.compareTo(b.nama));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _initializeDefaultCustomers() async {
    if (_box.isEmpty) {
      for (final name in AppConstants.defaultCustomerNames) {
        final customer = Customer(
          id: DateTime.now().millisecondsSinceEpoch.toString() + name.hashCode.toString(),
          nama: name,
        );
        await _box.put(customer.id, customer);
      }
      await loadCustomers();
    }
  }

  Future<Customer> addOrGetCustomer(String nama) async {
    // Check if customer exists
    final existing = _customers.firstWhere(
      (c) => c.nama.toLowerCase() == nama.toLowerCase(),
      orElse: () => Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
      ),
    );

    // If new customer, add to database
    if (!_customers.contains(existing)) {
      await _box.put(existing.id, existing);
      await loadCustomers();
    }

    return existing;
  }

  Future<void> updateCustomer(Customer customer) async {
    await _box.put(customer.id, customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
    await loadCustomers();
  }

  Customer? getCustomerById(String id) {
    return _box.get(id);
  }
}

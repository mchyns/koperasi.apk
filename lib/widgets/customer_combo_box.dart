import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/customer_provider.dart';

/// Widget ComboBox yang menggabungkan Dropdown dan TextField
/// Bisa memilih customer yang sudah ada atau mengetik nama baru
class CustomerComboBox extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  const CustomerComboBox({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<CustomerComboBox> createState() => _CustomerComboBoxState();
}

class _CustomerComboBoxState extends State<CustomerComboBox> {
  late TextEditingController _controller;
  bool _isDropdownMode = true;
  String? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _selectedCustomer = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchToTextField() {
    setState(() {
      _isDropdownMode = false;
      _controller.text = _selectedCustomer ?? '';
    });
  }

  void _switchToDropdown() {
    setState(() {
      _isDropdownMode = true;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        final customerNames = customerProvider.customerNames;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _isDropdownMode
                      ? _buildDropdown(customerNames)
                      : _buildTextField(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isDropdownMode ? Icons.edit : Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                  onPressed: widget.enabled
                      ? () {
                          if (_isDropdownMode) {
                            _switchToTextField();
                          } else {
                            _switchToDropdown();
                          }
                        }
                      : null,
                  tooltip: _isDropdownMode
                      ? 'Ketik nama baru'
                      : 'Pilih dari daftar',
                ),
              ],
            ),
            if (widget.errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(List<String> customerNames) {
    return DropdownButtonFormField<String>(
      initialValue: customerNames.contains(_selectedCustomer)
          ? _selectedCustomer
          : null,
      decoration: InputDecoration(
        labelText: 'Nama Pembeli',
        prefixIcon: const Icon(Icons.person_outline),
        errorText: widget.errorText,
      ),
      items: customerNames.map((name) {
        return DropdownMenuItem(
          value: name,
          child: Text(name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: widget.enabled
          ? (value) {
              setState(() {
                _selectedCustomer = value;
              });
              if (value != null) {
                widget.onChanged(value);
              }
            }
          : null,
      isExpanded: true,
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: 'Nama Pembeli (Ketik Baru)',
        prefixIcon: const Icon(Icons.person_add_outlined),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              )
            : null,
        errorText: widget.errorText,
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: widget.onChanged,
    );
  }
}

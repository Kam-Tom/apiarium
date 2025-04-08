import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class AddHiveTypeModal extends StatefulWidget {
  const AddHiveTypeModal({
    super.key,
  });

  @override
  State<AddHiveTypeModal> createState() => _AddHiveTypeModalState();
}

class _AddHiveTypeModalState extends State<AddHiveTypeModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _frameStandardController = TextEditingController();
  final _frameWidthController = TextEditingController();
  final _frameHeightController = TextEditingController();
  final _broodFrameWidthController = TextEditingController();
  final _broodFrameHeightController = TextEditingController();
  final _frameCountController = TextEditingController();
  final _broodBoxCountController = TextEditingController();
  final _honeySuperBoxCountController = TextEditingController();
  
  // Cost controllers
  final _hiveCostController = TextEditingController();
  final _frameUnitCostController = TextEditingController();
  final _broodFrameUnitCostController = TextEditingController();
  final _broodBoxUnitCostController = TextEditingController();
  final _honeySuperBoxUnitCostController = TextEditingController();
  
  final _countryController = TextEditingController();

  HiveMaterial _mainMaterial = HiveMaterial.wood;
  bool _hasFrames = true;
  Currency _currency = Currency.usd;
  bool _isStarred = false;

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _frameStandardController.dispose();
    _frameWidthController.dispose();
    _frameHeightController.dispose();
    _broodFrameWidthController.dispose();
    _broodFrameHeightController.dispose();
    _frameCountController.dispose();
    _broodBoxCountController.dispose();
    _honeySuperBoxCountController.dispose();
    _hiveCostController.dispose();
    _frameUnitCostController.dispose();
    _broodFrameUnitCostController.dispose();
    _broodBoxUnitCostController.dispose();
    _honeySuperBoxUnitCostController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Hive Type'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: Icon(
                        _isStarred ? Icons.star : Icons.star_border,
                        color: _isStarred ? Colors.amber : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _isStarred = !_isStarred;
                        });
                      },
                      tooltip: 'Add to favorites'.tr(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Basic Information Section
                _buildSectionTitle('Basic Information'.tr()),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name'.tr(),
                  hint: 'Langstroth, Dadant, etc.'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _manufacturerController,
                  label: 'Manufacturer'.tr(),
                  hint: 'Optional'.tr(),
                ),
                _buildTextField(
                  controller: _countryController,
                  label: 'Country of Origin'.tr(),
                  hint: 'Optional'.tr(),
                ),
                
                _buildMaterialDropdown(),
                
                const SizedBox(height: 16),
                
                // Frames Information Section
                _buildSectionTitle('Frames Information'.tr()),
                SwitchListTile(
                  title: Text('Has Frames'.tr()),
                  value: _hasFrames,
                  onChanged: (value) {
                    setState(() {
                      _hasFrames = value;
                    });
                  },
                ),
                
                if (_hasFrames) ...[
                  _buildTextField(
                    controller: _frameStandardController,
                    label: 'Frame Standard'.tr(),
                    hint: 'Hoffmann, etc.'.tr(),
                  ),
                  _buildNumberField(
                    controller: _frameCountController,
                    label: 'Default Frame Count'.tr(),
                    hint: 'E.g. 10'.tr(),
                    isInteger: true,
                  ),
                  
                  // Box counts
                  _buildTextField(
                    controller: _broodBoxCountController,
                    label: 'Brood Box Count'.tr(),
                    hint: 'E.g. 1-2'.tr(),
                  ),
                  
                  _buildTextField(
                    controller: _honeySuperBoxCountController,
                    label: 'Honey Super Box Count'.tr(),
                    hint: 'E.g. 1-3'.tr(),
                  ),
                  
                  // Frame dimensions - restructured
                  _buildDimensionsField(
                    title: 'Frame',
                    widthController: _frameWidthController,
                    heightController: _frameHeightController,
                  ),
                  
                  // Brood frame dimensions - restructured
                  _buildDimensionsField(
                    title: 'Brood Frame',
                    widthController: _broodFrameWidthController,
                    heightController: _broodFrameHeightController,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Cost Information Section
                _buildSectionTitle('Cost Information'.tr()),
                
                // Hive cost with integrated currency dropdown on the right
                _buildCurrencyField(
                  controller: _hiveCostController,
                  label: 'Hive Cost'.tr(),
                  hint: '0.00',
                  currencyValue: _currency,
                  onCurrencyChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _currency = value;
                      });
                    }
                  },
                  theme: Theme.of(context),
                ),
                
                // Frame unit costs
                _buildNumberField(
                  controller: _frameUnitCostController,
                  label: 'Frame Unit Cost'.tr(),
                  hint: '0.00',
                  prefixText: _getCurrencySymbol(_currency),
                ),
                
                _buildNumberField(
                  controller: _broodFrameUnitCostController,
                  label: 'Brood Frame Unit Cost'.tr(),
                  hint: '0.00',
                  prefixText: _getCurrencySymbol(_currency),
                ),
                
                // Box unit costs
                _buildNumberField(
                  controller: _broodBoxUnitCostController,
                  label: 'Brood Box Unit Cost'.tr(),
                  hint: '0.00',
                  prefixText: _getCurrencySymbol(_currency),
                ),
                
                _buildNumberField(
                  controller: _honeySuperBoxUnitCostController,
                  label: 'Honey Super Box Unit Cost'.tr(),
                  hint: '0.00',
                  prefixText: _getCurrencySymbol(_currency),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveHiveType,
                      child: Text('Save'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
  
  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isInteger = false,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          prefixText: prefixText,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // Only allow positive numbers with optional decimal
          isInteger 
              ? FilteringTextInputFormatter.digitsOnly
              : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (isInteger) {
              final intValue = int.tryParse(value);
              if (intValue == null) {
                return 'Must be a whole number'.tr();
              }
              if (intValue <= 0) {
                return 'Must be greater than zero'.tr();
              }
            } else {
              final doubleValue = double.tryParse(value);
              if (doubleValue == null) {
                return 'Must be a number'.tr();
              }
              if (doubleValue < 0) {
                return 'Must not be negative'.tr();
              }
            }
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Currency currencyValue,
    required void Function(Currency?) onCurrencyChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          // Currency dropdown on the right
          suffixIcon: Container(
            width: 70,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1.0,
                ),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Currency>(
                value: currencyValue,
                isDense: true,
                isExpanded: true,
                alignment: AlignmentDirectional.center,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                padding: const EdgeInsets.only(left: 8, right: 4),
                items: Currency.values.map((currency) => DropdownMenuItem(
                  value: currency,
                  child: Text(
                    currency.name.toUpperCase(),
                    style: theme.textTheme.bodySmall,
                  ),
                )).toList(),
                onChanged: onCurrencyChanged,
              ),
            ),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final doubleValue = double.tryParse(value);
            if (doubleValue == null) {
              return 'Must be a number'.tr();
            }
            if (doubleValue < 0) {
              return 'Must not be negative'.tr();
            }
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildMaterialDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<HiveMaterial>(
        decoration: const InputDecoration(
          labelText: 'Main Material',
          border: OutlineInputBorder(),
        ),
        value: _mainMaterial,
        items: HiveMaterial.values.map((material) => DropdownMenuItem<HiveMaterial>(
          value: material,
          child: Row(
            children: [
              _getMaterialIcon(material),
              const SizedBox(width: 8),
              Text(material.name.toUpperCase()),
            ],
          ),
        )).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _mainMaterial = value;
            });
          }
        },
      ),
    );
  }
  
  Widget _getMaterialIcon(HiveMaterial material) {
    IconData iconData;
    Color iconColor;
    
    switch (material) {
      case HiveMaterial.wood:
        iconData = Icons.forest;
        iconColor = Colors.brown.shade700;
        break;
      case HiveMaterial.plastic:
        iconData = Icons.local_mall;
        iconColor = Colors.blue.shade700;
        break;
      case HiveMaterial.metal:
        iconData = Icons.bubble_chart;
        iconColor = Colors.white;
        break;
      case HiveMaterial.polystyrene:
        iconData = Icons.card_giftcard;
        iconColor = Colors.red.shade300;
        break;
      case HiveMaterial.other:
        iconData = Icons.layers;
        iconColor = Colors.green.shade700;
        break;
    }
    
    return Icon(
      iconData, 
      color: iconColor,
      size: 22,
    );
  }
  
  String _getCurrencySymbol(Currency currency) {
    switch (currency) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.jpy:
        return '¥';
      case Currency.pln:
        return 'zł ';
      default:
        return '\$';
    }
  }
  
  void _saveHiveType() {
    if (_formKey.currentState!.validate()) {
      final hiveType = HiveType(
        id: '', // Will be generated by repository
        name: _nameController.text.trim(),
        manufacturer: _manufacturerController.text.isEmpty ? null : _manufacturerController.text.trim(),
        mainMaterial: _mainMaterial,
        hasFrames: _hasFrames,
        defaultFrameCount: _hasFrames && _frameCountController.text.isNotEmpty 
            ? int.tryParse(_frameCountController.text) 
            : null,
        frameWidth: _hasFrames && _frameWidthController.text.isNotEmpty 
            ? double.tryParse(_frameWidthController.text) 
            : null,
        frameHeight: _hasFrames && _frameHeightController.text.isNotEmpty 
            ? double.tryParse(_frameHeightController.text) 
            : null,
        broodFrameWidth: _hasFrames && _broodFrameWidthController.text.isNotEmpty 
            ? double.tryParse(_broodFrameWidthController.text) 
            : null,
        broodFrameHeight: _hasFrames && _broodFrameHeightController.text.isNotEmpty 
            ? double.tryParse(_broodFrameHeightController.text) 
            : null,
        frameStandard: _hasFrames && _frameStandardController.text.isNotEmpty 
            ? _frameStandardController.text.trim() 
            : null,
        broodBoxCount: _hasFrames && _broodBoxCountController.text.isNotEmpty
            ? _broodBoxCountController.text.trim()
            : null,
        honeySuperBoxCount: _hasFrames && _honeySuperBoxCountController.text.isNotEmpty
            ? _honeySuperBoxCountController.text.trim()
            : null,
        hiveCost: _hiveCostController.text.isNotEmpty 
            ? double.tryParse(_hiveCostController.text) 
            : null,
        currency: _hiveCostController.text.isNotEmpty ? _currency : null,
        frameUnitCost: _frameUnitCostController.text.isNotEmpty 
            ? double.tryParse(_frameUnitCostController.text) 
            : null,
        broodFrameUnitCost: _broodFrameUnitCostController.text.isNotEmpty
            ? double.tryParse(_broodFrameUnitCostController.text)
            : null,
        broodBoxUnitCost: _broodBoxUnitCostController.text.isNotEmpty
            ? double.tryParse(_broodBoxUnitCostController.text)
            : null,
        honeySuperBoxUnitCost: _honeySuperBoxUnitCostController.text.isNotEmpty
            ? double.tryParse(_honeySuperBoxUnitCostController.text)
            : null,
        country: _countryController.text.isEmpty ? null : _countryController.text.trim(),
        isStarred: _isStarred,
      );
      
      Navigator.of(context).pop(hiveType);
    }
  }
  
  Widget _buildDimensionsField({
    required String title,
    required TextEditingController widthController,
    required TextEditingController heightController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              '$title (cm)'.tr(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: widthController,
                  decoration: InputDecoration(
                    labelText: 'Width'.tr(),
                    hintText: '0.0',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue == null) {
                        return 'Must be a number'.tr();
                      }
                      if (doubleValue < 0) {
                        return 'Must not be negative'.tr();
                      }
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                child: Text(
                  '×',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: heightController,
                  decoration: InputDecoration(
                    labelText: 'Height'.tr(),
                    hintText: '0.0',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue == null) {
                        return 'Must be a number'.tr();
                      }
                      if (doubleValue < 0) {
                        return 'Must not be negative'.tr();
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

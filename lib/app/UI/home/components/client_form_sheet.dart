import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math';

class ClientFormSheet extends StatefulWidget {
  final ClientModel? client;
  const ClientFormSheet({super.key, this.client});

  @override
  State<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<ClientFormSheet> {
  static final Random _random = Random();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _numberController;

  String? _photoPath;
  String? _addressId;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _nameController = TextEditingController(text: client?.name);
    _descriptionController = TextEditingController(text: client?.description);
    _cpfController = TextEditingController(text: client?.cpf);
    _phoneController = TextEditingController(text: client?.phoneNumber);
    _streetController = TextEditingController(text: client?.address?.street);
    _neighborhoodController =
        TextEditingController(text: client?.address?.neighborhood);
    _numberController =
        TextEditingController(text: client?.address?.number.toString());
    _photoPath = client?.photoPath;
    _addressId = client?.address?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _neighborhoodController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  bool _validateCPF(String cpf) {
    final cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCPF.length != 11) return false;

    if (RegExp(r'^(\d)\1+$').hasMatch(cleanCPF)) return false;

    List<int> digits = cleanCPF.split('').map((d) => int.parse(d)).toList();

    // Validate 1st digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int res = (sum * 10) % 11;
    if (res == 10) res = 0;
    if (res != digits[9]) return false;

    // Validate 2nd digit
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    res = (sum * 10) % 11;
    if (res == 10) res = 0;
    if (res != digits[10]) return false;

    return true;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _photoPath = picked.path;
    });
  }

  Future<void> _openPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  width: 24,
                  height: 24,
                ),
                title: const Text('Tirar foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Escolher da galeria'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickPhoto(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Remover foto',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _photoPath = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final number = int.tryParse(_numberController.text.trim()) ?? 0;
    final isEdit = widget.client != null;
    final clientId = widget.client?.id ?? _generateUuidV4();

    Navigator.of(context).pop(
      ClientModel(
        id: clientId,
        userId: widget.client?.userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        cpf: _cpfController.text.trim(),
        photoPath: _photoPath,
        address: AddressModel(
          id: _addressId,
          clientId: clientId,
          street: _streetController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          number: number,
        ),
      ),
    );
  }

  String _generateUuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String toHex(int value) => value.toRadixString(16).padLeft(2, '0');

    return [
      bytes.sublist(0, 4).map(toHex).join(),
      bytes.sublist(4, 6).map(toHex).join(),
      bytes.sublist(6, 8).map(toHex).join(),
      bytes.sublist(8, 10).map(toHex).join(),
      bytes.sublist(10, 16).map(toHex).join(),
    ].join('-');
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.onSecondary.withOpacity(0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.tertiary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _field({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: _inputDecoration(theme).copyWith(
            counterText: "",
          ),
        ),
      ],
    );
  }

  Widget _photoButton(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: _openPhotoOptions,
      child: SizedBox(
        width: 31,
        height: 31,
        child: SvgPicture.asset(
          'assets/icons/camera.svg',
          width: 31,
          height: 31,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 0.88,
      alignment: Alignment.bottomCenter,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.client == null
                                ? 'Cadastrar cliente'
                                : 'Editar cliente',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _photoButton(theme),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          width: 140,
                          child: ElevatedButtomCustom(
                            theme: theme,
                            onPressed: _save,
                            title:
                                widget.client == null
                                    ? 'Salvar'
                                    : 'Salvar alterações',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _field(
                      theme: theme,
                      controller: _nameController,
                      label: 'Nome',
                      onChanged: (_) => setState(() {}),
                      validator:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe o nome'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      theme: theme,
                      controller: _descriptionController,
                      label: 'Descricao',
                      validator:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe a descricao'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      theme: theme,
                      controller: _cpfController,
                      label: 'CPF',
                      keyboardType: TextInputType.number,
                      maxLength: 14, // 000.000.000-00
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o CPF';
                        }
                        if (!_validateCPF(value)) {
                          return 'CPF inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _field(
                      theme: theme,
                      controller: _phoneController,
                      label: 'Telefone',
                      keyboardType: TextInputType.phone,
                      maxLength: 15, // (00) 00000-0000
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PhoneInputFormatter(),
                      ],
                      validator:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe o telefone'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Endereco',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.onSecondary.withOpacity(
                            0.28,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _field(
                            theme: theme,
                            controller: _streetController,
                            label: 'Rua',
                            validator:
                                (value) =>
                                    (value == null || value.trim().isEmpty)
                                        ? 'Informe a rua'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _field(
                                  theme: theme,
                                  controller: _neighborhoodController,
                                  label: 'Bairro',
                                  validator:
                                      (value) =>
                                          (value == null ||
                                                  value.trim().isEmpty)
                                              ? 'Informe o bairro'
                                              : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: _field(
                                  theme: theme,
                                  controller: _numberController,
                                  label: 'N°',
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (value) =>
                                          (value == null ||
                                                  value.trim().isEmpty)
                                              ? 'Informe o numero'
                                              : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final index = i + 1;
      if (index == 3 || index == 6) {
        if (index != text.length) buffer.write('.');
      } else if (index == 9) {
        if (index != text.length) buffer.write('-');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 0) buffer.write('(');
      buffer.write(text[i]);
      final index = i + 1;
      if (index == 2) {
        buffer.write(') ');
      } else if (index == 7) {
        buffer.write('-');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

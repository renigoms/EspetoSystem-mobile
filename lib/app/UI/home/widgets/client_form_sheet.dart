import 'package:espetosystem/app/UI/home/components/masks_fields.dart';
import 'package:espetosystem/app/UI/home/components/modal_custom.dart';
import 'package:espetosystem/app/UI/home/components/validations.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ClientFormSheet extends StatefulWidget {
  final ClientModel? client;
  const ClientFormSheet({super.key, this.client});

  @override
  State<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  // final _imagePicker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _numberController;
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
    _neighborhoodController = TextEditingController(
      text: client?.address?.neighborhood,
    );
    _numberController = TextEditingController(
      text: client?.address?.number.toString(),
    );
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

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final number = int.tryParse(_numberController.text.trim()) ?? 0;
    // final isEdit = widget.client != null;
    // final clientId = widget.client?.id ?? _generateUuidV4();
    final clientId = widget.client?.id ?? Uuid().v4();

    Navigator.of(context).pop(
      ClientModel(
        id: clientId,
        userId: widget.client?.userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        cpf: _cpfController.text.trim(),
        photoPath: context.read<HomeViewModel>().photoPath,
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
          decoration: _inputDecoration(theme).copyWith(counterText: ""),
        ),
      ],
    );
  }

  Widget _photoButton(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => openPhotoOptions(context),
      // onTap: _openPhotoOptions,
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
                        if (!validateCPF(value)) {
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

import 'package:espetosystem/app/UI/home/components/masks_fields.dart';
import 'package:espetosystem/app/UI/home/components/validations.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/UI/home/widgets/photo_button.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String? _validate(String message, String? value) =>
      value == null || value.trim().isEmpty ? message : null;

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
                  spacing: 12,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      spacing: 12,
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
                        PhotoButton(),
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
                    DefaultFormField(
                      name: "Nome",
                      controller: _nameController,
                      theme: theme,
                      validate:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe o nome'
                                  : null,
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DefaultFormField(
                      name: "Descrição",
                      controller: _descriptionController,
                      theme: theme,
                      validate:
                          (value) => _validate('Informe a descricao', value),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Column(
                      spacing: 5,
                      children: [
                        DefaultFormField(
                          name: "CPF",
                          controller: _cpfController,
                          theme: theme,
                          keyboardType: TextInputType.number,
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLength: 14,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],
                          validate: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o CPF';
                            }
                            if (!validateCPF(value)) {
                              return 'CPF inválido';
                            }
                            return null;
                          },
                        ),
                        DefaultFormField(
                          name: "Telefone",
                          controller: _phoneController,
                          theme: theme,
                          keyboardType: TextInputType.number,
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLength: 15,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            PhoneInputFormatter(),
                          ],
                          validate:
                              (value) => _validate("Informe o Telefone", value),
                        ),
                      ],
                    ),

                    Text(
                      'Endereço',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.onSecondary.withValues(
                            alpha: 0.28,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          DefaultFormField(
                            name: "Rua",
                            controller: _streetController,
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            theme: theme,
                            validate:
                                (value) => _validate("Informe a rua", value),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DefaultFormField(
                                  name: "Bairro",
                                  controller: _neighborhoodController,
                                  labelStyle: theme.textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  theme: theme,
                                  validate:
                                      (value) =>
                                          _validate("Informe o bairro", value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: DefaultFormField(
                                  name: "N°",
                                  controller: _numberController,
                                  labelStyle: theme.textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  theme: theme,
                                  validate:
                                      (value) => _validate(
                                        "Informe o número residencial",
                                        value,
                                      ),
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

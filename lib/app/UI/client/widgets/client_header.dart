import 'package:espetosystem/app/UI/client/widgets/info_line.dart';
import 'package:espetosystem/app/UI/home/widgets/client_avatar.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';

class ClientHeader extends StatelessWidget {
  final ClientModel client;

  const ClientHeader({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = _formatAddress(client.address);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.tertiary),
          ),
          child: ClientAvatar(
            name: client.name,
            photoPath: client.photoPath,
            size: 80,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLine(label: 'Nome:', value: client.name),
              const SizedBox(height: 5),
              InfoLine(
                label: 'Descrição:',
                value: client.description,
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 12,
                runSpacing: 5,
                children: [
                  InfoLine(label: 'cpf:', value: client.cpf),
                  InfoLine(label: 'Telefone:', value: client.phoneNumber),
                ],
              ),
              const SizedBox(height: 5),
              InfoLine(label: 'Endereço:', value: address),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatAddress(AddressModel? address) {
    if (address == null) {
      return 'Rua Jose Vidal, Centro, 102';
    }

    final street = address.street.trim();
    final neighborhood = address.neighborhood.trim();
    final number = address.number;

    return [
      if (street.isNotEmpty) street,
      if (neighborhood.isNotEmpty) neighborhood,
      if (number > 0) number.toString(),
    ].join(', ');
  }
}

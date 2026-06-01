import 'package:espetosystem/app/UI/home/widgets/client_avatar.dart';
import 'package:espetosystem/app/core/colors/app_colors.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientDetailsPage extends StatelessWidget {
  const ClientDetailsPage({super.key, required this.client});

  final ClientModel? client;

  @override
  Widget build(BuildContext context) {
    final currentClient = client ?? _fallbackClient;

    return Scaffold(
      backgroundColor: AppColorsEnum.jetblack.color,
      appBar: AppBar(
        backgroundColor: AppColorsEnum.jetblack.color,
        elevation: 0,
        toolbarHeight: 44,
        titleSpacing: 0,
        title: const Text(
          'Compras',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        foregroundColor: Colors.white70,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
                children: [
                  const _LogoHeader(),
                  const SizedBox(height: 14),
                  _ClientHeader(client: currentClient),
                  const SizedBox(height: 22),
                  const _SummaryRow(),
                  const SizedBox(height: 26),
                  const _ItemsTitle(),
                  const SizedBox(height: 14),
                  ..._previewItems.map(
                    (item) => _PurchasedItemTile(item: item),
                  ),
                ],
              ),
            ),
            const _BottomBar(selectedIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo_icon.png',
          width: 22,
          height: 22,
          errorBuilder:
              (_, __, ___) => const Icon(
                LucideIcons.flameKindling,
                color: Colors.white,
                size: 18,
              ),
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: 'Espeto',
                style: TextStyle(color: AppColorsEnum.lobsterpink.color),
              ),
              TextSpan(
                text: 'System',
                style: TextStyle(color: AppColorsEnum.twitterblue.color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client});

  final ClientModel client;

  @override
  Widget build(BuildContext context) {
    final address = _formatAddress(client.address);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColorsEnum.twitterblue.color),
          ),
          child: ClientAvatar(
            name: client.name,
            photoPath: client.photoPath,
            size: 58,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Nome:', value: client.name),
              const SizedBox(height: 5),
              _InfoLine(
                label: 'Descricao:',
                value: '${client.description} ${client.phoneNumber}',
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              _InfoLine(label: 'Endereco:', value: address),
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: value),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        height: 1.18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Vendido',
            value: 'R\$ 100,00',
            color: Color(0xFF1F1F1F),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Ja Pago',
            value: 'R\$ 50,00',
            color: Color(0xFF0078D7),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Falta Pagar',
            value: 'R\$ 50,00',
            color: Color(0xFFD9534F),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsTitle extends StatelessWidget {
  const _ItemsTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Itens Comprados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Adicionar item',
          icon: const Icon(
            LucideIcons.badgePlus,
            color: Colors.white,
            size: 19,
          ),
        ),
      ],
    );
  }
}

class _PurchasedItemTile extends StatelessWidget {
  const _PurchasedItemTile({required this.item});

  final _PurchasedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColorsEnum.carbomblack.color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${item.quantity}x',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.description,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
      color: AppColorsEnum.carbomblack.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: 'Compras',
            icon: LucideIcons.shoppingCart,
            selected: selectedIndex == 0,
          ),
          _NavItem(
            label: 'Pagamentos',
            icon: LucideIcons.banknote,
            selected: selectedIndex == 1,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? Colors.white : Colors.white70;
    final labelColor = selected ? Colors.white : Colors.white70;

    return SizedBox(
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  selected
                      ? AppColorsEnum.twitterblue.color
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchasedItem {
  const _PurchasedItem({
    required this.quantity,
    required this.description,
    required this.value,
  });

  final int quantity;
  final String description;
  final String value;
}

const _previewItems = [
  _PurchasedItem(
    quantity: 1,
    description: 'Cola p/ cano PVC',
    value: 'R\$ 10,00',
  ),
  _PurchasedItem(
    quantity: 1,
    description: 'Cola p/ cano PVC',
    value: 'R\$ 10,00',
  ),
  _PurchasedItem(
    quantity: 1,
    description: 'Cola p/ cano PVC',
    value: 'R\$ 10,00',
  ),
  _PurchasedItem(
    quantity: 1,
    description: 'Cola p/ cano PVC',
    value: 'R\$ 10,00',
  ),
  _PurchasedItem(
    quantity: 1,
    description: 'Cola p/ cano PVC',
    value: 'R\$ 10,00',
  ),
  _PurchasedItem(
    quantity: 1,
    description: 'Saco de cimento 50kg',
    value: 'R\$ 50,00',
  ),
];

final ClientModel _fallbackClient = ClientModel(
  id: 'preview',
  name: 'Joao Silva',
  description: 'Mora vizinho a rua das flores, bairro novo.',
  phoneNumber: '(99) 99999-9999',
  cpf: '999.999.999-99',
  photoPath: null,
  address: AddressModel(
    street: 'Rua Jose Vidal',
    neighborhood: 'Centro',
    number: 102,
  ),
);

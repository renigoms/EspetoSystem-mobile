import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:flutter/services.dart';
import 'package:espetosystem/app/UI/home/widgets/client_form_sheet.dart';
import 'package:espetosystem/app/UI/home/widgets/client_avatar.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';

class ClientDetailsShellPage extends StatefulWidget {
  const ClientDetailsShellPage({
    super.key,
    required this.navigationShell,
    required this.client,
  });

  final StatefulNavigationShell navigationShell;
  final ClientModel? client;

  @override
  State<ClientDetailsShellPage> createState() => _ClientDetailsShellPageState();
}

class _ClientDetailsShellPageState extends State<ClientDetailsShellPage> {
  late ClientModel _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? _fallbackClient;
  }

  @override
  void didUpdateWidget(ClientDetailsShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newClient = widget.client;

    if (newClient != null && newClient != oldWidget.client) {
      _client = newClient;
    }
  }

  Future<void> _showClientSettings(
    BuildContext context,
    ThemeData theme,
    ClientModel client,
  ) async {
    // 1. Mostra o primeiro menu de opções e aguarda a escolha do usuário
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  LucideIcons.edit,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text('Editar dados'),
                onTap: () => Navigator.of(ctx).pop('edit'),
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.trash2,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Excluir cliente',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => Navigator.of(ctx).pop('delete'),
              ),
            ],
          ),
        );
      },
    );

    // Se o usuário tocou fora, action será nula
    if (action == null || !context.mounted) return;

    if (action == 'edit') {
      // 2. Mostra o formulário de edição usando o contexto seguro da tela principal
      final result = await showModalBottomSheet<ClientModel>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => ClientFormSheet(client: client),
      );

      debugPrint(
        'DEBUG: Formulário de edição fechou. Retornou: ${result?.name}',
      );

      if (result != null && context.mounted) {
        final viewModel = context.read<HomeViewModel>();
        debugPrint('DEBUG: Chamando viewModel.saveClient...');
        final savedClient = await viewModel.saveClient(result);
        debugPrint('DEBUG: viewModel retornou: ${savedClient?.name}');

        if (savedClient != null && mounted) {
          setState(() {
            debugPrint('DEBUG: Atualizando o UI com o cliente atualizado.');
            _client = savedClient;
          });
        }
      }
    } else if (action == 'delete') {
      // Lógica de exclusão (inalterada, mas agora em um contexto seguro)
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => Dialog(
              backgroundColor: theme.colorScheme.secondary,
              insetPadding: const EdgeInsets.all(24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excluir cliente',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Tem certeza que deseja excluir este cliente? Esta ação não pode ser desfeita.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Excluir',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );

      if (confirm == true && context.mounted) {
        final viewModel = context.read<HomeViewModel>();
        if (client.id != null) {
          await viewModel.deleteClient(client.id!);
          if (context.mounted) {
            context.go('/home');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ClientDetailsScope(
      client: _client,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 75,
            titleSpacing: 16,
            backgroundColor: theme.colorScheme.primary,
            title: _LogoHeader(theme),
            actions: [
              IconButton(
                onPressed: () => _showClientSettings(context, theme, _client),
                icon: Icon(
                  LucideIcons.settings,
                  color: theme.colorScheme.tertiary,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () => context.go('/home'),
                icon: Icon(
                  LucideIcons.home,
                  color: theme.colorScheme.tertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(child: widget.navigationShell),
              _BottomBar(navigationShell: widget.navigationShell),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientDetailsPage extends StatefulWidget {
  const ClientDetailsPage({super.key});

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Carrega os dados apenas uma vez ao entrar na tela
    Future.microtask(() {
      if (mounted) {
        final client = _ClientDetailsScope.clientOf(context);
        if (client.id != null) {
          context.read<HomeViewModel>().loadItemsForClient(client.id!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = _ClientDetailsScope.clientOf(context);
    // Observa o ViewModel para reconstruir a lista automaticamente
    final viewModel = context.watch<HomeViewModel>();
    final items = viewModel.getItemsForClient(client.id ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      children: [
        _ClientHeader(client: client),
        const SizedBox(height: 22),
        const _DebtSummaryCard(),
        const SizedBox(height: 28),
        _ItemsTitle(
          onAdd: (_) {
            // A atualização agora é gerida inteiramente pelo ViewModel
            // para evitar conflitos de estado.
          },
        ),
        const SizedBox(height: 14),
        if (items.isEmpty && viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Nenhum item encontrado.',
                style: GoogleFonts.roboto(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else ...[
          // Cabeçalho da Tabela
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Qtd.', 1),
                _buildHeaderCell('Unid.', 1),
                _buildHeaderCell('Descrição', 2),
                _buildHeaderCell('V. Unit.', 2),
                _buildHeaderCell('Total', 2),
              ],
            ),
          ),
          ...items.map((item) => _PurchasedItemTile(item: item)),
        ],
      ],
    );
  }

  Widget _buildHeaderCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class ClientPaymentsPage extends StatefulWidget {
  const ClientPaymentsPage({super.key});

  @override
  State<ClientPaymentsPage> createState() => _ClientPaymentsPageState();
}

class _ClientPaymentsPageState extends State<ClientPaymentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final client = _ClientDetailsScope.clientOf(context);
        if (client.id != null) {
          context.read<HomeViewModel>().loadItemsForClient(
            client.id!,
          ); // This also loads payments
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = _ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<HomeViewModel>();
    final payments = viewModel.getPaymentsForClient(client.id ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      children: [
        _ClientHeader(client: client),
        const SizedBox(height: 22),
        const _DebtSummaryCard(),
        const SizedBox(height: 28),
        _PaymentsTitle(
          onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => const _AddPaymentDialog(),
            );

            if (result != null && context.mounted) {
              final viewModel = context.read<HomeViewModel>();
              if (client.id != null) {
                await viewModel.addPaymentToClientAccount(client.id!, result);
              }
            }
          },
        ),
        const SizedBox(height: 14),
        if (payments.isEmpty && viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (payments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Nenhum pagamento registrado.',
                style: GoogleFonts.roboto(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else ...[
          // Cabeçalho da Tabela
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Data', 1),
                _buildHeaderCell('Dinheiro', 2),
                _buildHeaderCell('Valor', 1),
              ],
            ),
          ),
          ...payments.map((payment) => _PaymentTile(payment: payment)),
        ],
      ],
    );
  }

  Widget _buildHeaderCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ClientDetailsScope extends InheritedWidget {
  const _ClientDetailsScope({required this.client, required super.child});

  final ClientModel client;

  static ClientModel clientOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_ClientDetailsScope>()
            ?.client ??
        _fallbackClient;
  }

  @override
  bool updateShouldNotify(_ClientDetailsScope oldWidget) {
    return client != oldWidget.client;
  }
}

class _LogoHeader extends StatelessWidget {
  final ThemeData theme;
  const _LogoHeader(this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        Image.asset('assets/images/logo.png', width: 31, height: 41),
        Row(
          children: [
            Text("Espeto", style: TextStyle(color: theme.colorScheme.error)),
            Text("System", style: TextStyle(color: theme.colorScheme.tertiary)),
          ],
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
              _InfoLine(label: 'Nome:', value: client.name),
              const SizedBox(height: 5),
              _InfoLine(
                label: 'Descrição:',
                value: client.description,
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 12,
                runSpacing: 5,
                children: [
                  _InfoLine(label: 'cpf:', value: client.cpf),
                  _InfoLine(label: 'Telefone:', value: client.phoneNumber),
                ],
              ),
              const SizedBox(height: 5),
              _InfoLine(label: 'Endereço:', value: address),
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
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: value),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.roboto(
        color: theme.colorScheme.onSurface,
        fontSize: 14,
        height: 1.18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = _ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<HomeViewModel>();

    final double totalDebt = viewModel.getTotalDebtForClient(client.id ?? '');
    final String formattedDebt =
        'R\$ ${totalDebt.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Falta Pagar',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDebt,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
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
  const _ItemsTitle({required this.onAdd});

  final Function(List<PurchasedItemModel>) onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Itens Comprados',
            style: GoogleFonts.roboto(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            final result = await context.push<List<Map<String, dynamic>>>(
              '/home/client/add-item',
            );

            if (result != null) {
              // Persiste no banco de dados e notifica o ViewModel
              final viewModel = context.read<HomeViewModel>();
              final client = _ClientDetailsScope.clientOf(context);
              if (client.id != null) {
                await viewModel.addItemsToClientAccount(client.id!, result);
              }
            }
          },
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Adicionar item',
          icon: Icon(
            LucideIcons.badgePlus,
            color: theme.colorScheme.onSurface,
            size: 19,
          ),
        ),
      ],
    );
  }
}

class _PaymentsTitle extends StatelessWidget {
  const _PaymentsTitle({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Pagamentos',
            style: GoogleFonts.roboto(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onAdd,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Adicionar pagamento',
          icon: Icon(
            LucideIcons.badgeDollarSign,
            color: theme.colorScheme.onSurface,
            size: 19,
          ),
        ),
      ],
    );
  }
}

class _PurchasedItemTile extends StatelessWidget {
  const _PurchasedItemTile({required this.item});

  final PurchasedItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.74);

    // Calcula o total (Qtd * V. Unit)
    final double unitValue =
        double.tryParse(
          item.value
              .replaceAll('R\$ ', '')
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0;
    final double total = item.quantity * unitValue;
    final String totalFormatted =
        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSecondary.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: Row(
        children: [
          // Qtd
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.roboto(
                color: mutedTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Unid
          Expanded(
            flex: 1,
            child: Text(
              item.unit,
              style: GoogleFonts.roboto(
                color: mutedTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Descrição
          Expanded(
            flex: 2,
            child: Text(
              item.description,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // V. Unit.
          Expanded(
            flex: 2,
            child: Text(
              item.value,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Total
          Expanded(
            flex: 2,
            child: Text(
              totalFormatted,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Formatação nativa de data sem depender do pacote intl
    final day = payment.date.day.toString().padLeft(2, '0');
    final month = payment.date.month.toString().padLeft(2, '0');
    final year = payment.date.year.toString();
    final String formattedDate = '$day/$month/$year';

    final String formattedValue =
        'R\$ ${payment.value.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSecondary.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              formattedDate,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Dinheiro', // Simulando método de pagamento pois PaymentModel não tem
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              formattedValue,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 8),
      color: theme.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: 'Compras',
            icon: LucideIcons.shoppingCart,
            selected: navigationShell.currentIndex == 0,
            onTap: () => navigationShell.goBranch(0),
          ),
          _NavItem(
            label: 'Pagamentos',
            icon: LucideIcons.banknote,
            selected: navigationShell.currentIndex == 1,
            onTap: () => navigationShell.goBranch(1),
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
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSecondary.withValues(alpha: 0.74);
    final iconColor = selected ? Colors.white : mutedColor;
    final labelColor = selected ? theme.colorScheme.onSurface : mutedColor;

    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected ? theme.colorScheme.tertiary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPaymentDialog extends StatefulWidget {
  const _AddPaymentDialog();

  @override
  State<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<_AddPaymentDialog> {
  final TextEditingController _valorController = TextEditingController();

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.secondary,
      insetPadding: const EdgeInsets.all(24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Pagamento',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0),
            DefaultFormField(
              name: 'Valor do Pagamento',
              controller: _valorController,
              theme: theme,
              hintText: 'R\$ 0,00',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButtomCustom(
              theme: theme,
              title: 'Confirmar Pagamento',
              onPressed: () {
                final valorText = _valorController.text;
                if (valorText.isNotEmpty) {
                  final String rawValue = valorText
                      .replaceAll('R\$ ', '')
                      .replaceAll('.', '')
                      .replaceAll(',', '.');
                  final double valor = double.tryParse(rawValue) ?? 0;

                  if (valor > 0) {
                    Navigator.of(
                      context,
                    ).pop({'valor': valor, 'metodo': 'Dinheiro'});
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

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

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);
    final formatter =
        'R\$ ${(value / 100).toStringAsFixed(2).replaceAll('.', ',')}';

    return newValue.copyWith(
      text: formatter,
      selection: TextSelection.collapsed(offset: formatter.length),
    );
  }
}

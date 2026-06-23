import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/UI/client/widgets/client_header.dart';
import 'package:espetosystem/app/UI/client/widgets/debt_summary_card.dart';
import 'package:espetosystem/app/UI/client/widgets/items_title.dart';
import 'package:espetosystem/app/UI/client/widgets/purchased_item_tile.dart';
import 'package:espetosystem/app/UI/client/widgets/build_header_cell.dart';
import 'package:espetosystem/app/UI/home/widgets/custom_showcase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class ClientDetailsPage extends StatefulWidget {
  const ClientDetailsPage({super.key});

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  final GlobalKey _debtCardKey = GlobalKey();
  final GlobalKey _addItemButtonKey = GlobalKey();
  final GlobalKey _firstItemKey = GlobalKey();
  bool _tutorialStarted = false;
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(scope: 'client_details');
    Future.microtask(() {
      if (mounted) {
        final client = ClientDetailsScope.clientOf(context);
        if (client.id != null) {
          context.read<ClientAccountViewModel>().loadItemsForClient(client.id!);
        }
      }
    });
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<ClientAccountViewModel>();
    final items = viewModel.getItemsForClient(client.id ?? '');
    final totalDebt = viewModel.getTotalDebtForClient(client.id ?? '');
    final isPaid = totalDebt <= 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!viewModel.isLoading && !viewModel.hasSeenClientOnboarding && !_tutorialStarted) {
        _tutorialStarted = true;
        final keys = [
          if (items.isNotEmpty) _debtCardKey,
          _addItemButtonKey,
          if (items.isNotEmpty) _firstItemKey,
        ];
        ShowcaseView.getNamed('client_details').startShowCase(keys);
        viewModel.completeClientOnboarding();
      }
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      children: [
        ClientHeader(client: client),
        const SizedBox(height: 22),
        if (items.isNotEmpty)
          CustomShowcase(
            showcaseKey: _debtCardKey,
            scope: 'client_details',
            title: isPaid ? 'Conta Paga' : 'Resumo da Dívida',
            description: isPaid
                ? 'A conta deste cliente está totalmente quitada! O card verde indica que não há pendências.'
                : 'Aqui você vê o status de pagamento e o valor total pendente deste cliente.',
            child: const DebtSummaryCard(),
          )
        else
          const DebtSummaryCard(),
        const SizedBox(height: 28),
        ItemsTitle(
          addItemKey: _addItemButtonKey,
          onHelpTap: () {
            _tutorialStarted = true;
            final keys = [
              if (items.isNotEmpty) _debtCardKey,
              _addItemButtonKey,
              if (items.isNotEmpty) _firstItemKey,
            ];
            ShowcaseView.getNamed('client_details').startShowCase(keys);
          },
          onAdd: (_) {
            // A atualização agora é gerida inteiramente pelo ViewModel
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                BuildHeaderCell('Qtd.', flex: 0),
                BuildHeaderCell('Unid.', flex: 1),
                BuildHeaderCell('Descrição', flex: 1),
                BuildHeaderCell('V. Unit.', flex: 1),
                BuildHeaderCell('Total', flex: 1),
              ],
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final tile = PurchasedItemTile(item: item);
            if (index == 0) {
              return CustomShowcase(
                showcaseKey: _firstItemKey,
                scope: 'client_details',
                title: 'Gerenciar Item',
                description: 'Deslize para a direita para editar o item ou para a esquerda para excluí-lo.',
                child: tile,
              );
            }
            return tile;
          }),
        ],
      ],
    );
  }
}

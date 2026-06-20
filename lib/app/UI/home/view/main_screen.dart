import 'package:espetosystem/app/core/widgets/custom_snack_bar.dart';
import 'package:espetosystem/app/UI/home/components/modal_custom.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/UI/home/widgets/app_bar_custom.dart';
import 'package:espetosystem/app/UI/home/widgets/client_card.dart';
import 'package:espetosystem/app/UI/home/widgets/empty_client_state.dart';
import 'package:espetosystem/app/UI/home/widgets/filter_arrow.dart';
import 'package:espetosystem/app/UI/home/widgets/filter_bar_custom.dart';
import 'package:espetosystem/app/UI/home/widgets/search_bar_static_custom.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<void> _openClientForm(
    BuildContext context,
    HomeViewModel viewModel,
  ) async {
    final theme = Theme.of(context);

    final ClientModel? created = await create(context, theme);

    if (created != null) {
      await viewModel.addClient(created);

      if (context.mounted) {
        CustomSnackBar.showSuccess(context, 'Cliente adicionado com sucesso!');
      }
    }
  }

  Future<void> _openSearchPage(
    BuildContext context,
    HomeViewModel viewModel,
  ) async {
    final String? result = await context.push<String>(
      '/home/search',
      extra: {
        'clients': viewModel.clients,
        'initialQuery': viewModel.searchQuery,
      },
    );

    if (result != null) {
      viewModel.setSearchQuery(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final clients = viewModel.visibleClients;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(75),
            child: AppBarCustom(theme: theme),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      spacing: 18,
                      children: [
                        Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              flex: orientation == Orientation.portrait ? 4 : 9,
                              child: SearchBarStaticCustom(
                                theme: theme,
                                onTap:
                                    () => _openSearchPage(context, viewModel),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        () =>
                                            _openClientForm(context, viewModel),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      width: 31,
                                      height: 31,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        border: Border.all(
                                          color: theme.colorScheme.onSecondary,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/icons/user-plus.svg',
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          theme.colorScheme.onSurface,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilterArrow(
                                  theme: theme,
                                  isAscending: viewModel.ascendingOrder,
                                  onTap: viewModel.toggleSortOrder,
                                ),
                              ],
                            ),
                          ],
                        ),
                        FilterBarCustom(
                          theme: theme,
                          selectedIndex: viewModel.selectedFilterIndex,
                          onSelected: viewModel.setSelectedFilterIndex,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Clientes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        viewModel.isLoading && clients.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                              onRefresh: viewModel.loadClients,
                              child:
                                  clients.isEmpty
                                      ? const SingleChildScrollView(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        child: EmptyClientState(),
                                      )
                                      : ListView.separated(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        itemCount: clients.length,
                                        separatorBuilder:
                                            (_, __) =>
                                                const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final client = clients[index];
                                          final status =
                                              viewModel.accountStatuses[client
                                                  .id] ??
                                              'LIMPA';
                                          return ClientCard(
                                            client: client,
                                            status: status,
                                            onTap: () {
                                              context.push(
                                                '/home/client',
                                                extra: client,
                                              );
                                            },
                                          );
                                        },
                                      ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

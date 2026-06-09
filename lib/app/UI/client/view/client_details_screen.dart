import 'package:espetosystem/app/UI/client/components/dialog_custom.dart';
import 'package:espetosystem/app/UI/client/components/modal_custom.dart';
import 'package:espetosystem/app/UI/client/view_model/client_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/bottom_bar.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/UI/client/widgets/logo_header.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

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
    _client = widget.client!;
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
    final action = await actionModal(context, theme);

    // Se o usuário tocou fora, action será nula
    if (action == null || !context.mounted) return;

    if (action == 'edit') {
      // 2. Mostra o formulário de edição usando o contexto seguro da tela principal
      final result = await resultModal(context, client);

      debugPrint(
        'DEBUG: Formulário de edição fechou. Retornou: ${result?.name}',
      );

      if (result != null && context.mounted) {
        final viewModel = context.read<ClientViewModel>();
        debugPrint('DEBUG: Chamando viewModel.saveClient...');
        final savedClient = await viewModel.saveClient(result);
        debugPrint('DEBUG: viewModel retornou: ${savedClient?.name}');

        if (savedClient != null && context.mounted) {
          setState(() {
            debugPrint('DEBUG: Atualizando o UI com o cliente atualizado.');
            _client = savedClient;
          });
        }
      }
    } else if (action == 'delete') {
      // Lógica de exclusão (inalterada, mas agora em um contexto seguro)
      final confirm = await confirmDialog(context, theme);

      if (confirm == true && context.mounted) {
        final viewModel = context.read<ClientViewModel>();
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

    return ClientDetailsScope(
      client: _client,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 75,
            titleSpacing: 16,
            backgroundColor: theme.colorScheme.primary,
            title: LogoHeader(theme),
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
              BottomBar(navigationShell: widget.navigationShell),
            ],
          ),
        ),
      ),
    );
  }
}

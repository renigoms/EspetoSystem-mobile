import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientSearchPage extends StatefulWidget {
  const ClientSearchPage({super.key, required this.clients, required this.initialQuery});

  final List<ClientModel> clients;
  final String initialQuery;

  @override
  State<ClientSearchPage> createState() => _ClientSearchPageState();
}

class _ClientSearchPageState extends State<ClientSearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ClientModel> get _matches {
    final query = _controller.text.trim().toLowerCase();
    return widget.clients.where((client) {
      if (query.isEmpty) {
        return true;
      }

      return client.name.toLowerCase().contains(query) ||
          client.description.toLowerCase().contains(query) ||
          client.cpf.toLowerCase().contains(query) ||
          client.phoneNumber.toLowerCase().contains(query) ||
          (client.address?.street.toLowerCase().contains(query) ?? false) ||
          (client.address?.neighborhood.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _matches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar clientes'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, CPF, telefone ou endereço',
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: theme.colorScheme.onSecondary,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSecondary.withOpacity(0.28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${matches.length} resultado(s) encontrados',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    matches.isEmpty
                        ? Center(
                          child: Text(
                            'Nenhum cliente encontrado.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                        : ListView.separated(
                          itemCount: matches.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final client = matches[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tileColor: theme.colorScheme.onPrimaryContainer,
                              title: Text(client.name),
                              subtitle: Text(client.description),
                              trailing: Text(client.phoneNumber),
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pop(_controller.text.trim());
                              },
                            );
                          },
                        ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_controller.text.trim());
                },
                child: const Text('Aplicar pesquisa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

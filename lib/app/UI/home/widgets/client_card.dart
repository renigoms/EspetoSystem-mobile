import 'package:espetosystem/app/UI/home/widgets/client_avatar.dart';
import 'package:espetosystem/app/UI/home/widgets/status_tag.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
    this.status = 'LIMPA',
  });

  final ClientModel client;
  final VoidCallback? onTap;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    switch (status.toUpperCase()) {
      case 'DEVENDO':
        backgroundColor = theme.colorScheme.error.withValues(alpha: 0.18);
        break;
      case 'PAGO':
      case 'PAGA':
        backgroundColor = theme.colorScheme.tertiary.withValues(alpha: 0.18);
        break;
      case 'LIMPA':
      case 'LIMPO':
      default:
        backgroundColor = theme.colorScheme.primary;
        break;
    }

    final borderColor = theme.colorScheme.onSecondary.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClientAvatar(name: client.name, photoPath: client.photoPath),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                client.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.description,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.phone,
                              size: 14,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                client.phoneNumber,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (client.address != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${client.address!.street}, ${client.address!.number} - ${client.address!.neighborhood}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(top: 0, right: 0, child: StatusTag(status: status)),
            ],
          ),
        ),
      ),
    );
  }
}

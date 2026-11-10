import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/core/constants/app_constants.dart';
import 'package:focusmate/data/models/routine_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';
import 'package:focusmate/presentation/providers/user_provider.dart';

final _routinesProvider =
    FutureProvider.autoDispose<List<RoutineModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider) ?? 'local_user';
  return ref
      .watch(routineRepositoryProvider)
      .getRoutinesForUser(userId);
});

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(_routinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routines')),
      body: routinesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.repeat_rounded, size: 56),
                  const SizedBox(height: 12),
                  Text('No routines yet',
                      style:
                          Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Routine'),
                    onPressed: () =>
                        _showCreateRoutineSheet(context, ref),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, i) => _RoutineTile(
              routine: routines[i],
              onToggle: (enabled) async {
                await ref
                    .read(routineRepositoryProvider)
                    .toggleRoutine(
                        routines[i].routineId, enabled);
                ref.invalidate(_routinesProvider);
              },
              onDelete: () async {
                await ref
                    .read(routineRepositoryProvider)
                    .deleteRoutine(routines[i].routineId);
                ref.invalidate(_routinesProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showCreateRoutineSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Routine'),
      ),
    );
  }

  void _showCreateRoutineSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final selectedDays = <int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Routine',
                  style:
                      Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Routine name'),
              ),
              const SizedBox(height: 16),
              Text('Repeat on',
                  style:
                      Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    List.generate(7, (i) {
                  final day = i + 1;
                  return FilterChip(
                    label: Text(AppConstants.daysOfWeek[i]),
                    selected: selectedDays.contains(day),
                    onSelected: (v) => setModal(() {
                      if (v) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    }),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    final userId =
                        ref.read(currentUserIdProvider) ??
                            'local_user';
                    await ref
                        .read(routineRepositoryProvider)
                        .createRoutine(
                          userId: userId,
                          name: nameController.text.trim(),
                          repeatDays:
                              selectedDays.toList()..sort(),
                        );
                    ref.invalidate(_routinesProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.routine,
    required this.onToggle,
    required this.onDelete,
  });

  final RoutineModel routine;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  String _daysLabel() {
    final days = routine.repeatDays.split(',').map(int.parse).toList()
      ..sort();
    if (days.length == 7) return 'Every day';
    if (days.length == 5 &&
        days.every((d) => d >= 1 && d <= 5)) return 'Weekdays';
    return days
        .map((d) => AppConstants.daysOfWeek[d - 1])
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.repeat_rounded,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(routine.routineName,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(_daysLabel()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: routine.isActive, onChanged: onToggle),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_config.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/story_values.dart';
import '../../../core/widgets/choice_pill.dart';
import '../../../core/widgets/field_label.dart';
import '../../../core/widgets/language_choice.dart';
import '../../../data/models/child_profile.dart';
import '../../children/controllers/children_provider.dart';
import '../controllers/story_creation_controller.dart';
import '../controllers/story_input_check.dart';
import 'story_info_box.dart';

/// Parent describes a lesson and starts a new story (design p7, FR-STORY-01, FR-STORY-05).
class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  final _textController = TextEditingController();
  String _value = '';
  String? _childId;
  String? _message;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ── Create the story ──
  void _create(ChildProfile? child) {
    final problem = StoryInputCheck.check(_textController.text, _value);
    if (problem != null) {
      setState(() => _message = problem);
      return;
    }
    if (child == null) {
      setState(() => _message = 'Please add a reader first.');
      return;
    }
    unawaited(
      ref
          .read(storyCreationControllerProvider.notifier)
          .create(text: _textController.text, value: _value, child: child),
    );
    context.go(AppRoutes.storyGenerating);
  }

  // ── Pick a value (tap again to remove it) ──
  void _pickValue(String value) {
    setState(() {
      _value = _value == value ? '' : value;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final children = ref.watch(childrenProvider).value ?? [];
    ChildProfile? selectedChild;
    for (final child in children) {
      if (child.id == _childId) {
        selectedChild = child;
      }
    }
    if (selectedChild == null && children.isNotEmpty) {
      selectedChild = children.first;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Back button and title ──
                    Row(
                      children: [
                        IconButton.outlined(
                          tooltip: 'Back',
                          onPressed: () => context.go(AppRoutes.parentHome),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        const SizedBox(width: 12),
                        Text('New story', style: textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── What should this story teach? ──
                    Text(
                      'What should this story teach?',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: AppConfig.maxPromptLength,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) => setState(() => _message = null),
                      decoration: const InputDecoration(
                        hintText:
                            "e.g. Zayan doesn't want to share his toys "
                            'with his baby sister',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Or pick a value ──
                    const FieldLabel('OR PICK A VALUE'),
                    Wrap(
                      spacing: AppSizes.parentSpacing,
                      runSpacing: AppSizes.parentSpacing,
                      children: [
                        for (final value in StoryValues.all)
                          ChoicePill(
                            label: value,
                            isSelected: _value == value,
                            onTap: () => _pickValue(value),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── For which child ──
                    const FieldLabel('FOR'),
                    if (children.isEmpty)
                      Text('No readers yet.', style: textTheme.bodyLarge),
                    Wrap(
                      spacing: AppSizes.parentSpacing,
                      runSpacing: AppSizes.parentSpacing,
                      children: [
                        for (final child in children)
                          ChoicePill(
                            label: '${child.name} · ${child.ageGroup.ageRange}',
                            isSelected: child.id == selectedChild?.id,
                            onTap: () => setState(() => _childId = child.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Language (English only, decision 005) ──
                    const FieldLabel('LANGUAGE'),
                    const LanguageChoice(),
                  ],
                ),
              ),
            ),

            // ── Info, message and main button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StoryInfoBox(),
                  const SizedBox(height: 12),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.coralSoft,
                        ),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: () => _create(selectedChild),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Create story'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

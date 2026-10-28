import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/field_label.dart';
import '../../../data/models/age_group.dart';
import '../controllers/add_child_controller.dart';
import 'age_group_card.dart';
import 'buddy_picker.dart';

/// Parent adds a child: name, buddy, age group, language (design p4, FR-AUTH-02).
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Buddy? _buddy;
  AgeGroup? _ageGroup;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Save the child ──
  Future<void> _save() async {
    final nameIsValid = _formKey.currentState!.validate();
    if (_buddy == null) {
      setState(() => _message = 'Please pick a buddy.');
      return;
    }
    if (_ageGroup == null) {
      setState(() => _message = 'Please choose an age group.');
      return;
    }
    if (!nameIsValid) {
      return;
    }
    setState(() => _message = null);

    final saved = await ref
        .read(addChildControllerProvider.notifier)
        .save(name: _nameController.text, buddy: _buddy!, ageGroup: _ageGroup!);
    if (!mounted) {
      return;
    }
    if (saved) {
      context.go(AppRoutes.parentHome);
    } else {
      setState(() => _message = 'Could not save. Please try again.');
    }
  }

  // ── Name check ──
  String? _checkName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) {
      return "Please type your child's name.";
    }
    if (name.length > 20) {
      return 'Please use 20 letters or fewer.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isSaving = ref.watch(addChildControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Progress bar and title ──
                      Row(
                        children: [
                          Expanded(child: _ProgressBar(color: colors.primary)),
                          const SizedBox(width: 8),
                          Expanded(child: _ProgressBar(color: colors.primary)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Who is our new reader?',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),

                      // ── Child's name ──
                      const FieldLabel("CHILD'S NAME"),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        validator: _checkName,
                      ),
                      const SizedBox(height: 20),

                      // ── Buddy ──
                      const FieldLabel('PICK A BUDDY'),
                      BuddyPicker(
                        selected: _buddy,
                        onPick: (buddy) => setState(() {
                          _buddy = buddy;
                          _message = null;
                        }),
                      ),
                      const SizedBox(height: 20),

                      // ── Age group ──
                      const FieldLabel('AGE GROUP'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAgeCard(AgeGroup.listener)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildAgeCard(AgeGroup.reader)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Language ──
                      Row(
                        children: [
                          _LanguagePill(label: 'English', isSelected: true),
                          const SizedBox(width: 8),
                          _LanguagePill(label: 'اردو', isSelected: false),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Urdu: coming soon',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Message and main button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _message!,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.coralSoft,
                          ),
                        ),
                      ),
                    FilledButton(
                      onPressed: isSaving ? null : _save,
                      child: const Text('Start the adventure'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeCard(AgeGroup ageGroup) {
    return AgeGroupCard(
      ageGroup: ageGroup,
      isSelected: _ageGroup == ageGroup,
      onTap: () => setState(() {
        _ageGroup = ageGroup;
        _message = null;
      }),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isUrdu = label == 'اردو';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? colors.primary : colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: isUrdu ? AppFonts.notoNastaliqUrdu : AppFonts.nunito,
          fontWeight: FontWeight.w700,
          height: isUrdu ? 1.0 : null,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : colors.inkMuted,
        ),
      ),
    );
  }
}

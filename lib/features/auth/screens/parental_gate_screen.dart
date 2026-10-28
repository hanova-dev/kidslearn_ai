import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/gate_question.dart';
import '../controllers/parent_unlock.dart';
import 'number_pad.dart';

/// "Grown-ups only" maths gate in front of the parent area (design p5, FR-AUTH-04).
class ParentalGateScreen extends ConsumerStatefulWidget {
  const ParentalGateScreen({super.key});

  @override
  ConsumerState<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends ConsumerState<ParentalGateScreen> {
  final Random _random = Random();
  late GateQuestion _question = GateQuestion.random(_random);
  String _typed = '';
  String? _message;

  // ── Number pad ──
  void _addDigit(String digit) {
    if (_typed.length < 3) {
      setState(() => _typed = _typed + digit);
    }
  }

  void _deleteDigit() {
    if (_typed.isNotEmpty) {
      setState(() => _typed = _typed.substring(0, _typed.length - 1));
    }
  }

  // ── Check the answer ──
  void _check() {
    if (int.tryParse(_typed) == _question.answer) {
      ref.read(parentUnlockProvider.notifier).unlock();
      context.go(AppRoutes.parentHome);
      return;
    }
    setState(() {
      _message = 'Not quite. Try this one.';
      _question = GateQuestion.random(_random);
      _typed = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Header ──
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 36,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.shield_outlined,
                  color: colors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text('Grown-ups only', style: textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'To open the parent area, solve this:',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // ── Question and typed answer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Text(_question.text, style: textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      _typed.isEmpty ? '—' : _typed,
                      key: const Key('typed-answer'),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 24,
                child: _message == null
                    ? null
                    : Text(
                        _message!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.coralSoft,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              NumberPad(
                onDigit: _addDigit,
                onDelete: _deleteDigit,
                onDone: _check,
              ),
              const SizedBox(height: 16),

              // ── Back to child space ──
              TextButton(
                onPressed: () => context.go(AppRoutes.whoIsReading),
                child: Text(
                  'Back to stories',
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

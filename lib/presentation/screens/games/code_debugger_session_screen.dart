import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../state/game_controller.dart';

class CodeDebuggerSessionScreen extends StatefulWidget {
  const CodeDebuggerSessionScreen({super.key});

  @override
  State<CodeDebuggerSessionScreen> createState() => _CodeDebuggerSessionScreenState();
}

class _CodeDebuggerSessionScreenState extends State<CodeDebuggerSessionScreen> {
  @override
  void initState() {
    super.initState();
    GameController.instance.startSession(60);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameController.instance,
      builder: (context, _) {
        final ctrl = GameController.instance;
        final question = ctrl.currentQuestion;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'Code Debugger Session',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ctrl.secondsRemaining < 15 ? AppColors.redLight : AppColors.orangeLight,
                  borderRadius: AppDimens.borderPill,
                  border: Border.all(
                    color: ctrl.secondsRemaining < 15 ? AppColors.red : AppColors.orange,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: ctrl.secondsRemaining < 15 ? AppColors.red : AppColors.orangeDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ctrl.secondsRemaining}s',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: ctrl.secondsRemaining < 15 ? AppColors.red : AppColors.orangeDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: question == null
              ? _buildSessionCompleted(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.marginMobile),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${ctrl.currentQuestionIndex + 1} of ${ctrl.codeDebugger.questions.length}',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700),
                            ),
                            StatusBadge.warning('+${question.points} Points'),
                          ],
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          question.title,
                          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.prompt,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppDimens.md),

                        // Code Snippet Box (Monospace Dark Surface)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2E), // Dark code editor background
                            borderRadius: AppDimens.borderLg,
                            boxShadow: AppDimens.cardShadow,
                          ),
                          child: SelectableText(
                            question.codeSnippet,
                            style: AppTextStyles.code.copyWith(
                              color: const Color(0xFFCBE0FF),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.lg),

                        // Options
                        Text(
                          'Select the correct fix:',
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        ...List.generate(question.options.length, (index) {
                          final isSelected = ctrl.selectedOptionIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimens.sm),
                            child: BentoCard(
                              onTap: () => ctrl.selectOption(index),
                              backgroundColor: isSelected ? AppColors.blueLight : AppColors.white,
                              border: Border.all(
                                color: isSelected ? AppColors.blue : AppColors.outlineVariant,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              padding: const EdgeInsets.all(AppDimens.md),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? AppColors.blue : AppColors.outline,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppDimens.md),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? AppColors.blueDark : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: AppDimens.lg),

                        // Submit Button
                        if (!ctrl.hasSubmittedAnswer)
                          PrimaryButton(
                            label: 'Submit Answer',
                            icon: Icons.check,
                            backgroundColor: AppColors.green,
                            onPressed: ctrl.selectedOptionIndex != null
                                ? () {
                                    ctrl.submitAnswer();
                                  }
                                : null,
                          )
                        else
                          _buildResultFeedbackCard(context, ctrl, question),
                        const SizedBox(height: AppDimens.xxl),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildResultFeedbackCard(BuildContext context, GameController ctrl, question) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      backgroundColor: ctrl.isAnswerCorrect ? AppColors.greenLight : AppColors.redLight,
      border: Border.all(
        color: ctrl.isAnswerCorrect ? AppColors.green : AppColors.red,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ctrl.isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                color: ctrl.isAnswerCorrect ? AppColors.greenDark : AppColors.redDark,
                size: 28,
              ),
              const SizedBox(width: AppDimens.sm),
              Text(
                ctrl.isAnswerCorrect ? 'Correct! +${question.points} Points 🎉' : 'Incorrect Solution',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: ctrl.isAnswerCorrect ? AppColors.greenDark : AppColors.redDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            question.explanation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: ctrl.isAnswerCorrect ? AppColors.greenDark : AppColors.redDark,
            ),
          ),
          const SizedBox(height: AppDimens.md),
          PrimaryButton(
            label: ctrl.currentQuestionIndex < ctrl.codeDebugger.questions.length - 1
                ? 'Next Question'
                : 'Finish Session',
            icon: Icons.arrow_forward,
            backgroundColor: ctrl.isAnswerCorrect ? AppColors.green : AppColors.blue,
            onPressed: () {
              if (ctrl.currentQuestionIndex < ctrl.codeDebugger.questions.length - 1) {
                ctrl.nextQuestion();
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Session completed! Score: ${ctrl.score} pts')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCompleted(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.military_tech, size: 64, color: AppColors.orangeDark),
            const SizedBox(height: AppDimens.md),
            Text(
              'Challenge Complete!',
              style: AppTextStyles.displayLargeMobile.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Total Score: ${GameController.instance.score} points earned',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.greenDark),
            ),
            const SizedBox(height: AppDimens.xl),
            PrimaryButton(
              label: 'Return to Games Hub',
              backgroundColor: AppColors.blue,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

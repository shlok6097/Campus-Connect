import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/registration_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/headers/section_header.dart';
import '../../state/event_controller.dart';

class OrganizerGameToolsScreen extends StatefulWidget {
  const OrganizerGameToolsScreen({super.key});

  @override
  State<OrganizerGameToolsScreen> createState() => _OrganizerGameToolsScreenState();
}

class _OrganizerGameToolsScreenState extends State<OrganizerGameToolsScreen> {
  RegistrationModel? _pickedWinner;
  bool _isPicking = false;
  List<List<RegistrationModel>> _generatedTeams = [];

  void _pickRandomWinner() {
    final list = EventController.instance.allRegistrations;
    if (list.isEmpty) return;

    setState(() {
      _isPicking = true;
      _pickedWinner = null;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final random = Random();
      setState(() {
        _pickedWinner = list[random.nextInt(list.length)];
        _isPicking = false;
      });
    });
  }

  void _generateRandomTeams() {
    final list = List<RegistrationModel>.from(EventController.instance.allRegistrations);
    list.shuffle(Random());

    final teams = <List<RegistrationModel>>[];
    const teamSize = 4;
    for (var i = 0; i < list.length; i += teamSize) {
      teams.add(list.sublist(i, (i + teamSize > list.length) ? list.length : i + teamSize));
    }

    setState(() {
      _generatedTeams = teams;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Organizer Game Tools',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.marginMobile),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                title: 'Live Event Utilities',
                subtitle: 'Pick giveaway winners, balance hackathon teams, and run live sessions',
              ),
              const SizedBox(height: AppDimens.lg),

              // 1. Random Participant Picker
              SectionHeader(title: 'Random Participant Picker', icon: Icons.shuffle),
              const SizedBox(height: AppDimens.sm),
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  children: [
                    if (_pickedWinner != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimens.md),
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.celebration, color: AppColors.orangeDark, size: 44),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        'Winner Selected! 🎊',
                        style: AppTextStyles.titleLarge.copyWith(color: AppColors.orangeDark, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pickedWinner!.studentName,
                        style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_pickedWinner!.studentUSN} • ${_pickedWinner!.branch}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimens.md),
                    ] else if (_isPicking) ...[
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.blue)),
                      const SizedBox(height: AppDimens.md),
                      Text('Selecting random attendee from 128 registrations...', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppDimens.md),
                    ],
                    PrimaryButton(
                      label: _isPicking ? 'Picking...' : 'Pick Random Winner',
                      icon: Icons.casino,
                      backgroundColor: AppColors.orangeDark,
                      isLoading: _isPicking,
                      onPressed: _pickRandomWinner,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              // 2. Random Team Generator
              SectionHeader(title: 'Random Team Generator', icon: Icons.groups_outlined),
              const SizedBox(height: AppDimens.sm),
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automatically shuffle registered attendees into balanced 4-person teams.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimens.md),
                    PrimaryButton(
                      label: 'Generate Teams',
                      icon: Icons.auto_awesome,
                      backgroundColor: AppColors.blue,
                      onPressed: _generateRandomTeams,
                    ),
                    if (_generatedTeams.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.lg),
                      const Divider(),
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        'Generated ${_generatedTeams.length} Teams:',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      ...List.generate(_generatedTeams.length, (teamIdx) {
                        final teamMembers = _generatedTeams[teamIdx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.md),
                          child: Container(
                            padding: const EdgeInsets.all(AppDimens.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppDimens.borderMd,
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Team ${teamIdx + 1}',
                                  style: AppTextStyles.titleLarge.copyWith(fontSize: 15, color: AppColors.blue),
                                ),
                                const SizedBox(height: 4),
                                ...teamMembers.map((m) => Text('• ${m.studentName} (${m.studentUSN} - ${m.branch})', style: AppTextStyles.bodySmall)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

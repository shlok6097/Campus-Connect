import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/game_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/headers/section_header.dart';
import '../../state/game_controller.dart';
import 'code_debugger_session_screen.dart';
import 'organizer_game_tools_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameController.instance,
      builder: (context, _) {
        final games = GameController.instance.games;
        final debuggerGame = GameController.instance.codeDebugger;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.marginMobile,
            vertical: AppDimens.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Wrap(
                  spacing: AppDimens.md,
                  runSpacing: AppDimens.sm,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const ScreenHeader(
                      title: 'Technical Games',
                      subtitle: 'Speed debugging, logic challenges, and interactive tools',
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OrganizerGameToolsScreen()),
                        );
                      },
                      icon: const Icon(Icons.casino_outlined, size: 18, color: AppColors.blue),
                      label: Text('Game Tools', style: AppTextStyles.labelMedium.copyWith(color: AppColors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),

                // Featured Game Card (Code Debugger)
                SectionHeader(title: 'Featured Challenge', icon: Icons.local_fire_department_outlined),
                const SizedBox(height: AppDimens.sm),
                _buildFeaturedGameCard(context, debuggerGame),
                const SizedBox(height: AppDimens.xl),

                // More Games Grid
                SectionHeader(title: 'More Challenges', icon: Icons.sports_esports_outlined),
                const SizedBox(height: AppDimens.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 600;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 2 : 1,
                        crossAxisSpacing: AppDimens.md,
                        mainAxisSpacing: AppDimens.md,
                        childAspectRatio: isDesktop ? 1.5 : 1.35,
                      ),
                      itemCount: games.length,
                      itemBuilder: (ctx, index) => _buildGameCard(context, games[index]),
                    );
                  },
                ),
                const SizedBox(height: AppDimens.xl),

                // Organizer Interactive Tools Card
                SectionHeader(title: 'Event Organizer Tools', icon: Icons.admin_panel_settings_outlined),
                const SizedBox(height: AppDimens.sm),
                _buildOrganizerToolsPromoCard(context),
                const SizedBox(height: AppDimens.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedGameCard(BuildContext context, GameModel game) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: AppDimens.borderMd,
                ),
                child: const Icon(Icons.bug_report, color: AppColors.greenDark, size: 28),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      game.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.warning(game.difficulty),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: AppColors.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${game.playerCount} students playing today',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.orangeDark),
              const SizedBox(width: 4),
              Text(
                '${game.timeLimitSeconds}s per round',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            label: 'Start Debugging Session',
            icon: Icons.play_arrow,
            backgroundColor: AppColors.green,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CodeDebuggerSessionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, GameModel game) {
    return BentoCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CodeDebuggerSessionScreen()),
        );
      },
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.sm),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: AppDimens.borderMd,
                ),
                child: const Icon(Icons.code, color: AppColors.blue, size: 22),
              ),
              StatusBadge.info(game.difficulty),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.title,
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                game.subtitle,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Play for +50 Pts', style: AppTextStyles.labelMedium.copyWith(color: AppColors.greenDark)),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerToolsPromoCard(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.orangeLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shuffle, color: AppColors.orangeDark, size: 26),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Random Winner & Team Tools',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Generate balanced teams or pick random attendees during events.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrganizerGameToolsScreen()),
                );
              },
              icon: const Icon(Icons.casino_outlined, size: 18),
              label: const Text('Open Interactive Tools'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: AppColors.orangeDark, width: 1.2),
                foregroundColor: AppColors.orangeDark,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimens.borderMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

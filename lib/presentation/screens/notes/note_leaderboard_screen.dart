import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/note_model.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../state/note_controller.dart';

class NoteLeaderboardScreen extends StatelessWidget {
  const NoteLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NoteController.instance,
      builder: (context, _) {
        final leaderboard = NoteController.instance.leaderboard;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'Contribution Leaderboard',
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
                    title: 'Student Contributors',
                    subtitle:
                        'Students helping students through shared notes & guides',
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // 1. Top 3 Podium Card
                  _buildPodiumCard(leaderboard),
                  const SizedBox(height: AppDimens.lg),

                  // 2. Ranked List View
                  BentoCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppDimens.md),
                          child: Text(
                            'All-Time Top Contributors',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: leaderboard.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, index) =>
                              _buildLeaderboardRow(leaderboard[index]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodiumCard(List<LeaderboardUser> users) {
    if (users.length < 3) return const SizedBox.shrink();
    final first = users[0];
    final second = users[1];
    final third = users[2];

    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        children: [
          Text(
            '🏆 Hall of Fame',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Rank 2
              _buildPodiumColumn(
                user: second,
                rank: 2,
                height: 90,
                color: AppColors.surfaceContainerHigh,
                badgeColor: AppColors.blue,
              ),
              const SizedBox(width: AppDimens.md),
              // Rank 1
              _buildPodiumColumn(
                user: first,
                rank: 1,
                height: 130,
                color: AppColors.blueContainer,
                badgeColor: AppColors.orangeDark,
              ),
              const SizedBox(width: AppDimens.md),
              // Rank 3
              _buildPodiumColumn(
                user: third,
                rank: 3,
                height: 70,
                color: AppColors.surfaceContainerHigh,
                badgeColor: AppColors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardUser user,
    required int rank,
    required double height,
    required Color color,
    required Color badgeColor,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 58,
              height: 58,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(user.avatarUrl, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: AppDimens.borderPill,
              ),
              child: Text(
                '#$rank',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user.name.split(' ').first,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${user.points} pts',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusMd),
            ),
          ),
          child: Center(
            child: Icon(
              rank == 1 ? Icons.emoji_events : Icons.military_tech,
              color: rank == 1 ? AppColors.white : AppColors.outline,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(LeaderboardUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${user.rank}',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: user.rank <= 3
                    ? AppColors.blue
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: Image.network(user.avatarUrl, fit: BoxFit.cover),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.titleLarge.copyWith(fontSize: 15),
                    ),
                    if (user.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      StatusBadge.info('You'),
                    ],
                  ],
                ),
                Text(
                  '${user.branch} • Sem ${user.semester}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.points} pts',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenDark,
                  fontSize: 15,
                ),
              ),
              Text(
                '${user.contributionsCount} contributions',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

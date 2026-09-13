import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../state/auth_controller.dart';
import '../../state/event_controller.dart';

class SendEventNotificationScreen extends StatefulWidget {
  final EventModel event;

  const SendEventNotificationScreen({super.key, required this.event});

  @override
  State<SendEventNotificationScreen> createState() => _SendEventNotificationScreenState();
}

class _SendEventNotificationScreenState extends State<SendEventNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedRecipientGroup = 'all'; // 'all', 'confirmed', 'pending'
  bool _isSending = false;

  final List<Map<String, String>> _quickTemplates = [
    {
      'label': 'Registration closes soon',
      'title': 'Registration closes tomorrow',
      'message': 'Registration for this event closes tomorrow at 11:59 PM. Please make sure your registration and payment details are submitted.',
    },
    {
      'label': 'Event starts tomorrow',
      'title': 'Get Ready! Event starts tomorrow',
      'message': 'We are excited to see you tomorrow! Please report to the venue on time with your college ID card.',
    },
    {
      'label': 'Venue changed',
      'title': 'Important Update: Venue Changed',
      'message': 'Please note that the event venue has been updated. Refer to the event page for directions.',
    },
    {
      'label': 'Schedule updated',
      'title': 'Event Schedule Updated',
      'message': 'The timeline and round schedules have been updated. Please review the new schedule.',
    },
    {
      'label': 'Bring your college ID',
      'title': 'Mandatory: Bring College ID Card',
      'message': 'Physical student ID verification is required at entry during check-in.',
    },
    {
      'label': 'Team formation closes today',
      'title': 'Final Reminder: Team Formation Closes Today',
      'message': 'Ensure your teammates are invited and finalized before the team lock deadline.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Default initial message
    _titleController.text = 'Registration closes tomorrow';
    _messageController.text = '${widget.event.title} registration closes tomorrow at 11:59 PM...';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _applyQuickTemplate(Map<String, String> template) {
    setState(() {
      _titleController.text = template['title']!;
      _messageController.text = template['message']!;
    });
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF24389C)),
            const SizedBox(width: 8),
            const Text('Notification Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF24389C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'To: ${_selectedRecipientGroup.toUpperCase()} Participants',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF24389C)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _titleController.text.trim().isNotEmpty ? _titleController.text : 'Notification Title',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _messageController.text.trim().isNotEmpty ? _messageController.text : 'Notification body content...',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final user = AuthController.instance.currentUser;
    final notification = EventNotificationModel(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      eventId: widget.event.id,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      recipientGroup: _selectedRecipientGroup,
      sentByUserId: user.id,
      createdAt: DateTime.now(),
    );

    await EventController.instance.sendEventNotification(notification);

    if (!mounted) return;
    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1B1B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFBAC3FF), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Notification sent successfully to ${_selectedRecipientGroup.toUpperCase()} recipients.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF24389C)),
        title: const Text(
          'Send Notification',
          style: TextStyle(
            color: Color(0xFF24389C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Context Header (Stitch 55c1a61a09d9439891fb38202e22467f)
              Row(
                children: [
                  const Icon(Icons.event, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Context: ',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    widget.event.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

              // Main Form Card
              Container(
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipients Section
                    const Text(
                      'Recipients',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRecipientPill(label: 'All', value: 'all'),
                        const SizedBox(width: 8),
                        _buildRecipientPill(label: 'Confirmed', value: 'confirmed'),
                        const SizedBox(width: 8),
                        _buildRecipientPill(label: 'Pending', value: 'pending'),
                      ],
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Quick Messages Section (Stitch 55c1a61a09d9439891fb38202e22467f)
                    Row(
                      children: const [
                        Icon(Icons.bolt, size: 16, color: Color(0xFF24389C)),
                        SizedBox(width: 4),
                        Text(
                          'Quick Messages',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickTemplates.map((template) {
                        return InkWell(
                          onTap: () => _applyQuickTemplate(template),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF24389C).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF24389C).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              template['label']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF24389C),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Title Field
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Notification title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Message Field
                    const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter notification message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a message' : null,
                    ),
                    const SizedBox(height: AppDimens.xl),

                    // Bottom Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _showPreviewDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outlineVariant),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Preview',
                            style: TextStyle(color: Color(0xFF24389C), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        ElevatedButton.icon(
                          onPressed: _isSending ? null : _handleSend,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send, size: 16),
                          label: Text(_isSending ? 'Sending...' : 'Send Notification'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24389C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
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

  Widget _buildRecipientPill({required String label, required String value}) {
    final isSelected = _selectedRecipientGroup == value;

    return InkWell(
      onTap: () => setState(() => _selectedRecipientGroup = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDEE0FF) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF24389C) : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: Color(0xFF24389C)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF24389C) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

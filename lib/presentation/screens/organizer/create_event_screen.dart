import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/event_service.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/payment_qr_card.dart';
import '../../state/auth_controller.dart';
import '../../state/event_controller.dart';

class CreateEventScreen extends StatefulWidget {
  final EventModel? eventToEdit;

  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _bannerUrlController = TextEditingController();

  // Schedule Controllers
  final _venueController = TextEditingController();
  final _feeController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _eligibilityController = TextEditingController();
  final _rulesController = TextEditingController();

  // Prizes Controllers
  final _firstPrizeController = TextEditingController(text: '₹10,000 + Trophy');
  final _secondPrizeController = TextEditingController(text: '₹5,000 + Medal');
  final _thirdPrizeController = TextEditingController(text: '₹2,500 + Medal');
  final _specialAwardsController = TextEditingController();

  // State Variables
  String _selectedCategory = 'Workshop';
  DateTime? _eventDate;
  DateTime? _registrationDeadline;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Image Upload State
  Uint8List? _selectedImageBytes;
  String? _selectedImageFileName;
  bool _isPublishing = false;

  late List<CustomFormField> _customQuestions;

  final List<String> _categoryOptions = [
    'Workshop',
    'Hackathon',
    'Technical Competition',
    'Cultural',
    'Sports & Fitness',
    'Academic Competition',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _feeController.addListener(() => setState(() {}));
    _upiIdController.addListener(() => setState(() {}));

    if (widget.eventToEdit != null) {
      final e = widget.eventToEdit!;
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _customCategoryController.text = e.customCategory ?? '';
      _bannerUrlController.text = e.bannerUrl;
      _venueController.text = e.venue;
      _feeController.text = e.entryFee > 0 ? e.entryFee.toStringAsFixed(0) : '';
      _upiIdController.text = e.paymentUpiId ?? '';
      _eligibilityController.text = e.eligibility.join('\n');
      _rulesController.text = e.rules.join('\n');
      _eventDate = e.startDate;
      _registrationDeadline = e.registrationDeadline;

      if (e.customCategory != null && e.customCategory!.isNotEmpty) {
        _selectedCategory = 'Others';
      } else {
        switch (e.category) {
          case EventCategory.hackathon:
            _selectedCategory = 'Hackathon';
            break;
          case EventCategory.competition:
            _selectedCategory = 'Technical Competition';
            break;
          case EventCategory.cultural:
            _selectedCategory = 'Cultural';
            break;
          case EventCategory.sports:
            _selectedCategory = 'Sports & Fitness';
            break;
          case EventCategory.workshop:
          default:
            _selectedCategory = 'Workshop';
            break;
        }
      }

      if (e.prizes.isNotEmpty) {
        final p1 = e.prizes.where((p) => p.rankTitle.contains('1st')).firstOrNull;
        final p2 = e.prizes.where((p) => p.rankTitle.contains('2nd')).firstOrNull;
        final p3 = e.prizes.where((p) => p.rankTitle.contains('3rd')).firstOrNull;
        final pSpec = e.prizes.where((p) => p.rankTitle.toLowerCase().contains('special') || p.rankTitle.toLowerCase().contains('award')).firstOrNull;

        if (p1 != null) _firstPrizeController.text = '${p1.amount} ${p1.description}'.trim();
        if (p2 != null) _secondPrizeController.text = '${p2.amount} ${p2.description}'.trim();
        if (p3 != null) _thirdPrizeController.text = '${p3.amount} ${p3.description}'.trim();
        if (pSpec != null) _specialAwardsController.text = '${pSpec.amount} ${pSpec.description}'.trim();
      }

      _customQuestions = List.from(e.customFormFields);
      if (_customQuestions.isEmpty) {
        _customQuestions = _defaultQuestions();
      }
    } else {
      _customQuestions = _defaultQuestions();
    }
  }

  List<CustomFormField> _defaultQuestions() => [
    const CustomFormField(
      id: 'q_diet',
      label: 'Dietary Restrictions',
      type: QuestionType.dropdown,
      isRequired: true,
      options: ['Vegetarian', 'Vegan', 'Non-Vegetarian', 'No Preference'],
    ),
    const CustomFormField(
      id: 'q_tshirt',
      label: 'T-Shirt Size',
      type: QuestionType.multipleChoice,
      isRequired: true,
      options: ['Small', 'Medium', 'Large', 'XL', 'XXL'],
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _bannerUrlController.dispose();
    _venueController.dispose();
    _feeController.dispose();
    _upiIdController.dispose();
    _eligibilityController.dispose();
    _rulesController.dispose();
    _firstPrizeController.dispose();
    _secondPrizeController.dispose();
    _thirdPrizeController.dispose();
    _specialAwardsController.dispose();
    super.dispose();
  }

  double get _currentFee => double.tryParse(_feeController.text.trim()) ?? 0.0;
  bool get _isPaidEvent => _currentFee > 0;

  String get _generatedUpiUri {
    final upiId = _upiIdController.text.trim();
    final name = Uri.encodeComponent(_titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Event Entry');
    final fee = _currentFee.toStringAsFixed(2);
    return 'upi://pay?pa=$upiId&pn=$name&am=$fee&cu=INR';
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFileName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageFileName = null;
    });
  }

  Future<void> _pickDate(BuildContext context, bool isEventDate) async {
    final now = DateTime.now();
    final initialDate = isEventDate
        ? (_eventDate ?? now.add(const Duration(days: 7)))
        : (_registrationDeadline ?? now.add(const Duration(days: 5)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isEventDate) {
          _eventDate = picked;
        } else {
          _registrationDeadline = picked;
        }
      });
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 10, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (ctx) => _AddQuestionDialog(
        onAdd: (field) {
          setState(() => _customQuestions.add(field));
        },
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isPaidEvent && _upiIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID for paid events.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final date = _eventDate ?? DateTime.now().add(const Duration(days: 7));
    final startStr = _startTime != null ? _startTime!.format(context) : '10:00 AM';
    final endStr = _endTime != null ? _endTime!.format(context) : '5:00 PM';

    setState(() => _isPublishing = true);

    String bannerUrl = _bannerUrlController.text.trim();
    if (_selectedImageBytes != null) {
      final uploadedUrl = await EventService.instance.uploadEventPoster(
        _selectedImageBytes!,
        _selectedImageFileName ?? 'event_poster.jpg',
      );
      if (uploadedUrl != null) {
        bannerUrl = uploadedUrl;
      }
    }

    if (bannerUrl.isEmpty) {
      bannerUrl = 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1000&q=80';
    }

    EventCategory categoryEnum;
    switch (_selectedCategory) {
      case 'Hackathon':
        categoryEnum = EventCategory.hackathon;
        break;
      case 'Technical Competition':
        categoryEnum = EventCategory.competition;
        break;
      case 'Cultural':
        categoryEnum = EventCategory.cultural;
        break;
      case 'Sports & Fitness':
        categoryEnum = EventCategory.sports;
        break;
      case 'Academic Competition':
        categoryEnum = EventCategory.competition;
        break;
      case 'Others':
        categoryEnum = EventCategory.others;
        break;
      case 'Workshop':
      default:
        categoryEnum = EventCategory.workshop;
        break;
    }

    final isEditing = widget.eventToEdit != null;
    final currentUser = AuthController.instance.currentUser;
    final organizerName = widget.eventToEdit?.organizerName ??
        (currentUser.clubName != null && currentUser.clubName!.isNotEmpty
            ? currentUser.clubName!
            : 'Test club');

    final savedEvent = EventModel(
      id: widget.eventToEdit?.id ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: categoryEnum,
      customCategory: _selectedCategory == 'Others' ? _customCategoryController.text.trim() : null,
      bannerUrl: bannerUrl,
      startDate: date,
      endDate: date,
      registrationDeadline: _registrationDeadline,
      timeString: '$startStr - $endStr',
      venue: _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : 'Main Campus',
      organizerName: organizerName,
      maxParticipants: widget.eventToEdit?.maxParticipants ?? 0,
      registeredCount: widget.eventToEdit?.registeredCount ?? 0,
      entryFee: _currentFee,
      paymentUpiId: _isPaidEvent ? _upiIdController.text.trim() : null,
      tagline: widget.eventToEdit?.tagline ?? 'Build. Innovate. Solve.',
      teamMinSize: widget.eventToEdit?.teamMinSize ?? 1,
      teamMaxSize: widget.eventToEdit?.teamMaxSize ?? 4,
      isFeatured: widget.eventToEdit?.isFeatured ?? false,
      isPublished: true,
      eligibility: _eligibilityController.text.trim().isNotEmpty
          ? [_eligibilityController.text.trim()]
          : ['Open to all students with a valid ID.'],
      rules: _rulesController.text.trim().isNotEmpty
          ? [_rulesController.text.trim()]
          : ['Follow institutional code of conduct and standard event guidelines.'],
      customFormFields: _customQuestions,
      prizes: [
        if (_firstPrizeController.text.trim().isNotEmpty)
          PrizeItem(
            rankTitle: '1st Place',
            amount: _firstPrizeController.text.trim(),
            description: 'Winner Trophy & Certificate',
            icon: 'trophy',
          ),
        if (_secondPrizeController.text.trim().isNotEmpty)
          PrizeItem(
            rankTitle: '2nd Place',
            amount: _secondPrizeController.text.trim(),
            description: 'Runner Up Certificate',
            icon: 'medal',
          ),
        if (_thirdPrizeController.text.trim().isNotEmpty)
          PrizeItem(
            rankTitle: '3rd Place',
            amount: _thirdPrizeController.text.trim(),
            description: 'Second Runner Up Certificate',
            icon: 'medal',
          ),
        if (_specialAwardsController.text.trim().isNotEmpty)
          PrizeItem(
            rankTitle: 'Special Awards',
            amount: '',
            description: _specialAwardsController.text.trim(),
            icon: 'award',
          ),
      ],
      timeline: widget.eventToEdit?.timeline ?? [
        TimelineStep(title: 'Registration Opens', time: DateFormat('d MMM yyyy').format(DateTime.now()), isCompleted: true),
        TimelineStep(title: 'Registration Deadline', time: DateFormat('d MMM yyyy').format(_registrationDeadline ?? date.subtract(const Duration(days: 2)))),
        TimelineStep(title: 'Event Day', time: DateFormat('d MMM yyyy').format(date)),
      ],
    );

    final bool success;
    if (isEditing) {
      success = await EventController.instance.updateEvent(savedEvent);
    } else {
      success = await EventController.instance.createEvent(savedEvent);
    }

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Event updated successfully!' : 'Event published successfully to Campus Connect!'),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Failed to update event. Please try again.' : 'Failed to publish event. Please try again.'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create New Event'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Titles
                Text(
                  isEditing ? 'Edit Event Details' : 'Create New Event',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  'Fill in the details below to publish your event to the campus community.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 1. Basic Info Card
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title *',
                          hintText: 'e.g., Annual Tech Symposium',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter event title' : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Provide details about what attendees can expect...',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please provide event description' : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        items: _categoryOptions.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      if (_selectedCategory == 'Others') ...[
                        const SizedBox(height: AppDimens.md),
                        TextFormField(
                          controller: _customCategoryController,
                          decoration: const InputDecoration(
                            labelText: 'Specify Category *',
                            hintText: 'Enter custom category',
                          ),
                          validator: (v) {
                            if (_selectedCategory == 'Others' && (v == null || v.trim().isEmpty)) {
                              return 'Please specify the category name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 2. Schedule Card
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 16, color: AppColors.outlineVariant),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerTile(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: _eventDate != null
                                  ? DateFormat('d MMM yyyy').format(_eventDate!)
                                  : 'Select Date',
                              onTap: () => _pickDate(context, true),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: _buildPickerTile(
                              icon: Icons.event_busy,
                              label: 'Registration Deadline',
                              value: _registrationDeadline != null
                                  ? DateFormat('d MMM yyyy').format(_registrationDeadline!)
                                  : 'Select Deadline',
                              onTap: () => _pickDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerTile(
                              icon: Icons.schedule,
                              label: 'Start Time',
                              value: _startTime != null ? _startTime!.format(context) : '10:00 AM',
                              onTap: () => _pickTime(context, true),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: _buildPickerTile(
                              icon: Icons.update,
                              label: 'End Time',
                              value: _endTime != null ? _endTime!.format(context) : '5:00 PM',
                              onTap: () => _pickTime(context, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 3. Banner Upload Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(AppDimens.md),
                  child: Column(
                    children: [
                      const Icon(Icons.add_photo_alternate, size: 44, color: AppColors.textSecondary),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        'Select Event Poster from Device',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Gallery Button
                      ElevatedButton(
                        onPressed: _pickImageFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0057E7),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Choose from Gallery / Files'),
                      ),

                      // Memory Preview Badge if image is chosen
                      if (_selectedImageBytes != null) ...[
                        const SizedBox(height: AppDimens.md),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _selectedImageBytes!,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.black.withValues(alpha: 0.6),
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  onPressed: _clearSelectedImage,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppDimens.md),
                      TextFormField(
                        controller: _bannerUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Or Image URL',
                          hintText: 'https://',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 4. Logistics Card (Venue, Fee, UPI & QR Preview)
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _venueController,
                        decoration: const InputDecoration(
                          labelText: 'Venue (Hall / Lab / Auditorium name) *',
                          hintText: 'e.g., Student Union Room 301',
                          prefixIcon: Icon(Icons.location_on, color: AppColors.textSecondary),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter venue' : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      TextFormField(
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Entry Fee (₹)',
                          hintText: '0 for Free entry',
                          prefixIcon: Icon(Icons.payments, color: AppColors.textSecondary),
                        ),
                      ),

                      // Conditional UPI Section for Paid Events
                      if (_isPaidEvent) ...[
                        const SizedBox(height: AppDimens.md),
                        const Divider(color: AppColors.outlineVariant),
                        const SizedBox(height: AppDimens.sm),
                        TextFormField(
                          controller: _upiIdController,
                          decoration: const InputDecoration(
                            labelText: 'UPI ID *',
                            hintText: 'clubname@upi',
                            helperText: 'Required for paid events',
                            prefixIcon: Icon(Icons.account_balance, color: AppColors.blue),
                          ),
                        ),
                        const SizedBox(height: AppDimens.md),

                        // Payment QR Preview Container
                        Container(
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Payment QR Preview',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppDimens.sm),
                              Container(
                                width: 128,
                                height: 128,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _upiIdController.text.trim().isNotEmpty
                                    ? QrImageView(
                                        data: _generatedUpiUri,
                                        version: QrVersions.auto,
                                        size: 116,
                                      )
                                    : const Icon(Icons.qr_code_2, size: 54, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppDimens.sm),
                              TextButton.icon(
                                onPressed: () {
                                  if (_upiIdController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a UPI ID first to generate QR.'),
                                        backgroundColor: AppColors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  PaymentQRCard.downloadQrImage(
                                    context: context,
                                    upiUri: _generatedUpiUri,
                                    fileName: _titleController.text.trim().isNotEmpty
                                        ? _titleController.text.trim()
                                        : 'event_upi_qr',
                                    title: _titleController.text.trim().isNotEmpty
                                        ? _titleController.text.trim()
                                        : 'Event Payment QR',
                                  );
                                },
                                icon: const Icon(Icons.download, size: 16, color: AppColors.green),
                                label: const Text(
                                  'Download QR',
                                  style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 5. Eligibility Criteria Card
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eligibility Criteria',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 16, color: AppColors.outlineVariant),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _eligibilityController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Who can participate?',
                          hintText: 'e.g., Open to all 2nd and 3rd year CSE students...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 6. Competition Rules Card
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Competition Rules',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 16, color: AppColors.outlineVariant),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _rulesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Rules & Guidelines',
                          hintText: 'Specify rules, code of conduct, or submission guidelines...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 7. Prizes & Awards Card (Stitch Exact)
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prizes & Awards',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 16, color: AppColors.outlineVariant),
                      const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 500) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstPrizeController,
                                    decoration: const InputDecoration(
                                      labelText: '1st Prize',
                                      hintText: 'e.g., ₹10,000 + Trophy',
                                      prefixIcon: Icon(Icons.emoji_events_outlined, color: AppColors.blue, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: TextFormField(
                                    controller: _secondPrizeController,
                                    decoration: const InputDecoration(
                                      labelText: '2nd Prize',
                                      hintText: 'e.g., ₹5,000 + Medal',
                                      prefixIcon: Icon(Icons.military_tech_outlined, color: AppColors.textSecondary, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: TextFormField(
                                    controller: _thirdPrizeController,
                                    decoration: const InputDecoration(
                                      labelText: '3rd Prize',
                                      hintText: 'e.g., ₹2,500 + Medal',
                                      prefixIcon: Icon(Icons.workspace_premium_outlined, color: AppColors.orange, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                TextFormField(
                                  controller: _firstPrizeController,
                                  decoration: const InputDecoration(
                                    labelText: '1st Prize',
                                    hintText: 'e.g., ₹10,000 + Trophy',
                                    prefixIcon: Icon(Icons.emoji_events_outlined, color: AppColors.blue, size: 20),
                                  ),
                                ),
                                const SizedBox(height: AppDimens.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _secondPrizeController,
                                        decoration: const InputDecoration(
                                          labelText: '2nd Prize',
                                          hintText: 'e.g., ₹5,000 + Medal',
                                          prefixIcon: Icon(Icons.military_tech_outlined, color: AppColors.textSecondary, size: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.sm),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _thirdPrizeController,
                                        decoration: const InputDecoration(
                                          labelText: '3rd Prize',
                                          hintText: 'e.g., ₹2,500 + Medal',
                                          prefixIcon: Icon(Icons.workspace_premium_outlined, color: AppColors.orange, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppDimens.md),
                      TextFormField(
                        controller: _specialAwardsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Special Awards / Mentions',
                          hintText: 'Describe any other recognitions or consolation prizes...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 8. Registration Form Builder Card
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registration Form Builder',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Customize questions attendees must answer.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _addQuestion,
                            icon: const Icon(Icons.add, size: 16, color: AppColors.blue),
                            label: const Text('Add Field', style: TextStyle(color: AppColors.blue, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outlineVariant),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.outlineVariant),

                      // Questions list
                      ..._customQuestions.map((q) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppDimens.md),
                          padding: const EdgeInsets.all(AppDimens.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.drag_indicator, size: 20, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          q.label,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (q.isRequired)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Mandatory',
                                              style: TextStyle(
                                                color: AppColors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                                    onPressed: () {
                                      setState(() => _customQuestions.remove(q));
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 28, bottom: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  child: Text(
                                    q.type == QuestionType.multipleChoice ? 'MCQ Radio' : q.type.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                              if (q.options.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 28, top: 4),
                                  child: Column(
                                    children: q.options.asMap().entries.map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Text('${entry.key + 1}. ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceContainerLowest,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: AppColors.outlineVariant),
                                                ),
                                                child: Text(entry.value, style: const TextStyle(fontSize: 12)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.xl),

                // 8. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Save Draft',
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: PrimaryButton(
                        label: isEditing ? 'Save Changes' : 'Publish Event',
                        isLoading: _isPublishing,
                        backgroundColor: const Color(0xFF008744),
                        onPressed: _isPublishing ? null : _handlePublish,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.md),
      child: child,
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddQuestionDialog extends StatefulWidget {
  final Function(CustomFormField field) onAdd;

  const _AddQuestionDialog({required this.onAdd});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _OptionFieldItem {
  final Key key;
  final TextEditingController controller;
  _OptionFieldItem({required this.key, required this.controller});
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  late final TextEditingController _labelController;
  late final List<_OptionFieldItem> _options;
  QuestionType _selectedType = QuestionType.dropdown;
  bool _isRequired = true;
  String? _optionsError;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _options = [
      _OptionFieldItem(key: UniqueKey(), controller: TextEditingController()),
      _OptionFieldItem(key: UniqueKey(), controller: TextEditingController()),
    ];
  }

  @override
  void dispose() {
    _labelController.dispose();
    for (final opt in _options) {
      opt.controller.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _optionsError = 'Please enter a question title.');
      return;
    }

    final hasOptions = _selectedType == QuestionType.dropdown ||
        _selectedType == QuestionType.multipleChoice ||
        _selectedType == QuestionType.checkbox;

    List<String> options = [];
    if (hasOptions) {
      options = _options
          .map((opt) => opt.controller.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (options.length < 2) {
        setState(() => _optionsError = 'Please provide at least 2 non-empty options.');
        return;
      }
    }

    widget.onAdd(
      CustomFormField(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}',
        label: label,
        type: _selectedType,
        isRequired: _isRequired,
        options: options,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasOptions = _selectedType == QuestionType.dropdown ||
        _selectedType == QuestionType.multipleChoice ||
        _selectedType == QuestionType.checkbox;

    return AlertDialog(
      title: const Text('Add Registration Question'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Question Title *',
                  hintText: 'e.g. T-Shirt Size, Dietary Choice, Experience Level',
                ),
              ),
              const SizedBox(height: AppDimens.md),
              DropdownButtonFormField<QuestionType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Question Format'),
                items: const [
                  DropdownMenuItem(
                    value: QuestionType.dropdown,
                    child: Text('Dropdown Menu (Select One)'),
                  ),
                  DropdownMenuItem(
                    value: QuestionType.multipleChoice,
                    child: Text('Multiple Choice / MCQ (Radio)'),
                  ),
                  DropdownMenuItem(
                    value: QuestionType.checkbox,
                    child: Text('Checkboxes (Multi-Select)'),
                  ),
                  DropdownMenuItem(
                    value: QuestionType.text,
                    child: Text('Short Answer (Single Line)'),
                  ),
                  DropdownMenuItem(
                    value: QuestionType.multiline,
                    child: Text('Paragraph (Multi-Line)'),
                  ),
                ],
                onChanged: (val) => setState(
                  () => _selectedType = val ?? QuestionType.dropdown,
                ),
              ),
              if (hasOptions) ...[
                const SizedBox(height: AppDimens.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Options List *',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _options.add(
                            _OptionFieldItem(
                              key: UniqueKey(),
                              controller: TextEditingController(),
                            ),
                          );
                          _optionsError = null;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.blue),
                      label: const Text(
                        'Add Option',
                        style: TextStyle(color: AppColors.blue, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Padding(
                    key: item.key,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: item.controller,
                            decoration: InputDecoration(
                              hintText: 'Option ${index + 1}',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.outlineVariant),
                              ),
                            ),
                          ),
                        ),
                        if (_options.length > 2)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                final removed = _options.removeAt(index);
                                removed.controller.dispose();
                              });
                            },
                            padding: const EdgeInsets.only(left: 4),
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  );
                }),
                if (_optionsError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_optionsError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                  ),
              ],
              const SizedBox(height: AppDimens.md),
              Row(
                children: [
                  Checkbox(
                    value: _isRequired,
                    onChanged: (val) => setState(() => _isRequired = val ?? true),
                  ),
                  const Text('Mandatory field (Required)'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Add Field'),
        ),
      ],
    );
  }
}

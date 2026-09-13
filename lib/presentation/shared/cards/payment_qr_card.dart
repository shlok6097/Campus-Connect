import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class PaymentQRCard extends StatelessWidget {
  final String upiId;
  final double amount;
  final String eventName;
  final VoidCallback? onDownload;

  const PaymentQRCard({
    super.key,
    required this.upiId,
    required this.amount,
    required this.eventName,
    this.onDownload,
  });

  String get upiUri {
    final cleanUpi = upiId.trim();
    final name = Uri.encodeComponent(eventName.trim().isNotEmpty ? eventName : 'Event Registration');
    final amt = amount.toStringAsFixed(2);
    return 'upi://pay?pa=$cleanUpi&pn=$name&am=$amt&cu=INR';
  }

  static Future<void> downloadQrImage({
    required BuildContext context,
    required String upiUri,
    required String fileName,
    required String title,
  }) async {
    try {
      final qrPainter = QrPainter(
        data: upiUri,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF1C1B1B),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF1C1B1B),
        ),
      );

      final picData = await qrPainter.toImageData(600);
      if (picData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate QR image.'), backgroundColor: AppColors.red),
          );
        }
        return;
      }

      final pngBytes = picData.buffer.asUint8List();
      final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(pngBytes, name: 'qr_$sanitizedName.png', mimeType: 'image/png')],
          text: 'Payment QR for $title',
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_$sanitizedName.png');
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: 'Payment QR for $title',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code image downloaded for $title!'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download QR: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _launchUpiApp(BuildContext context) async {
    final uri = Uri.parse(upiUri);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          Clipboard.setData(ClipboardData(text: upiId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('UPI ID copied ($upiId). Please open your payment app to complete payment.'),
              backgroundColor: AppColors.blue,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: upiId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('UPI ID copied ($upiId). Open any UPI app to pay ₹${amount.toStringAsFixed(0)}.'),
            backgroundColor: AppColors.blue,
          ),
        );
      }
    }
  }

  void _handleCopyUpi(BuildContext context) {
    Clipboard.setData(ClipboardData(text: upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard!'),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = amount > 0 ? '₹${amount.toStringAsFixed(0)}' : '₹0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Entry Fee: $displayAmount',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // QR Box Container
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                // White card enclosing QR
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: upiId.trim().isNotEmpty
                      ? QrImageView(
                          data: upiUri,
                          version: QrVersions.auto,
                          size: 130,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1C1B1B),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1C1B1B),
                          ),
                        )
                      : const SizedBox(
                          width: 130,
                          height: 130,
                          child: Icon(Icons.qr_code_2, size: 64, color: AppColors.textSecondary),
                        ),
                ),
                const SizedBox(height: AppDimens.sm),

                // UPI ID label
                Text(
                  'UPI ID',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () => _handleCopyUpi(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          upiId.isNotEmpty ? upiId : 'Not configured',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 14, color: AppColors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () => _launchUpiApp(context),
                  icon: const Icon(Icons.account_balance_wallet, size: 18),
                  label: const Text('Pay / Open UPI App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onDownload ??
                      () {
                        downloadQrImage(
                          context: context,
                          upiUri: upiUri,
                          fileName: eventName.isNotEmpty ? eventName : 'event_payment_qr',
                          title: eventName.isNotEmpty ? eventName : 'Event Payment',
                        );
                      },
                  icon: const Icon(Icons.download, size: 18, color: AppColors.blue),
                  label: const Text('Download QR', style: TextStyle(color: AppColors.blue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blue),
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

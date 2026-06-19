import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_top_bar.dart';

class TransferConfirmPage extends StatelessWidget {
  final Map<String, dynamic> recipient;
  final String channel;
  final double amount;
  final String note;
  final double fee;

  const TransferConfirmPage({
    super.key,
    required this.recipient,
    required this.channel,
    required this.amount,
    required this.note,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) {
    final total = amount + fee;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(title: 'Konfirmasi Transfer', onBack: () => context.go('/transfer/amount')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Recipient summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line2, width: 1.5),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        channel == 'bank'
                            ? Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.tone(recipient['tone'] as String)[0],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(recipient['name'] as String,
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.tone(recipient['tone'] as String)[1],
                                        fontSize: 16,
                                      )),
                                ),
                              )
                            : AppAvatar(name: recipient['name'] as String, size: 60),
                        const SizedBox(height: 12),
                        const Text('Transfer ke',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: AppColors.slate400,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 4),
                        Text(channel == 'bank' ? (recipient['sub'] as String) : (recipient['name'] as String),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            )),
                        const SizedBox(height: 2),
                        Text(recipient['sub'] as String,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: AppColors.slate400,
                            )),
                        const SizedBox(height: 18),
                        Text(CurrencyFormatter.format(amount),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Detail rows
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line2, width: 1.5),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        _Line(label: 'Nominal Transfer', value: CurrencyFormatter.format(amount)),
                        const Divider(height: 1, color: AppColors.line2),
                        _Line(label: 'Biaya Admin', value: fee > 0 ? CurrencyFormatter.format(fee) : 'Gratis'),
                        if (note.isNotEmpty) ...[
                          const Divider(height: 1, color: AppColors.line2),
                          _Line(label: 'Catatan', value: note),
                        ],
                        const Divider(height: 1, color: AppColors.line2),
                        _Line(label: 'Total Bayar', value: CurrencyFormatter.format(total), bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Source
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line2, width: 1.5),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Saldo DKG',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  )),
                              SizedBox(height: 2),
                              Text('Sumber Dana Utama',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    color: AppColors.slate400,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: AppColors.line2, width: 1.5),
              boxShadow: AppColors.shadowCard,
            ),
            child: AppButton(
              label: 'Konfirmasi & Bayar',
              icon: const Icon(Icons.lock_outline_rounded, size: 19, color: Colors.white),
              onPressed: () => context.go('/pin', extra: {
                'kind': 'transfer',
                'recipient': recipient,
                'channel': channel,
                'amount': amount,
                'note': note,
                'fee': fee,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Line({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: bold ? 15.0 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? AppColors.ink : AppColors.slate500,
              )),
          Text(value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: bold ? 16.0 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: bold ? AppColors.primary : AppColors.ink,
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/account/account_bloc.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/num_pad.dart';

class TransferAmountPage extends StatefulWidget {
  final Map<String, dynamic> recipient;
  final String channel;

  const TransferAmountPage({super.key, required this.recipient, required this.channel});

  @override
  State<TransferAmountPage> createState() => _TransferAmountPageState();
}

class _TransferAmountPageState extends State<TransferAmountPage> {
  int _amount = 0;
  String _note = '';

  final _chips = [20000, 50000, 100000, 250000];

  void _onKey(String k) {
    setState(() {
      if (k == 'del') {
        _amount = _amount ~/ 10;
      } else if (k == '000') {
        _amount = (_amount * 1000) > 100000000 ? _amount : _amount * 1000;
      } else {
        final n = _amount * 10 + int.parse(k);
        _amount = n > 100000000 ? _amount : n;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.select<AccountBloc, double>((b) {
      final s = b.state;
      return s is AccountLoaded ? s.account.balance : 0.0;
    });
    final fee = widget.channel == 'bank' ? 2500 : 0;
    final enough = _amount <= balance;
    final valid = _amount >= 1000 && enough;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(title: 'Nominal Transfer', onBack: () => context.go('/transfer')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  // Recipient card
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
                        widget.channel == 'bank'
                            ? Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.tone(widget.recipient['tone'] as String)[0],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(widget.recipient['name'] as String,
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.tone(widget.recipient['tone'] as String)[1],
                                        fontSize: 14,
                                      )),
                                ),
                              )
                            : AppAvatar(name: widget.recipient['name'] as String, size: 44),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.channel == 'bank'
                                    ? (widget.recipient['sub'] as String)
                                    : (widget.recipient['name'] as String),
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(widget.recipient['sub'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    color: AppColors.slate400,
                                  )),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line2, width: 1.5),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        const Text('NOMINAL TRANSFER',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              color: AppColors.slate400,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            )),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('Rp ',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: _amount > 0 ? AppColors.primary : AppColors.slate300,
                                )),
                            Text(
                              _amount > 0 ? _amount.toLocaleString() : '0',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: _amount > 0 ? AppColors.ink : AppColors.slate300,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: enough ? AppColors.line2 : AppColors.redSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            enough ? 'Saldo Aktif: ${CurrencyFormatter.format(balance)}' : 'Saldo tidak mencukupi',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: enough ? AppColors.slate600 : AppColors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _chips.map((c) {
                            final isSelected = _amount == c;
                            return GestureDetector(
                              onTap: () => setState(() => _amount = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primarySurface : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.line,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(CurrencyFormatter.formatInt(c),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppColors.primary : AppColors.slate600,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Note Field Card
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line2, width: 1.5),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: AppField(
                      value: _note,
                      onChanged: (v) => setState(() => _note = v),
                      placeholder: 'Tambah catatan transfer (opsional)',
                      prefixIcon: const Icon(Icons.receipt_outlined, size: 20, color: AppColors.slate400),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // NumPad and Button pinned at the bottom on a white premium panel
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: AppColors.line2, width: 1.5),
              boxShadow: AppColors.shadowCard,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NumPad(onKey: _onKey),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Lanjutkan',
                  onPressed: valid
                      ? () => context.go('/transfer/confirm', extra: {
                            'recipient': widget.recipient,
                            'channel': widget.channel,
                            'amount': _amount.toDouble(),
                            'note': _note,
                            'fee': fee.toDouble(),
                          })
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

extension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

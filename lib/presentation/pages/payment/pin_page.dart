import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/feature_icon.dart';
import '../../widgets/pin_pad.dart';

class PinPage extends StatefulWidget {
  final Map<String, dynamic> flowData;
  const PinPage({super.key, required this.flowData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _pin = '';
  bool _busy = false;
  bool _hasError = false;

  void _onComplete(String pin) {
    setState(() => _busy = true);
    _processPayment(pin);
  }

  void _processPayment(String pin) {
    final flow = widget.flowData;
    final kind = flow['kind'] as String? ?? '';

    debugPrint('[PinPage] Simulating payment success locally for kind=$kind with PIN=$pin');

    // Simulate network delay of 1.2 seconds, then redirect to success page directly
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (kind == 'transfer') {
        context.go('/success', extra: {
          'title': 'Transfer berhasil',
          'subtitle': flow['note'] as String? ?? 'Transfer',
          'amount': (flow['amount'] as num).toDouble(),
          'lines': [
            ['Jumlah', CurrencyFormatter.format((flow['amount'] as num).toDouble())],
            ['Saldo setelah', CurrencyFormatter.format(1000000.0)], // mock balance
            ['Ref', 'DKGMOCK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'],
          ],
        });
      } else if (kind == 'topup') {
        context.go('/success', extra: {
          'title': 'Top up berhasil',
          'subtitle': 'Saldo kamu bertambah',
          'amount': (flow['amount'] as num).toDouble(),
          'lines': [
            ['Jumlah', CurrencyFormatter.format((flow['amount'] as num).toDouble())],
            ['Saldo sekarang', CurrencyFormatter.format(1000000.0)],
          ],
        });
      } else if (kind == 'payment' || kind == 'deeplink') {
        context.go('/success', extra: {
          'title': 'Pembayaran berhasil',
          'subtitle': flow['description'] as String? ?? 'Pembayaran QRIS',
          'amount': (flow['amount'] as num).toDouble(),
          'lines': [
            ['Jumlah', CurrencyFormatter.format((flow['amount'] as num).toDouble())],
            ['Saldo setelah', CurrencyFormatter.format(1000000.0)],
            ['Ref', 'DKGMOCK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'],
          ],
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        debugPrint('[PinPage] Received PaymentState: $state');
        if (state is PaymentTransferSuccess) {
          debugPrint('[PinPage] PaymentTransferSuccess: routing to /success');
          final result = state.result;
          context.go('/success', extra: {
            'title': 'Transfer berhasil',
            'subtitle': result.description,
            'amount': result.amount,
            'lines': [
              ['Jumlah', CurrencyFormatter.format(result.amount)],
              ['Saldo setelah', CurrencyFormatter.format(result.balanceAfter)],
              ['Ref', 'DKG${result.transactionId}'],
            ],
          });
        } else if (state is PaymentTopupSuccess) {
          debugPrint('[PinPage] PaymentTopupSuccess: routing to /success');
          context.go('/success', extra: {
            'title': 'Top up berhasil',
            'subtitle': 'Saldo kamu bertambah',
            'amount': state.amount,
            'lines': [
              ['Jumlah', CurrencyFormatter.format(state.amount)],
              ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
            ],
          });
        } else if (state is PaymentInvalidOtp) {
          debugPrint('[PinPage] PaymentInvalidOtp: OTP is invalid');
          setState(() { _busy = false; _hasError = true; _pin = ''; });
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() => _hasError = false);
          });
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error PIN/OTP'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is PaymentInsufficientBalance) {
          debugPrint('[PinPage] PaymentInsufficientBalance');
          setState(() { _busy = false; _pin = ''; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saldo tidak mencukupi. Saldo Anda: ${CurrencyFormatter.format(state.balance)}'),
              backgroundColor: AppColors.red,
            ),
          );
        } else if (state is PaymentError) {
          debugPrint('[PinPage] PaymentError: ${state.message}');
          setState(() => _busy = false);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Transaksi Gagal'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                  onPressed: () => context.go('/home'),
                ),
              ),
              if (_busy) ...[
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 18),
                      Text('Memproses transaksi…',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate600,
                          )),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Icon(Icons.lock_outline_rounded, size: 26, color: AppColors.primary)),
                        ),
                        const SizedBox(height: 16),
                        const Text('Masukkan PIN',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            )),
                        const SizedBox(height: 6),
                        const Text('Masukkan 6 digit PIN keamanan kamu',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.5, color: AppColors.slate500)),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          transform: _hasError ? (Matrix4.identity()..translate(10.0)) : Matrix4.identity(),
                          child: PinPad(
                            value: _pin,
                            onChanged: (v) => setState(() => _pin = v),
                            onComplete: _onComplete,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text.rich(TextSpan(
                          text: 'Lupa PIN? ',
                          style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12.5, color: AppColors.slate400),
                          children: [
                            TextSpan(
                              text: 'Reset',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

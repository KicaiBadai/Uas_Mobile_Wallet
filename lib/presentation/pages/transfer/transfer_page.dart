import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_top_bar.dart';

const _contacts = [
  {'id': '1', 'name': 'Budi Santoso', 'sub': '0812-3456-7890', 'fav': true},
  {'id': '2', 'name': 'Citra Dewi', 'sub': '0856-1122-3344', 'fav': true},
  {'id': '3', 'name': 'Eko Prasetyo', 'sub': '0813-9988-7766', 'fav': false},
  {'id': '4', 'name': 'Fitri Handayani', 'sub': '0821-4455-6677', 'fav': false},
  {'id': '5', 'name': 'Gilang Ramadhan', 'sub': '0857-3344-1122', 'fav': false},
];

const _banks = [
  {'id': 'bca', 'name': 'BCA', 'sub': 'Bank Central Asia', 'tone': 'blue'},
  {'id': 'bni', 'name': 'BNI', 'sub': 'Bank Negara Indonesia', 'tone': 'amber'},
  {'id': 'mandiri', 'name': 'Mandiri', 'sub': 'Bank Mandiri', 'tone': 'blue'},
  {'id': 'bri', 'name': 'BRI', 'sub': 'Bank Rakyat Indonesia', 'tone': 'blue'},
];

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});
  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String _tab = 'dkg';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(title: 'Transfer', onBack: () => context.go('/home')),
      body: Column(
        children: [
          Container(
            color: AppColors.bg,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.line2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [['dkg', 'Sesama DKG'], ['bank', 'Ke Bank']].map((t) {
                      final active = _tab == t[0];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _tab = t[0]; _q = ''; }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: active ? AppColors.shadowSoft : null,
                            ),
                            child: Center(
                              child: Text(t[1],
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: active ? AppColors.primary : AppColors.slate500,
                                  )),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                AppField(
                  value: _q,
                  onChanged: (v) => setState(() => _q = v),
                  placeholder: _tab == 'dkg' ? 'Cari nama atau nomor HP' : 'Cari nama bank',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.slate400),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _tab == 'dkg' ? _buildContacts() : _buildBanks(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContacts() {
    final filtered = _contacts.where((c) =>
        (c['name'] as String).toLowerCase().contains(_q.toLowerCase())).toList();
    final favorites = filtered.where((c) => c['fav'] as bool).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (favorites.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 12, bottom: 12),
            child: Text('Kontak Favorit',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                  letterSpacing: 0.5,
                )),
          ),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              itemBuilder: (context, idx) {
                final c = favorites[idx];
                return GestureDetector(
                  onTap: () => context.go('/transfer/amount', extra: {
                    'recipient': c,
                    'channel': 'dkg',
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 76,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: AppAvatar(name: c['name'] as String, size: 50),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (c['name'] as String).split(' ').first,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 10, bottom: 10),
          child: Text('Semua Kontak',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.slate400,
                letterSpacing: 0.5,
              )),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line2, width: 1.5),
            boxShadow: AppColors.shadowSoft,
          ),
          child: Column(
            children: filtered.asMap().entries.map((e) {
              final i = e.key;
              final c = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, indent: 72, color: AppColors.line2),
                  GestureDetector(
                    onTap: () => context.go('/transfer/amount', extra: {
                      'recipient': c,
                      'channel': 'dkg',
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          AppAvatar(name: c['name'] as String, size: 46),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['name'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    )),
                                const SizedBox(height: 2),
                                Text(c['sub'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      color: AppColors.slate400,
                                    )),
                              ],
                            ),
                          ),
                          if (c['fav'] as bool)
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.amber)
                          else
                            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slate400),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBanks() {
    final filtered = _banks.where((b) =>
        (b['sub'] as String).toLowerCase().contains(_q.toLowerCase()) ||
        (b['name'] as String).toLowerCase().contains(_q.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 10, bottom: 10),
          child: Text('Daftar Bank',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.slate400,
                letterSpacing: 0.5,
              )),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line2, width: 1.5),
            boxShadow: AppColors.shadowSoft,
          ),
          child: Column(
            children: filtered.asMap().entries.map((e) {
              final i = e.key;
              final b = e.value;
              final colors = AppColors.tone(b['tone'] as String);
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, indent: 72, color: AppColors.line2),
                  GestureDetector(
                    onTap: () => context.go('/transfer/amount', extra: {
                      'recipient': b,
                      'channel': 'bank',
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: colors[0],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(b['name'] as String,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w800,
                                    color: colors[1],
                                    fontSize: 14.5,
                                  )),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['sub'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    )),
                                const SizedBox(height: 2),
                                const Text('Biaya transfer Rp2.500',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      color: AppColors.slate400,
                                    )),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slate400),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

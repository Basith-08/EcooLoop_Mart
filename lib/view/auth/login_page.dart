import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../state/auth_state.dart';
import '../admin/admin_home_page.dart';
import '../warga/warga_home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Color _green = const Color(0xFF2D9F5D);
  final Color _orange = const Color(0xFFFF8C42);

  /// Flag untuk mencegah navigasi/dialog handling berulang saat provider
  /// tetap berada pada state Authenticated.
  bool _isHandlingAuth = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // ketika pindah tab, bersihkan input dan reset flag penanganan
      setState(() {
        _usernameController.clear();
        _passwordController.clear();
        _isHandlingAuth = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    return _tabController.index == 0 ? _green : _orange;
  }

  void _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    // panggil login (asumsi AuthViewModel mengatur state ke AuthLoading -> Authenticated/ Error)
    await authViewModel.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    // Navigasi/deteksi dilakukan oleh Consumer di build sehingga kita tidak memanggil navigator di sini.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F8EF),
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            // Jika sudah ter-authenticate dan belum ditangani -> handle sekali
            if (authViewModel.state is Authenticated && !_isHandlingAuth) {
              _isHandlingAuth = true; // set agar tidak dipanggil berulang
              final user = (authViewModel.state as Authenticated).user;
              final bool isAdmin = user.isAdmin == true;

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final activeTabIsAdmin = _tabController.index == 1;

                if (activeTabIsAdmin && isAdmin) {
                  // Admin tab aktif & user admin -> navigasi
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AdminHomePage()),
                  );
                } else if (!activeTabIsAdmin && !isAdmin) {
                  // Warga tab aktif & user bukan admin -> navigasi
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WargaHomePage()),
                  );
                } else {
                  // Role mismatch:
                  // 1) logout agar state tidak lagi Authenticated (mencegah dialog re-show / auto-login)
                  // 2) tampilkan dialog informasi
                  // 3) bersihkan input dan reset flag _isHandlingAuth agar login berikutnya bisa diproses
                  try {
                    // Hentikan session di viewmodel agar state berubah
                    if (authViewModel.logout != null) {
                      // jika ada method logout pada viewmodel
                      await authViewModel.logout();
                    } else {
                      // fallback: kalau tidak ada logout, coba set state melalui method yang sesuai
                      // (jika AuthViewModel tidak punya logout, sesuaikan sendiri pada kode project)
                    }
                  } catch (_) {
                    // ignore logout error; tetap lanjut tampilkan dialog
                  }

                  await showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Peran Akun Tidak Sesuai'),
                        content: Text(
                          activeTabIsAdmin
                              ? 'Akun ini bukan akun Admin. Silakan login melalui tab WARGA atau gunakan akun Admin.'
                              : 'Akun ini adalah Admin. Silakan login melalui tab ADMIN.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(); // tutup dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  // setelah dialog ditutup, bersihkan input dan reset flag handling
                  if (mounted) {
                    setState(() {
                      _usernameController.clear();
                      _passwordController.clear();
                      _isHandlingAuth = false;
                    });
                  }
                }
              });
            }

            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      _buildBranding(),
                      const SizedBox(height: 20),
                      _buildLoginCard(authViewModel),
                      const SizedBox(height: 14),
                      if (_tabController.index == 0)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Baru di sini? Daftar Warga',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      const SizedBox(height: 22),
                      InkWell(
                        onTap: _showHowToDialog,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.help_outline,
                                size: 18,
                                color: Color(0xFF8E96A3),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'HowTo & FAQs',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E96A3),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        '© 2025-2026 EcoLoop Mart—Ver 2.1',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB4B9C3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/icons/app_icon.png'),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'EcoLoop-',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
              TextSpan(
                text: 'Mart',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _orange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ekosistem Tukar Sampah Jadi Sembako',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF7A838F),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthViewModel authViewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border.all(
                color: const Color(0xFFE8EAEF),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: _primaryColor, width: 3),
                insets: const EdgeInsets.symmetric(horizontal: 36),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: _primaryColor,
              unselectedLabelColor: const Color(0xFF9DA3AE),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'WARGA'),
                Tab(text: 'ADMIN'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput(
                    controller: _usernameController,
                    hint: 'Username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    controller: _passwordController,
                    hint: 'Password',
                    obscure: true,
                    icon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authViewModel.state is AuthLoading
                          ? null
                          : () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: authViewModel.state is AuthLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (authViewModel.state is AuthError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        (authViewModel.state as AuthError).message,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFB0B6C3)),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hint harus diisi';
        }
        return null;
      },
    );
  }

  void _showHowToDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        final controller = PageController();
        int currentPage = 0;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final slides = _howToSlides();
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 330,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.close, color: Color(0xFFB0B6C3)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 360,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: slides.length,
                          onPageChanged: (index) {
                            setStateDialog(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) => slides[index],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(slides.length, (index) {
                          final isActive = index == currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 18 : 7,
                            decoration: BoxDecoration(
                              color:
                                  isActive ? _green : const Color(0xFFD0D5DD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentPage == slides.length - 1) {
                              Navigator.of(context).pop();
                            } else {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentPage == slides.length - 1
                                    ? 'Saya Mengerti'
                                    : 'Lanjut',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                currentPage == slides.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _howToSlides() {
    return [
      _buildDialogSlide(
        icon: Icons.recycling,
        iconColor: _green,
        title: 'Selamat Datang!',
        content: const Text(
          'EcoLoop Mart bantu kamu tukar sampah jadi sembako gratis. Gampang dan berkah!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF5C6573),
          ),
        ),
      ),
      _buildDialogSlide(
        icon: Icons.inventory_2_outlined,
        iconColor: _orange,
        title: 'Pilah Sampahmu',
        content: Column(
          children: [
            _infoCard(
              color: const Color(0xFFE8F7ED),
              border: _green,
              icon: Icons.check_circle_outline,
              title: 'DITERIMA (CUAN)',
              description:
                  'Kardus, Botol Plastik Bersih, Kaleng, Minyak Jelantah.',
              textColor: _green,
            ),
            const SizedBox(height: 12),
            _infoCard(
              color: const Color(0xFFFCEBEA),
              border: const Color(0xFFD94D48),
              icon: Icons.highlight_off,
              title: 'DITOLAK',
              description: 'Sampah Basah, Sisa Makanan, Popok, Kaca Pecah.',
              textColor: const Color(0xFFD94D48),
            ),
          ],
        ),
      ),
      _buildDialogSlide(
        icon: Icons.help_outline,
        iconColor: const Color(0xFF2E84E6),
        title: 'Gimana Caranya?',
        content: Column(
          children: [
            _bulletStep(number: '1', text: 'Pisahkan sampah kering & bersih.'),
            _bulletStep(number: '2', text: 'Bawa ke admin, tunjukkan QR Code.'),
            _bulletStep(number: '3', text: 'Terima Poin & Tukar Sembako!'),
          ],
        ),
      ),
      _buildDialogSlide(
        icon: Icons.lock_outline,
        iconColor: const Color(0xFFE1444B),
        title: 'Bantuan Akun',
        content: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE7C891)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ Jangan panik! Demi keamanan, reset password hanya bisa dilakukan oleh Petugas Admin.',
                style: TextStyle(
                  color: Color(0xFF9B6B25),
                  height: 1.35,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Silakan kunjungi loket EcoLoop Mart terdekat.',
                style: TextStyle(
                  color: Color(0xFF9B6B25),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildDialogSlide({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 42),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF323A48),
          ),
        ),
        const SizedBox(height: 14),
        content,
      ],
    );
  }

  Widget _infoCard({
    required Color color,
    required Color border,
    required IconData icon,
    required String title,
    required String description,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF4F5968),
                    height: 1.3,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletStep({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4F5968),
                height: 1.35,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/api_client.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';
import '../widgets/credit_card_widget.dart';
import '../theme/app_colors.dart';
import '../screens/transactions_page.dart';
import '../screens/transfer_page.dart';

/// Écran principal - dashboard reproduisant le design Next.js
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _accounts = [];
  bool _isLoading = true;
  String? _error;
  String _currentView = 'dashboard';
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final accounts = await ApiClient.getAccounts();

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is ApiException
              ? e.message
              : 'Erreur lors du chargement des comptes';
          _isLoading = false;
        });
      }
    }
  }

  void _handleViewTransactions(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
      _currentView = 'transactions';
    });
  }

  void _handleTransfer([String? accountId]) {
    setState(() {
      _selectedAccountId = accountId;
      _currentView = 'transfers';
    });
  }

  void _handleBackToDashboard() {
    setState(() {
      _currentView = 'dashboard';
      _selectedAccountId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildMainContent(),
      drawer: MediaQuery.of(context).size.width <= 768
          ? _buildMobileDrawer()
          : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/elliora_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Elliora Banking',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Top Bar Mobile
        _buildMobileTopBar(),

        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildContentByView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width <= 768)
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
                iconSize: 20,
              ),
            if (MediaQuery.of(context).size.width <= 768)
              const SizedBox(width: 8),
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets/images/elliora_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Elliora Banking',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    'assets/images/elliora_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Elliora Banking',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sidebarText,
                  ),
                ),
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Dashboard',
                    isActive: _currentView == 'dashboard',
                    onTap: () {
                      setState(() => _currentView = 'dashboard');
                      Navigator.pop(context);
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.list_alt,
                    label: 'Transactions',
                    isActive: _currentView == 'transactions',
                    onTap: () {
                      if (_accounts.isNotEmpty) {
                        _handleViewTransactions(_accounts[0]['id']);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.send,
                    label: 'Virements',
                    isActive: _currentView == 'transfers',
                    onTap: () {
                      _handleTransfer();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Logout
          Container(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppColors.sidebarTextMuted,
              ),
              title: Text(
                'Déconnexion',
                style: GoogleFonts.inter(color: AppColors.sidebarTextMuted),
              ),
              onTap: () async {
                Navigator.pop(context);
                await AuthService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    )
                  : null,
              color: isActive ? null : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isActive
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.sidebarHover.withOpacity(0.5),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : AppColors.sidebarTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.sidebarTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentByView() {
    switch (_currentView) {
      case 'transactions':
        return _selectedAccountId != null
            ? TransactionsPage(
                accountId: _selectedAccountId!,
                onBack: _handleBackToDashboard,
              )
            : _buildDashboardContent();
      case 'transfers':
        return TransferPage(
          accounts: _accounts,
          selectedAccountId: _selectedAccountId,
          onBack: _handleBackToDashboard,
          onSuccess: _loadAccounts,
        );
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAccounts,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun compte trouvé',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contactez votre banque pour plus d\'informations',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue, Utilisateur 👋',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez vos comptes et transactions en toute sécurité',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _handleTransfer(),
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Nouveau Virement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAccounts,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Section titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes Comptes',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _loadAccounts,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Actualiser'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Cartes de crédit
                ..._accounts
                    .map(
                      (account) => CreditCardWidget(
                        account: account,
                        onViewTransactions: () =>
                            _handleViewTransactions(account['id']),
                        onTransfer: () => _handleTransfer(account['id']),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

void main() {
  runApp(const ParentSoloApp());
}

class ParentSoloApp extends StatelessWidget {
  const ParentSoloApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Solo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE91E63),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const MainAppScreen(),
    );
  }
}

// ============================================
// STRATÉGIE D'AFFICHAGE DE LA PAGE D'ABONNEMENT
// ============================================

class SubscriptionDisplayManager {
  static const int SHOW_AFTER_LAUNCHES = 3; // Afficher après 3 lancements
  static const int SHOW_EVERY_N_DAYS = 7; // Afficher tous les 7 jours
  static const int SHOW_AFTER_N_ACTIONS = 10; // Afficher après 10 actions

  // Utiliser SharedPreferences pour stocker ces valeurs
  static int launchCount = 0;
  static DateTime? lastShownDate;
  static int actionCount = 0;

  // Vérifier si on doit afficher la page d'abonnement
  static bool shouldShowSubscription(bool isPremium) {
    if (isPremium) return false;

    // 1. Au démarrage : afficher après N lancements
    if (launchCount >= SHOW_AFTER_LAUNCHES && launchCount % 5 == 0) {
      return true;
    }

    // 2. Périodiquement : tous les N jours
    if (lastShownDate != null) {
      final daysSinceLastShown = DateTime.now().difference(lastShownDate!).inDays;
      if (daysSinceLastShown >= SHOW_EVERY_N_DAYS) {
        return true;
      }
    }

    // 3. Après N actions (swipes, messages, etc.)
    if (actionCount >= SHOW_AFTER_N_ACTIONS) {
      actionCount = 0; // Reset
      return true;
    }

    return false;
  }

  // Afficher la page d'abonnement
  static void showSubscriptionPage(BuildContext context) {
    lastShownDate = DateTime.now();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubscriptionPage(fromPrompt: true),
        fullscreenDialog: true,
      ),
    );
  }

  // Incrémenter le compteur d'actions
  static void incrementActionCount() {
    actionCount++;
  }

  // Incrémenter le compteur de lancements
  static void incrementLaunchCount() {
    launchCount++;
  }
}

// ============================================
// ÉCRAN PRINCIPAL DE L'APPLICATION
// ============================================

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    SubscriptionDisplayManager.incrementLaunchCount();

    // Vérifier si on doit afficher la page d'abonnement au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SubscriptionDisplayManager.shouldShowSubscription(isPremium)) {
        SubscriptionDisplayManager.showSubscriptionPage(context);
      }
    });
  }

  void _simulateUserAction() {
    // Simuler une action utilisateur (swipe, message, etc.)
    SubscriptionDisplayManager.incrementActionCount();

    // Vérifier si on doit afficher l'abonnement
    if (SubscriptionDisplayManager.shouldShowSubscription(isPremium)) {
      SubscriptionDisplayManager.showSubscriptionPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Parent Solo',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (isPremium)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    'Premium',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 100, color: Color(0xFFE91E63).withOpacity(0.3)),
            const SizedBox(height: 20),
            const Text(
              'Bienvenue sur Parent Solo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                _simulateUserAction();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action effectuée !')),
                );
              },
              icon: const Icon(Icons.touch_app),
              label: const Text('Simuler une action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionPage(
                      fromPrompt: false,
                      onSubscribed: () {
                        setState(() {
                          isPremium = true;
                        });
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('Voir les abonnements'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PAGE D'ABONNEMENT
// ============================================

class SubscriptionPage extends StatefulWidget {
  final bool fromPrompt;
  final VoidCallback? onSubscribed;

  const SubscriptionPage({
    Key? key,
    this.fromPrompt = false,
    this.onSubscribed,
  }) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedPlan = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubscription(String planName, String price, String currency) {
    // Configuration PayPal selon le plan choisi
    final transactions = [
      {
        "amount": {
          "total": price,
          "currency": currency,
          "details": {
            "subtotal": price,
            "shipping": '0',
            "shipping_discount": 0
          }
        },
        "description": "Abonnement $planName - Parent Solo",
        "item_list": {
          "items": [
            {
              "name": planName,
              "quantity": 1,
              "price": price,
              "currency": currency
            }
          ],
        }
      }
    ];

    // Décommenter pour utiliser PayPal en production

    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true,
        clientId: "VOTRE_CLIENT_ID",
        secretKey: "VOTRE_SECRET_KEY",
        transactions: transactions,
        note: "Merci pour votre abonnement à Parent Solo !",
        onSuccess: (Map params) async {
          log("onSuccess: $params");
          _showSuccessDialog();
        },
        onError: (error) {
          log("onError: $error");
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du paiement: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onCancel: () {
          print('cancelled:');
          Navigator.pop(context);
        },
      ),
    ));

    // Simulation pour la démo
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFF06292)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Félicitations ! 🎉',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Votre abonnement est activé',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialogue
                Navigator.pop(context); // Fermer la page d'abonnement
                widget.onSubscribed?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Commencer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.fromPrompt
            ? IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildFeatures(),
                  const SizedBox(height: 40),
                  _buildPlanCard(
                    index: 0,
                    title: 'Parent Solo Zen',
                    subtitle: 'L\'essentiel pour commencer',
                    price: '9,90',
                    period: '/mois',
                    color: const Color(0xFF2196F3),
                    icon: Icons.favorite_border,
                    features: [
                      'Accès complet à l\'application',
                      'Profils illimités',
                      'Messagerie de base',
                      'Notifications en temps réel',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPlanCard(
                    index: 1,
                    title: 'Parent Solo Premium',
                    subtitle: 'L\'expérience complète',
                    price: '99',
                    period: '/mois',
                    color: const Color(0xFFE91E63),
                    icon: Icons.workspace_premium,
                    isPopular: true,
                    features: [
                      'Tout de Parent Solo Zen',
                      'Chat IA expert en parentalité',
                      'Ressources exclusives',
                      'Conseils personnalisés',
                      'Support prioritaire',
                      'Badge Premium',
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildTrustIndicators(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF06292)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          'Trouvez l\'amour en tant que parent',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Rejoignez la communauté des parents célibataires',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildFeatureRow(
            icon: Icons.verified_user,
            text: 'Profils vérifiés',
            color: const Color(0xFF2196F3),
          ),
          const Divider(height: 30),
          _buildFeatureRow(
            icon: Icons.lock,
            text: 'Données sécurisées',
            color: const Color(0xFFE91E63),
          ),
          /*const Divider(height: 30),
          _buildFeatureRow(
            icon: Icons.people,
            text: '+50 000 parents actifs',
            color: const Color(0xFF4CAF50),
          ),*/
        ],
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required Color color,
    required IconData icon,
    required List<String> features,
    bool isPopular = false,
  }) {
    final isSelected = selectedPlan == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? color.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '€/CHF',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            period,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _handleSubscription(title, price, 'EUR');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: isSelected ? 8 : 2,
                  ),
                  child: const Text(
                    'S\'abonner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'POPULAIRE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Paiement sécurisé par PayPal',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Annulez à tout moment',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
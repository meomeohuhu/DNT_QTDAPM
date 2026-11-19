import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/traceability_provider.dart';
import 'services/firebase_service.dart';
import 'views/screens/customer/customer_home_screen.dart';
import 'views/screens/farmer/farmer_dashboard_screen.dart';
import 'views/screens/supplier/supplier_inventory_screen.dart';
import 'views/screens/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (const bool.fromEnvironment('FRESHFARM_FIREBASE')) {
    await FirebaseService.initialize();
  }

  runApp(const FreshFarmApp());
}

class FreshFarmApp extends StatelessWidget {
  const FreshFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => TraceabilityProvider()),
      ],
      child: MaterialApp(
        title: 'FreshFarm E-Commerce',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const RoleBasedMainScreen(),
      ),
    );
  }
}

class RoleBasedMainScreen extends StatelessWidget {
  const RoleBasedMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Dynamic screen switching based on active actor/role
    switch (auth.activeRole) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.farmer:
        return const FarmerDashboardScreen();
      case UserRole.supplier:
        return const SupplierInventoryScreen();
      case UserRole.admin:
        return const AdminDashboardScreen();
    }
  }
}

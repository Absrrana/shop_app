import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import '../screens/auth_screen.dart';
import '../providers/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // we
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (auth) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(
            '',
            '',
            [],
          ),
          update: (ctx, auth, previousProducts) => Products(
            auth.token ?? '',
            auth.userId ?? '',
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (cart) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(
            '',
            '',
            [],
          ),
          update: (ctx, auth, previousOrders) => Orders(
            auth.token!,
            auth.userId!,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Shop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              colorScheme: const ColorScheme.light(
                primary: Colors.deepOrangeAccent,
                secondary: Colors.blue,
                onPrimary: Colors.white,
                onSecondary: Colors.black,
              ),
              fontFamily: 'Lato'),
          home:
              auth.isAuth // if the user is authenticated then show the home screen
                  ? ProductsOverviewScreen() // else show the auth screen
                  : FutureBuilder(
                      // this future builder is used to check if the user is already logged in or not
                      future: auth
                          .tryAutoLogin(), // this future is used to check if the user is already logged in or not
                      builder: (ctx,
                              authResultSnapshot) => // this builder is used to show the splash screen while the future is being executed
                          authResultSnapshot
                                      .connectionState == // this is used to check if the future is completed or not
                                  ConnectionState
                                      .waiting // if the future is not completed then show the splash screen
                              ? SplashScreen() // if the future is completed then show the auth screen
                              : AuthScreen(),
                    ),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

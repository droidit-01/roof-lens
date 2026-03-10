import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/roof_provider.dart';
import 'presentation/providers/camera_provider.dart';
import 'presentation/screens/home_screen.dart';

//Developed by: Jay Vekariya
//Date: 09 March, 2026

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D1117),
  ));
  runApp(const RoofViewerApp());
}

class RoofViewerApp extends StatelessWidget {
  const RoofViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoofProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: MaterialApp(
        title: 'RoofLens',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A90D9),
            secondary: Color(0xFF7B68EE),
            surface: Color(0xFF141826),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          tabBarTheme: const TabBarThemeData(
            indicatorColor: Color(0xFF4A90D9),
            labelColor: Color(0xFF4A90D9),
            unselectedLabelColor: Colors.white38,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

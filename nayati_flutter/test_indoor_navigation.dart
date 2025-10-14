import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/providers/indoor_navigation_provider.dart';
import 'lib/screens/indoor_navigation_screen.dart';

void main() {
  runApp(const IndoorNavigationTestApp());
}

class IndoorNavigationTestApp extends StatelessWidget {
  const IndoorNavigationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IndoorNavigationProvider(),
      child: MaterialApp(
        title: 'Indoor Navigation Test',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const IndoorNavigationTestScreen(),
      ),
    );
  }
}

class IndoorNavigationTestScreen extends StatelessWidget {
  const IndoorNavigationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Navigation Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_outlined,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Indoor Navigation Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test the indoor navigation feature with pre-fed building maps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IndoorNavigationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Start Indoor Navigation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Available Buildings:\n• University Main Building\n• City Shopping Mall\n• City General Hospital',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

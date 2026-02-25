import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!mounted) return;
      setState(() {
        _hasConnection = !results.contains(ConnectivityResult.none);
      });
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      _hasConnection = !results.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_hasConnection)
          Container(
            height: 32,
            width: double.infinity,
            color: Colors.red[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'İnternet bağlantısı yok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _checkInitialConnection,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    'Tekrar Dene',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

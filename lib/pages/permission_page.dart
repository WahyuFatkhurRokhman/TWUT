import 'package:flutter/material.dart';
import 'package:music_player/services/music_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  final VoidCallback onGranted;

  const PermissionPage({super.key, required this.onGranted});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _isChecking = false;

  Future<void> _requestPermission() async {
    setState(() => _isChecking = true);
    
    bool granted = await MusicScanner.requestPermissions();
    
    if (granted) {
      widget.onGranted();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Izin Diperlukan"),
            content: const Text(
              "Aplikasi memerlukan izin akses penyimpanan untuk memindai file musik di perangkat Anda. "
              "Silakan aktifkan izin di Pengaturan.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text("Buka Pengaturan"),
              ),
            ],
          ),
        );
      }
    }
    
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music_rounded, size: 100, color: Colors.green),
            const SizedBox(height: 32),
            const Text(
              "Selamat Datang!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Untuk memulai, kami membutuhkan izin untuk mengakses file audio di perangkat Anda agar dapat menampilkan koleksi musik lokal Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            _isChecking
                ? const CircularProgressIndicator(color: Colors.green)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _requestPermission,
                    child: const Text("Berikan Izin", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}

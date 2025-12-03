import 'package:flutter/material.dart';

import '../services/theme_service.dart';
import '../widgets/themed_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedThemeId = AppThemeIds.neoTokyoSkyline;
  final ThemeService _themeService = ThemeService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeId = await _themeService.getCurrentThemeId();
    setState(() {
      _selectedThemeId = themeId;
      _isLoading = false;
    });
  }

  Future<void> _onThemeChanged(String? newThemeId) async {
    if (newThemeId == null) return;
    setState(() {
      _selectedThemeId = newThemeId;
    });
    await _themeService.setCurrentThemeId(newThemeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildThemedBackground(
        _selectedThemeId,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFFFF00A8),
                                    Color(0xFFFFA800),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFFFF00A8),
                              Color(0xFFFFA800),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Themes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildThemeOption(
                        id: AppThemeIds.neonRainGlitch,
                        title: 'Neon Rain & Glitch',
                        subtitle:
                            'Dark cyber sky with neon rain streaks and glitch bars',
                      ),
                      _buildThemeOption(
                        id: AppThemeIds.neoTokyoSkyline,
                        title: 'Neo-Tokyo Skyline',
                        subtitle:
                            'Futuristic city silhouette with neon accents',
                      ),
                      _buildThemeOption(
                        id: AppThemeIds.cyberRoad,
                        title: 'Cyber Road',
                        subtitle:
                            'Curved neon road with northern lights and cityscape',
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String id,
    required String title,
    required String subtitle,
  }) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: id,
        groupValue: _selectedThemeId,
        activeColor: Colors.orangeAccent,
        onChanged: _onThemeChanged,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
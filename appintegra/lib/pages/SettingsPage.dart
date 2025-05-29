import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Conta
            _buildSectionHeader('CONTA'),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Perfil',
              subtitle: 'Configurações do seu perfil',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
              subtitle: 'Gerenciar alertas',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Privacidade',
              subtitle: 'Controle seus dados',
              onTap: () {},
            ),

            const Divider(height: 20),

            // Seção de Aplicativo
            _buildSectionHeader('APLICATIVO'),
            _buildSettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Aparência',
              subtitle: 'Tema claro ou escuro',
              trailing: CupertinoSwitch(
                value: false,
                onChanged: (bool value) {},
              ),
            ),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Idioma',
              subtitle: 'Português (Brasil)',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.storage_outlined,
              title: 'Armazenamento',
              subtitle: '1.2 GB utilizados',
              onTap: () {},
            ),

            const Divider(height: 20),

            // Seção de Suporte
            _buildSectionHeader('SUPORTE'),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Ajuda',
              subtitle: 'Central de ajuda',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Sobre',
              subtitle: 'Versão 1.0.0',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.logout_outlined,
              title: 'Sair',
              subtitle: 'Encerrar sessão',
              isDestructive: true,
              onTap: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red[100] 
              : Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive 
              ? Colors.red[800] 
              : Colors.blue[800],
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red[800] : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDestructive ? Colors.red[600] : Colors.grey[600],
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 0,
      onTap: onTap,
    );
  }
}
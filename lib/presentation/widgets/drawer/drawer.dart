// Flutter imports:
import 'package:flutter/material.dart';
// Project imports:
import 'package:ous/presentation/pages/Nav/call_screen.dart';
import 'package:ous/presentation/pages/Nav/link_screen.dart';
import 'package:ous/presentation/pages/setting/setting_screen.dart';
import 'package:ous/presentation/widgets/drawer/drawer_user_widget.dart';
// Package imports:
import 'package:url_launcher/url_launcher.dart';

// URL Constants
const String calendarUrl = 'https://www.ous.ac.jp/campuslife/academic_calenda/';
const String handbookUrl = 'https://www.ous.ac.jp/outline/disclosure/handbook/';
const String mylogUrl =
    'https://mylog.pub.ous.ac.jp/uprx/up/pk/pky501/Pky50101.xhtml';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerUserHeader(),
          _buildMenuItem(
            icon: Icons.event_available_outlined,
            title: '行事予定',
            onTap: () => _launchUrl(context, calendarUrl),
          ),
          _buildMenuItem(
            icon: Icons.public_outlined,
            title: 'マイログ',
            onTap: () => _launchUrl(context, mylogUrl),
          ),
          _buildMenuItem(
            icon: Icons.book_outlined,
            title: '学生便覧',
            onTap: () => _launchUrl(context, handbookUrl),
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.link_outlined,
            title: '各種リンク集',
            onTap: () => _navigateToPage(context, const Link()),
          ),
          _buildMenuItem(
            icon: Icons.call_outlined,
            title: '各種連絡先',
            onTap: () => _navigateToPage(context, const Call()),
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: '設定/その他',
            onTap: () => _navigateToPage(context, const SettingPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          onTap: onTap,
          trailing: const Icon(Icons.chevron_right),
          dense: true,
          visualDensity: VisualDensity.comfortable,
        ),
        if (showDivider) const Divider(),
      ],
    );
  }

  void _launchUrl(BuildContext context, String url) {
    Navigator.of(context).pop();
    launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

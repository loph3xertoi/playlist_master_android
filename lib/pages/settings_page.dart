// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:playlistmaster/config/user_info.dart';
import 'package:playlistmaster/utils/app_updater.dart';
import 'package:playlistmaster/utils/my_toast.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  void _resetPassword(BuildContext context) {
    if (UserInfo.basicUser!.email == null ||
        UserInfo.basicUser!.email!.isEmpty) {
      MyToast.showToast('Please bind email first.');
      return;
    }
    Navigator.pushNamed(context, '/reset_password_page');
  }

  void _aboutPage(BuildContext context) {
    Navigator.pushNamed(context, '/about_page');
  }

  void _bindEmail(BuildContext context) {
    Navigator.pushNamed(context, '/bind_email_page');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings', style: textTheme.labelLarge),
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onSecondary),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingItem(
              name: 'Bind Email',
              style: textTheme.labelMedium!,
              onTap: _bindEmail,
            ),
            SettingItem(
              name: 'Reset Password',
              style: textTheme.labelMedium!,
              onTap: _resetPassword,
            ),
            SettingItem(
              name: 'About',
              style: textTheme.labelMedium!,
              onTap: _aboutPage,
            ),
          ],
        ));
  }
}

class SettingItem extends StatelessWidget {
  SettingItem({
    Key? key,
    required this.name,
    required this.style,
    required this.onTap,
  }) : super(key: key);

  final String name;
  final TextStyle style;
  final void Function(BuildContext) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: InkWell(
          onTap: () {
            onTap(context);
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(name, style: style),
              ),
            ],
          )),
    );
  }
}

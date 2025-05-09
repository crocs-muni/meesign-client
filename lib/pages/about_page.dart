import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../widget/smart_logo.dart';

class AboutPage extends StatelessWidget {
  static const version = '0.5.1';

  static const crocsAuth = 'crocs.fi.muni.cz';
  static const meesignAuth = 'meesign.$crocsAuth';

  // sorted alphabetically by last name
  static const authors = [
    (name: 'Antonín Dufka', github: 'dufkan'),
    (name: 'Jiří Gavenda', github: 'jirigav'),
    (name: 'Robin Chmelík', github: 'Ojin13'),
    (name: 'Ondřej Chudáček', github: 'SPXcz'),
    (name: 'Jakub Janků', github: 'jjanku'),
    (name: 'Kristián Mika', github: 'KristianMika'),
    (name: 'Marek Mračna', github: 'MarekMracna'),
    (name: 'Petr Švenda', github: 'petrs'),
  ];

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
        wrapInScroll: true,
        showAppBar: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogoSection(context),
            SizedBox(height: MEDIUM_GAP),
            _buildCrocsSection(context),
            SizedBox(height: XLARGE_GAP),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWebsiteButton('Project website', meesignAuth),
                SizedBox(width: MEDIUM_GAP),
                _buildWebsiteButton('CROCS website', crocsAuth),
              ],
            ),
            SizedBox(height: MEDIUM_GAP),
            _buildAuthorsSection(context),
          ],
        ));
  }

  Widget _buildLogoSection(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        SmartLogo(logoWidth: 72),
        Text('MeeSign',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
        Text('version $version',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.outline)),
        SizedBox(height: MEDIUM_GAP),
      ],
    );
  }

  Widget _buildCrocsSection(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Text('Developed by', style: theme.textTheme.bodyMedium),
        SizedBox(height: MEDIUM_GAP),
        SvgPicture.asset(
          'assets/crocs_logo.svg',
          colorFilter: theme.brightness == Brightness.dark
              ? ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                )
              : null,
          height: 72,
        ),
      ],
    );
  }

  Widget _buildAuthorsSection(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Divider(thickness: 0),
        Text('Authors:',
            style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        SizedBox(height: SMALL_GAP),
        for (final author in authors)
          InkWell(
            borderRadius:
                BorderRadius.all(Radius.circular(SMALL_BORDER_RADIUS)),
            onTap: () {
              launchUrl(
                Uri.https('github.com', author.github),
              );
            },
            child: Container(
              constraints: BoxConstraints(minWidth: 160),
              padding: EdgeInsets.all(SMALL_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: MEDIUM_PADDING),
                    child: SizedBox.square(
                      dimension: 24,
                      child: Icon(Symbols.link, opticalSize: 20),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 100),
                    child: Text(author.name),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWebsiteButton(String text, String link) {
    return FilledButton.icon(
      onPressed: () {
        launchUrl(Uri.https(link));
      },
      label: Container(
        padding: EdgeInsets.symmetric(vertical: SMALL_PADDING),
        child: Text(text),
      ),
      icon: Icon(Icons.chevron_right, size: 25),
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

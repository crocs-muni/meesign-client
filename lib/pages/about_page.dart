import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/widget/smart_logo.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const version = '0.5.1';

  static const crocsAuth = 'crocs.fi.muni.cz';
  static const meesignAuth = 'meesign.$crocsAuth';

  // sorted alphabetically by last name
  static const List<({String github, String name})> authors = [
    (name: 'Antonín Dufka', github: 'dufkan'),
    (name: 'Jiří Gavenda', github: 'jirigav'),
    (name: 'Robin Chmelík', github: 'Ojin13'),
    (name: 'Ondřej Chudáček', github: 'SPXcz'),
    (name: 'Jakub Janků', github: 'jjanku'),
    (name: 'Kristián Mika', github: 'KristianMika'),
    (name: 'Marek Mračna', github: 'MarekMracna'),
    (name: 'Petr Švenda', github: 'petrs'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      wrapInScroll: true,
      showAppBar: true,
      body: Column(
        children: [
          _buildLogoSection(context),
          const SizedBox(height: MEDIUM_GAP),
          _buildCrocsSection(context),
          const SizedBox(height: XLARGE_GAP),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWebsiteButton(
                AppLocalizations.of(context).projectWebsite,
                meesignAuth,
              ),
              const SizedBox(width: MEDIUM_GAP),
              _buildWebsiteButton(
                AppLocalizations.of(context).crocsWebsite,
                crocsAuth,
              ),
            ],
          ),
          const SizedBox(height: MEDIUM_GAP),
          _buildAuthorsSection(context),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SmartLogo(logoWidth: 72),
        const Text(
          'MeeSign',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
        ),
        Text(
          '${AppLocalizations.of(context).version} $version',
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: MEDIUM_GAP),
      ],
    );
  }

  Widget _buildCrocsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          AppLocalizations.of(context).developedBy,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: MEDIUM_GAP),
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
    final theme = Theme.of(context);

    return Column(
      children: [
        const Divider(thickness: 0),
        Text(
          AppLocalizations.of(context).authors,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: SMALL_GAP),
        for (final author in authors)
          InkWell(
            borderRadius:
                const BorderRadius.all(Radius.circular(SMALL_BORDER_RADIUS)),
            onTap: () {
              launchUrl(
                Uri.https('github.com', author.github),
              );
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 160),
              padding: const EdgeInsets.all(SMALL_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: MEDIUM_PADDING),
                    child: SizedBox.square(
                      dimension: 24,
                      child: Icon(Symbols.link, opticalSize: 20),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: Text(author.name),
                  ),
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
        padding: const EdgeInsets.symmetric(vertical: SMALL_PADDING),
        child: Text(text),
      ),
      icon: const Icon(Icons.chevron_right, size: 25),
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const version = '0.4.2';

  static const crocsAuth = 'crocs.fi.muni.cz';
  static const meesignAuth = 'meesign.$crocsAuth';

  // sorted alphabetically by last name
  static const authors = [
    (name: 'Antonín Dufka', github: 'dufkan'),
    (name: 'Jiří Gavenda', github: 'jirigav'),
    (name: 'Jakub Janků', github: 'jjanku'),
    (name: 'Kristián Mika', github: 'KristianMika'),
    (name: 'Petr Švenda', github: 'petrs'),
  ];

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final linkStyle = theme.textTheme.titleMedium?.copyWith(
      decoration: TextDecoration.underline,
      color: theme.colorScheme.tertiary,
    );

    final sectionStyle = theme.textTheme.titleLarge;

    const sectionGap = 32.0;
    const itemGap = 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icon_logo.svg',
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primaryContainer,
                  BlendMode.srcIn,
                ),
                width: 72,
              ),
              const SizedBox(height: itemGap),
              Text(
                'MeeSign',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: itemGap),
              Text(
                version,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: itemGap),
              InkWell(
                onTap: () => launchUrl(Uri.https(meesignAuth)),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Text(
                  meesignAuth,
                  style: linkStyle,
                ),
              ),
              const SizedBox(height: sectionGap),
              Text(
                'Developed by',
                style: sectionStyle,
              ),
              const SizedBox(height: itemGap),
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
              const SizedBox(height: itemGap),
              InkWell(
                onTap: () => launchUrl(Uri.https(crocsAuth)),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Text(
                  crocsAuth,
                  style: linkStyle,
                ),
              ),
              const SizedBox(height: sectionGap),
              Text(
                'Authors',
                style: sectionStyle,
              ),
              const SizedBox(height: itemGap),
              for (final author in authors)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 24,
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        iconSize: 20,
                        icon: const Icon(Symbols.link, opticalSize: 20),
                        onPressed: () => launchUrl(
                          Uri.https('github.com', author.github),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(author.name),
                  ],
                ),
              const SizedBox(height: sectionGap),
            ],
          ),
        ),
      ),
    );
  }
}

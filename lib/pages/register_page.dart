import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/model/settings.dart';
import '../app_container.dart';
import '../enums/screen_layout.dart';
import '../enums/user_status.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/launch_home.dart';
import '../util/layout_getter.dart';
import '../widget/registration_form.dart';
import '../widget/fluid_gradient.dart';
import '../widget/smart_logo.dart';
import '../widget/warning_banner.dart';

class RegisterPage extends StatefulWidget {
  final String prefillName;
  final String prefillHost;

  const RegisterPage({
    super.key,
    this.prefillHost = '',
    this.prefillName = '',
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  User? _savedUser;
  UserStatus? _status;

  final double cardMaxWidth = 500;
  final double cardMaxHeight = 660;

  Future<String> _getCurrentUserId() async {
    final container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;

    Settings appSettings = await settingsController.settingsStream.first;
    return appSettings.currentUserId;
  }

  Future<void> _initApp() async {
    final container = context.read<AppContainer>();

    // Wait to get first stream value
    await Future.delayed(Duration(seconds: 0));

    // Try to init current user
    String currentUserId = await _getCurrentUserId();
    var user =
        await container.userRepository.getUser(searchedUserId: currentUserId);
    _savedUser = user;

    if (user == null) {
      setState(() => _status = UserStatus.unregistered);
      return;
    }

    final session = await container.startUserSession(user);

    try {
      final compatible =
          await session.supportServices.checkCompatibility(user.did);
      if (!compatible) {
        setState(() => _status = UserStatus.outdated);
        return;
      }
    } on UnknownDeviceException {
      setState(() => _status = UserStatus.unrecognized);
      return;
    } catch (e) {
      // likely a networking error, e.g., the user may be offline,
      // in such a case, let the user access their data
    }

    setState(() => _status = UserStatus.ok);
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      launchHome(user: user, context: context, registerNewUser: false);
    }
  }

  Future<void> _deleteAppData() async {
    setState(() {
      _savedUser = null;
      _status = null;
    });
    final container = context.read<AppContainer>();
    await container.recreate(deleteData: true);
    setState(() => _status = UserStatus.unregistered);
  }

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      includePadding: false,
      body: _buildPageBody(context),
    );
  }

  Widget _buildPageBody(BuildContext context) {
    return Stack(
      children: [
        FluidGradient(),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 1000),
          firstChild: _getCardLoader(),
          secondChild: _getLoadedCard(),
          crossFadeState: _status != null
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        )
      ],
    );
  }

  Widget _getCardLoader() {
    return SizedBox(
      height: MediaQuery.sizeOf(context)
          .height, // This is to prevent loader from jumping during cross fade
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _getLoadedCard() {
    return _buildBackgroundCard(
        context,
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: XLARGE_GAP),
              _buildLogoSection(context),
              const SizedBox(height: XLARGE_GAP),
              _buildContent(),
              SizedBox(height: LARGE_GAP),
              _buildMinistryFooter(context),
            ],
          ),
        ));
  }

  Widget _buildBackgroundCard(BuildContext context, Widget child) {
    const double borderWidth = 1;
    const double borderOpacity = 0.2;
    const double shadowOpacity = 0.12;
    const double shadowRadius = 5;
    const Color borderColor = Colors.black;
    const int animationDuration = 250;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool compactLayout = LayoutGetter.getCurLayout(constraints.maxWidth) ==
            ScreenLayout.mobile;
        bool minWidthReached = cardMaxWidth >= constraints.maxWidth;

        return Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: animationDuration),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(
                maxWidth: cardMaxWidth, maxHeight: cardMaxHeight),
            alignment: Alignment.center,
            padding: EdgeInsets.all(compactLayout ? 0 : MEDIUM_PADDING),
            child: AnimatedContainer(
              duration: Duration(milliseconds: animationDuration),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(
                    minWidthReached ? 0 : LARGE_BORDER_RADIUS),
                border: Border.all(
                    color: borderColor.withValues(alpha: borderOpacity),
                    width: borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: shadowOpacity),
                    spreadRadius: shadowRadius,
                    blurRadius: shadowRadius * 3,
                  ),
                ],
              ),
              child: _buildNestedNavigator(child),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNestedNavigator(Widget child) {
    return Navigator(
      key: Key('nestedNavigator'),
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) {
          return child;
        });
      },
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    const double logoWidth = 100;

    return Column(
      children: [
        SmartLogo(logoWidth: logoWidth),
        SizedBox(height: MEDIUM_GAP),
        Text(
          'MeeSign',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case UserStatus.unregistered:
        return _buildRegistrationForm();
      case UserStatus.unrecognized:
        return _buildUnrecognizedBanner();
      case UserStatus.outdated:
        return _buildOutdatedBanner();
      case UserStatus.ok:
        return Container();
      default:
        return _buildRegistrationForm();
    }
  }

  Widget _buildRegistrationForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LARGE_PADDING,
      ),
      child: RegistrationForm(
        prefillHost: widget.prefillHost,
        prefillName: widget.prefillName,
      ),
    );
  }

  Widget _buildUnrecognizedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
      child: WarningBanner(
        title: 'Unknown device',
        text: 'The previously used server does not recognize this '
            'device. This likely means that the server was '
            'redeployed.\n\nYou are advised to delete your data '
            'and start anew. Alternatively, to browse your old data, '
            'you may try to proceed anyway. However, you will not '
            'be able to participate in new tasks.',
        actions: [
          OutlinedButton(
            onPressed: () => launchHome(
                user: _savedUser!, context: context, registerNewUser: true),
            child: const Text('Proceed anyway'),
          ),
          FilledButton.tonal(
            onPressed: _deleteAppData,
            child: const Text('Delete data'),
          ),
        ],
      ),
    );
  }

  Widget _buildOutdatedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
      child: WarningBanner(
        title: 'Unsupported server',
        text: 'The previously used server is incompatible with this '
            'client. The server was likely upgraded.\n\n'
            'You are advised to install a newer client and start anew. '
            'Alternatively, to browse your old data, you may try to '
            'proceed anyway. However, the client may be unstable.',
        actions: [
          OutlinedButton(
            onPressed: () => launchHome(
                user: _savedUser!, context: context, registerNewUser: true),
            child: const Text('Proceed anyway'),
          ),
        ],
      ),
    );
  }

  Widget _buildMinistryFooter(BuildContext context) {
    const double logoWidth = 175;
    final Uri url = Uri.parse('https://mv.gov.cz/mvcren/');

    return Padding(
      padding: const EdgeInsets.all(XLARGE_PADDING),
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: SvgPicture.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/ministerstvo_vnitra_cz_logo_dark_mode.svg'
              : 'assets/ministerstvo_vnitra_cz_logo.svg',
          width: logoWidth,
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    // TODO: This requires configuration in AndroidManifest.xml and Info.plist!
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

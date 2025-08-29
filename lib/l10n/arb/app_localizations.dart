import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en')
  ];

  /// No description provided for @languageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language settings'**
  String get languageSettingsTitle;

  /// No description provided for @languageSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the application interface.'**
  String get languageSettingsDescription;

  /// No description provided for @archivationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archiving settings'**
  String get archivationSettingsTitle;

  /// No description provided for @archivationSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can choose whether to display items that have been archived before Archived items will be shown in their corresponding pages.'**
  String get archivationSettingsDescription;

  /// No description provided for @showArchivedItems.
  ///
  /// In en, this message translates to:
  /// **'Show archived items'**
  String get showArchivedItems;

  /// No description provided for @themeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme settings'**
  String get themeSettingsTitle;

  /// No description provided for @themeSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can manually set your preferred theme, or use the system theme to automatically set color scheme based on your OS settings.'**
  String get themeSettingsDescription;

  /// No description provided for @useSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Use system theme'**
  String get useSystemTheme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @generalSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get generalSettingsTitle;

  /// No description provided for @applicationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Application settings'**
  String get applicationSettingsTitle;

  /// No description provided for @deviceAndServerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device and server'**
  String get deviceAndServerSettingsTitle;

  /// No description provided for @groupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettingsTitle;

  /// No description provided for @aboutThisProject.
  ///
  /// In en, this message translates to:
  /// **'About this project'**
  String get aboutThisProject;

  /// No description provided for @deviceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device settings'**
  String get deviceSettingsTitle;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @nameToIdentifyYourselfHint.
  ///
  /// In en, this message translates to:
  /// **'Name to identify yourself'**
  String get nameToIdentifyYourselfHint;

  /// No description provided for @changeServerOrDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Change server or device'**
  String get changeServerOrDeviceTitle;

  /// No description provided for @changeServerOrDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'This will take you back to the registration screen where you can change the server or register a new device.'**
  String get changeServerOrDeviceDescription;

  /// No description provided for @changeDeviceButton.
  ///
  /// In en, this message translates to:
  /// **'Change device'**
  String get changeDeviceButton;

  /// No description provided for @dangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZoneTitle;

  /// No description provided for @dangerZoneDescription.
  ///
  /// In en, this message translates to:
  /// **'This action will effectively delete your device and all associated data. After deletion, you will need to re-register your device to continue using the app.'**
  String get dangerZoneDescription;

  /// No description provided for @deleteDeviceButton.
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get deleteDeviceButton;

  /// No description provided for @groupAutomationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group automation settings'**
  String get groupAutomationSettingsTitle;

  /// No description provided for @groupAutomationSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'By default all group invitations you receive will be automatically accepted. You can change this behaviour in the section bellow to manually asses each invitation.'**
  String get groupAutomationSettingsDescription;

  /// No description provided for @automaticallyAcceptGroupInvitations.
  ///
  /// In en, this message translates to:
  /// **'Automatically accept group invitations'**
  String get automaticallyAcceptGroupInvitations;

  /// No description provided for @minimumNumberOfMembersToCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Minimum number of members to create a group'**
  String get minimumNumberOfMembersToCreateGroup;

  /// No description provided for @manageGroups.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get manageGroups;

  /// No description provided for @manageGroupsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your groups and group invitations'**
  String get manageGroupsDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'version'**
  String get version;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @projectWebsite.
  ///
  /// In en, this message translates to:
  /// **'Project website'**
  String get projectWebsite;

  /// No description provided for @crocsWebsite.
  ///
  /// In en, this message translates to:
  /// **'CRoCS website'**
  String get crocsWebsite;

  /// No description provided for @authors.
  ///
  /// In en, this message translates to:
  /// **'Authors:'**
  String get authors;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @noTasksAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Join a group and create a new task to get started.'**
  String get noTasksAvailableDescription;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @createNewTask.
  ///
  /// In en, this message translates to:
  /// **'Create new task'**
  String get createNewTask;

  /// No description provided for @createNewTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new task'**
  String get createNewTaskTitle;

  /// No description provided for @typeOfTask.
  ///
  /// In en, this message translates to:
  /// **'Type of task'**
  String get typeOfTask;

  /// No description provided for @signPdf.
  ///
  /// In en, this message translates to:
  /// **'Sign PDF'**
  String get signPdf;

  /// No description provided for @challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get challenge;

  /// No description provided for @decrypt.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get decrypt;

  /// No description provided for @pdfSigning.
  ///
  /// In en, this message translates to:
  /// **'PDF signing'**
  String get pdfSigning;

  /// No description provided for @decryption.
  ///
  /// In en, this message translates to:
  /// **'decryption'**
  String get decryption;

  /// No description provided for @nameOfPdfSigningTask.
  ///
  /// In en, this message translates to:
  /// **'Name of the PDF signing task'**
  String get nameOfPdfSigningTask;

  /// No description provided for @nameOfChallengeTask.
  ///
  /// In en, this message translates to:
  /// **'Name of the challenge task'**
  String get nameOfChallengeTask;

  /// No description provided for @nameOfDecryptionTask.
  ///
  /// In en, this message translates to:
  /// **'Name of the decryption task'**
  String get nameOfDecryptionTask;

  /// No description provided for @enterDescriptionOfTask.
  ///
  /// In en, this message translates to:
  /// **'Enter description of the {taskType} task'**
  String enterDescriptionOfTask(String taskType);

  /// No description provided for @selectDecryptionType.
  ///
  /// In en, this message translates to:
  /// **'Select decryption type'**
  String get selectDecryptionType;

  /// No description provided for @decryptAMessage.
  ///
  /// In en, this message translates to:
  /// **'Decrypt a message'**
  String get decryptAMessage;

  /// No description provided for @decryptAnImage.
  ///
  /// In en, this message translates to:
  /// **'Decrypt an image'**
  String get decryptAnImage;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get selectImage;

  /// No description provided for @enterMessageToBeSigned.
  ///
  /// In en, this message translates to:
  /// **'Enter message to be signed'**
  String get enterMessageToBeSigned;

  /// No description provided for @enterMessageToBeDecrypted.
  ///
  /// In en, this message translates to:
  /// **'Enter message to be decrypted'**
  String get enterMessageToBeDecrypted;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message'**
  String get enterMessage;

  /// No description provided for @enterTheMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the message'**
  String get enterTheMessage;

  /// No description provided for @selectGroupForNewTask.
  ///
  /// In en, this message translates to:
  /// **'Select group for the new task'**
  String get selectGroupForNewTask;

  /// No description provided for @refreshGroups.
  ///
  /// In en, this message translates to:
  /// **'Refresh groups'**
  String get refreshGroups;

  /// No description provided for @noGroupsAvailableForTaskType.
  ///
  /// In en, this message translates to:
  /// **'No groups available for this type of task yet.'**
  String get noGroupsAvailableForTaskType;

  /// No description provided for @createGroupForPdfSigning.
  ///
  /// In en, this message translates to:
  /// **'Create group for PDF signing'**
  String get createGroupForPdfSigning;

  /// No description provided for @createGroupForChallenges.
  ///
  /// In en, this message translates to:
  /// **'Create group for challenges'**
  String get createGroupForChallenges;

  /// No description provided for @createGroupForDecryption.
  ///
  /// In en, this message translates to:
  /// **'Create group for decryption'**
  String get createGroupForDecryption;

  /// No description provided for @createTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Create {taskType} task'**
  String createTaskButton(String taskType);

  /// No description provided for @selectPdf.
  ///
  /// In en, this message translates to:
  /// **'Select PDF'**
  String get selectPdf;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @changeFile.
  ///
  /// In en, this message translates to:
  /// **'Change file'**
  String get changeFile;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File too large'**
  String get fileTooLarge;

  /// No description provided for @pleaseSelectSmallerOne.
  ///
  /// In en, this message translates to:
  /// **'Please select a smaller one.'**
  String get pleaseSelectSmallerOne;

  /// No description provided for @dataTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Data too large'**
  String get dataTooLarge;

  /// No description provided for @pleaseSelectSmallerImageOrShorterText.
  ///
  /// In en, this message translates to:
  /// **'Please select a smaller image or enter a shorter text.'**
  String get pleaseSelectSmallerImageOrShorterText;

  /// No description provided for @challengeRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Challenge request failed'**
  String get challengeRequestFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// No description provided for @decryptionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Decryption request failed'**
  String get decryptionRequestFailed;

  /// No description provided for @signRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign request failed'**
  String get signRequestFailed;

  /// No description provided for @newGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroupTitle;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @membersHelpText.
  ///
  /// In en, this message translates to:
  /// **'By default, each member receives one share of the group\'s private key. As a result, all members have equal voting rights.\n\nYou can change the number of key shares a given member receives using the arrows next to its name. The circle around user\'s avatar visualizes its voting power.\n\nFor example, the user below receives one share which amounts to one third of the total number of votes.'**
  String get membersHelpText;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'example'**
  String get example;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get addMembers;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get threshold;

  /// No description provided for @thresholdHelpText.
  ///
  /// In en, this message translates to:
  /// **'No group task can succeed unless at least the specified number of positive votes is gathered from the group\'s members.\n\nBy carefully setting up the threshold and the number of shares each user receives, you can enforce that only certain subsets of the group can proceed with a given task.'**
  String get thresholdHelpText;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @policy.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get policy;

  /// No description provided for @policyHelpText.
  ///
  /// In en, this message translates to:
  /// **'If a bot is present in the group, you can set a policy that modifies its behavior (when to approve or decline requests).\n\nDepending on the bot\'s configuration, it may disregard the user-provided policy.'**
  String get policyHelpText;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @declineIfNotSatisfiedImmediately.
  ///
  /// In en, this message translates to:
  /// **'Decline if not satisfied immediately'**
  String get declineIfNotSatisfiedImmediately;

  /// No description provided for @advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get advancedOptions;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @customPolicy.
  ///
  /// In en, this message translates to:
  /// **'Custom policy'**
  String get customPolicy;

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON'**
  String get invalidJson;

  /// No description provided for @moreGroupMembersRequired.
  ///
  /// In en, this message translates to:
  /// **'More group members required'**
  String get moreGroupMembersRequired;

  /// No description provided for @atLeastTwoSharesRequired.
  ///
  /// In en, this message translates to:
  /// **'At least two shares required'**
  String get atLeastTwoSharesRequired;

  /// No description provided for @atLeastTwoSharesRequiredText.
  ///
  /// In en, this message translates to:
  /// **'Either add new members to the group or give more shares to the existing members.'**
  String get atLeastTwoSharesRequiredText;

  /// No description provided for @shareSliderDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Share slider is disabled for this protocol'**
  String get shareSliderDisabledTitle;

  /// No description provided for @shareSliderDisabledText.
  ///
  /// In en, this message translates to:
  /// **'When using MUSIG2 protocol the threshold is always set to max number of shares. Therefore, it is not possible to use the slider.'**
  String get shareSliderDisabledText;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @searchForPeer.
  ///
  /// In en, this message translates to:
  /// **'Search for peer'**
  String get searchForPeer;

  /// No description provided for @noPeersExistOnServer.
  ///
  /// In en, this message translates to:
  /// **'No peers exist on this server'**
  String get noPeersExistOnServer;

  /// No description provided for @noPeersWithSuchNameFound.
  ///
  /// In en, this message translates to:
  /// **'No peers with such a name found'**
  String get noPeersWithSuchNameFound;

  /// No description provided for @searchTasksByName.
  ///
  /// In en, this message translates to:
  /// **'Search tasks by name...'**
  String get searchTasksByName;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @decryptions.
  ///
  /// In en, this message translates to:
  /// **'Decryptions'**
  String get decryptions;

  /// No description provided for @signings.
  ///
  /// In en, this message translates to:
  /// **'Signings'**
  String get signings;

  /// No description provided for @noWaitingTasksFoundForQuery.
  ///
  /// In en, this message translates to:
  /// **'No waiting tasks found for \"{query}\".'**
  String noWaitingTasksFoundForQuery(String query);

  /// No description provided for @noWaitingTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No waiting tasks found at the moment.'**
  String get noWaitingTasksFound;

  /// No description provided for @noTasksFoundForQuery.
  ///
  /// In en, this message translates to:
  /// **'No tasks found for \"{query}\".'**
  String noTasksFoundForQuery(String query);

  /// No description provided for @reloadTasks.
  ///
  /// In en, this message translates to:
  /// **'Reload tasks'**
  String get reloadTasks;

  /// No description provided for @reloadGroups.
  ///
  /// In en, this message translates to:
  /// **'Reload groups'**
  String get reloadGroups;

  /// No description provided for @showOnlyPending.
  ///
  /// In en, this message translates to:
  /// **'Show only pending'**
  String get showOnlyPending;

  /// No description provided for @membersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{userCount} user{userPlural}, {botCount} bot{botPlural}'**
  String membersSubtitle(
      int userCount, String userPlural, int botCount, String botPlural);

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @sign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get sign;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @readCard.
  ///
  /// In en, this message translates to:
  /// **'Read card'**
  String get readCard;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joinWithCard.
  ///
  /// In en, this message translates to:
  /// **'Join with card'**
  String get joinWithCard;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get waitingForConfirmation;

  /// No description provided for @waitingForConfirmationByOthers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation by others'**
  String get waitingForConfirmationByOthers;

  /// No description provided for @workingOnTask.
  ///
  /// In en, this message translates to:
  /// **'Working on task'**
  String get workingOnTask;

  /// No description provided for @needsCardToContinue.
  ///
  /// In en, this message translates to:
  /// **'Needs card to continue'**
  String get needsCardToContinue;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeviceDeletion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this device?'**
  String get confirmDeviceDeletion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmProfileChange.
  ///
  /// In en, this message translates to:
  /// **'Confirm profile change'**
  String get confirmProfileChange;

  /// No description provided for @confirmServerOrDeviceChange.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change server or device?'**
  String get confirmServerOrDeviceChange;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @nameMustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name must not be empty'**
  String get nameMustNotBeEmpty;

  /// No description provided for @failedToRegister.
  ///
  /// In en, this message translates to:
  /// **'Failed to register'**
  String get failedToRegister;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @useExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'or use an existing account'**
  String get useExistingAccount;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get selectAccount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found'**
  String get noAccountsFound;

  /// No description provided for @areYouSureDeleteDevices.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete these devices?'**
  String get areYouSureDeleteDevices;

  /// No description provided for @areYouSureDeleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this device?'**
  String get areYouSureDeleteDevice;

  /// No description provided for @deleteDevicesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete the selected devices and all their communications. This action cannot be undone.'**
  String get deleteDevicesConfirmation;

  /// No description provided for @deleteDeviceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete the selected device and all its communications. This action cannot be undone.'**
  String get deleteDeviceConfirmation;

  /// No description provided for @devicesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} devices.'**
  String devicesDeleted(int count);

  /// No description provided for @deviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} device.'**
  String deviceDeleted(int count);

  /// No description provided for @taskDetail.
  ///
  /// In en, this message translates to:
  /// **'Task Detail'**
  String get taskDetail;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskName;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @taskValue.
  ///
  /// In en, this message translates to:
  /// **'Task value'**
  String get taskValue;

  /// No description provided for @taskImage.
  ///
  /// In en, this message translates to:
  /// **'Task image'**
  String get taskImage;

  /// No description provided for @openPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Open PDF file'**
  String get openPdfFile;

  /// No description provided for @hexValue.
  ///
  /// In en, this message translates to:
  /// **'Hex value'**
  String get hexValue;

  /// No description provided for @taskGroup.
  ///
  /// In en, this message translates to:
  /// **'Task group'**
  String get taskGroup;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @enterInput.
  ///
  /// In en, this message translates to:
  /// **'Enter input'**
  String get enterInput;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsYet;

  /// No description provided for @createGroupToStart.
  ///
  /// In en, this message translates to:
  /// **'Create a group to get started.'**
  String get createGroupToStart;

  /// No description provided for @createGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroupButton;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @useTemplateForGroup.
  ///
  /// In en, this message translates to:
  /// **'Use as a template for new group'**
  String get useTemplateForGroup;

  /// No description provided for @useTemplateForTask.
  ///
  /// In en, this message translates to:
  /// **'Use as a template for new task'**
  String get useTemplateForTask;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copyNoun.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyNoun;

  /// No description provided for @taskState.
  ///
  /// In en, this message translates to:
  /// **'Task state'**
  String get taskState;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

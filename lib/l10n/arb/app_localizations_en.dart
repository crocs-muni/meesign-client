// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageSettingsTitle => 'Language settings';

  @override
  String get languageSettingsDescription =>
      'Choose your preferred language for the application interface.';

  @override
  String get archivationSettingsTitle => 'Archiving settings';

  @override
  String get archivationSettingsDescription =>
      'You can choose whether to display items that have been archived before Archived items will be shown in their corresponding pages.';

  @override
  String get showArchivedItems => 'Show archived items';

  @override
  String get themeSettingsTitle => 'Theme settings';

  @override
  String get themeSettingsDescription =>
      'You can manually set your preferred theme, or use the system theme to automatically set color scheme based on your OS settings.';

  @override
  String get useSystemTheme => 'Use system theme';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get generalSettingsTitle => 'General settings';

  @override
  String get applicationSettingsTitle => 'Application settings';

  @override
  String get deviceAndServerSettingsTitle => 'Device and server';

  @override
  String get groupSettingsTitle => 'Group settings';

  @override
  String get aboutThisProject => 'About this project';

  @override
  String get deviceSettingsTitle => 'Device settings';

  @override
  String get deviceName => 'Device name';

  @override
  String get nameToIdentifyYourselfHint => 'Name to identify yourself';

  @override
  String get changeServerOrDeviceTitle => 'Change server or device';

  @override
  String get changeServerOrDeviceDescription =>
      'This will take you back to the registration screen where you can change the server or register a new device.';

  @override
  String get changeDeviceButton => 'Change device';

  @override
  String get dangerZoneTitle => 'Danger zone';

  @override
  String get dangerZoneDescription =>
      'This action will effectively delete your device and all associated data. After deletion, you will need to re-register your device to continue using the app.';

  @override
  String get deleteDeviceButton => 'Delete device';

  @override
  String get groupAutomationSettingsTitle => 'Group automation settings';

  @override
  String get groupAutomationSettingsDescription =>
      'By default all group invitations you receive will be automatically accepted. You can change this behaviour in the section bellow to manually asses each invitation.';

  @override
  String get automaticallyAcceptGroupInvitations =>
      'Automatically accept group invitations';

  @override
  String get minimumNumberOfMembersToCreateGroup =>
      'Minimum number of members to create a group';

  @override
  String get manageGroups => 'Manage groups';

  @override
  String get manageGroupsDescription =>
      'Manage your groups and group invitations';

  @override
  String get version => 'version';

  @override
  String get developedBy => 'Developed by';

  @override
  String get projectWebsite => 'Project website';

  @override
  String get crocsWebsite => 'CRoCS website';

  @override
  String get authors => 'Authors:';

  @override
  String get noTasksAvailable => 'No tasks available';

  @override
  String get noTasksAvailableDescription =>
      'Join a group and create a new task to get started.';

  @override
  String get createGroup => 'Create group';

  @override
  String get createNewTask => 'Create new task';

  @override
  String get createNewTaskTitle => 'Create new task';

  @override
  String get typeOfTask => 'Type of task';

  @override
  String get signPdf => 'Sign PDF';

  @override
  String get challenge => 'Challenge';

  @override
  String get decrypt => 'Decrypt';

  @override
  String get pdfSigning => 'PDF signing';

  @override
  String get decryption => 'decryption';

  @override
  String get nameOfPdfSigningTask => 'Name of the PDF signing task';

  @override
  String get nameOfChallengeTask => 'Name of the challenge task';

  @override
  String get nameOfDecryptionTask => 'Name of the decryption task';

  @override
  String enterDescriptionOfTask(String taskType) {
    return 'Enter description of the $taskType task';
  }

  @override
  String get selectDecryptionType => 'Select decryption type';

  @override
  String get decryptAMessage => 'Decrypt a message';

  @override
  String get decryptAnImage => 'Decrypt an image';

  @override
  String get selectImage => 'Select image';

  @override
  String get enterMessageToBeSigned => 'Enter message to be signed';

  @override
  String get enterMessageToBeDecrypted => 'Enter message to be decrypted';

  @override
  String get enterMessage => 'Enter message';

  @override
  String get enterTheMessage => 'Enter the message';

  @override
  String get selectGroupForNewTask => 'Select group for the new task';

  @override
  String get refreshGroups => 'Refresh groups';

  @override
  String get noGroupsAvailableForTaskType =>
      'No groups available for this type of task yet.';

  @override
  String get createGroupForPdfSigning => 'Create group for PDF signing';

  @override
  String get createGroupForChallenges => 'Create group for challenges';

  @override
  String get createGroupForDecryption => 'Create group for decryption';

  @override
  String createTaskButton(String taskType) {
    return 'Create $taskType task';
  }

  @override
  String get selectPdf => 'Select PDF';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get changeFile => 'Change file';

  @override
  String get fileTooLarge => 'File too large';

  @override
  String get pleaseSelectSmallerOne => 'Please select a smaller one.';

  @override
  String get dataTooLarge => 'Data too large';

  @override
  String get pleaseSelectSmallerImageOrShorterText =>
      'Please select a smaller image or enter a shorter text.';

  @override
  String get challengeRequestFailed => 'Challenge request failed';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get decryptionRequestFailed => 'Decryption request failed';

  @override
  String get signRequestFailed => 'Sign request failed';

  @override
  String get newGroupTitle => 'New group';

  @override
  String get groupName => 'Group Name';

  @override
  String get enterGroupName => 'Enter group name';

  @override
  String get members => 'Members';

  @override
  String get membersHelpText =>
      'By default, each member receives one share of the group\'s private key. As a result, all members have equal voting rights.\n\nYou can change the number of key shares a given member receives using the arrows next to its name. The circle around user\'s avatar visualizes its voting power.\n\nFor example, the user below receives one share which amounts to one third of the total number of votes.';

  @override
  String get example => 'example';

  @override
  String get addMembers => 'Add members';

  @override
  String get scan => 'Scan';

  @override
  String get threshold => 'Threshold';

  @override
  String get thresholdHelpText =>
      'No group task can succeed unless at least the specified number of positive votes is gathered from the group\'s members.\n\nBy carefully setting up the threshold and the number of shares each user receives, you can enforce that only certain subsets of the group can proceed with a given task.';

  @override
  String get purpose => 'Purpose';

  @override
  String get policy => 'Policy';

  @override
  String get policyHelpText =>
      'If a bot is present in the group, you can set a policy that modifies its behavior (when to approve or decline requests).\n\nDepending on the bot\'s configuration, it may disregard the user-provided policy.';

  @override
  String get time => 'Time';

  @override
  String get declineIfNotSatisfiedImmediately =>
      'Decline if not satisfied immediately';

  @override
  String get advancedOptions => 'Advanced options';

  @override
  String get protocol => 'Protocol';

  @override
  String get customPolicy => 'Custom policy';

  @override
  String get invalidJson => 'Invalid JSON';

  @override
  String get moreGroupMembersRequired => 'More group members required';

  @override
  String get atLeastTwoSharesRequired => 'At least two shares required';

  @override
  String get atLeastTwoSharesRequiredText =>
      'Either add new members to the group or give more shares to the existing members.';

  @override
  String get shareSliderDisabledTitle =>
      'Share slider is disabled for this protocol';

  @override
  String get shareSliderDisabledText =>
      'When using MUSIG2 protocol the threshold is always set to max number of shares. Therefore, it is not possible to use the slider.';

  @override
  String get ok => 'OK';

  @override
  String get create => 'Create';

  @override
  String get add => 'Add';

  @override
  String get searchForPeer => 'Search for peer';

  @override
  String get noPeersExistOnServer => 'No peers exist on this server';

  @override
  String get noPeersWithSuchNameFound => 'No peers with such a name found';

  @override
  String get searchTasksByName => 'Search tasks by name...';

  @override
  String get tasks => 'Tasks';

  @override
  String get groups => 'Groups';

  @override
  String get challenges => 'Challenges';

  @override
  String get decryptions => 'Decryptions';

  @override
  String get signings => 'Signings';

  @override
  String noWaitingTasksFoundForQuery(String query) {
    return 'No waiting tasks found for \"$query\".';
  }

  @override
  String get noWaitingTasksFound => 'No waiting tasks found at the moment.';

  @override
  String noTasksFoundForQuery(String query) {
    return 'No tasks found for \"$query\".';
  }

  @override
  String get reloadTasks => 'Reload tasks';

  @override
  String get reloadGroups => 'Reload groups';

  @override
  String get showOnlyPending => 'Show only pending';

  @override
  String membersSubtitle(
      int userCount, String userPlural, int botCount, String botPlural) {
    return '$userCount user$userPlural, $botCount bot$botPlural';
  }

  @override
  String get images => 'Images';

  @override
  String get view => 'View';

  @override
  String get sign => 'Sign';

  @override
  String get decline => 'Decline';

  @override
  String get readCard => 'Read card';

  @override
  String get join => 'Join';

  @override
  String get joinWithCard => 'Join with card';

  @override
  String get waitingForConfirmation => 'Waiting for confirmation';

  @override
  String get waitingForConfirmationByOthers =>
      'Waiting for confirmation by others';

  @override
  String get workingOnTask => 'Working on task';

  @override
  String get needsCardToContinue => 'Needs card to continue';

  @override
  String get waiting => 'Waiting';

  @override
  String get newTask => 'New task';

  @override
  String get newGroup => 'New group';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get confirmDeviceDeletion =>
      'Are you sure you want to delete this device?';

  @override
  String get delete => 'Delete';

  @override
  String get confirmProfileChange => 'Confirm profile change';

  @override
  String get confirmServerOrDeviceChange =>
      'Are you sure you want to change server or device?';

  @override
  String get confirm => 'Confirm';

  @override
  String get name => 'Name';

  @override
  String get server => 'Server';

  @override
  String get nameMustNotBeEmpty => 'Name must not be empty';

  @override
  String get failedToRegister => 'Failed to register';

  @override
  String get register => 'Register';

  @override
  String get useExistingAccount => 'or use an existing account';

  @override
  String get selectAccount => 'Select account';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get noAccountsFound => 'No accounts found';

  @override
  String get areYouSureDeleteDevices =>
      'Are you sure you want to delete these devices?';

  @override
  String get areYouSureDeleteDevice =>
      'Are you sure you want to delete this device?';

  @override
  String get deleteDevicesConfirmation =>
      'This will delete the selected devices and all their communications. This action cannot be undone.';

  @override
  String get deleteDeviceConfirmation =>
      'This will delete the selected device and all its communications. This action cannot be undone.';

  @override
  String devicesDeleted(int count) {
    return 'Deleted $count devices.';
  }

  @override
  String deviceDeleted(int count) {
    return 'Deleted $count device.';
  }

  @override
  String get taskDetail => 'Task Detail';

  @override
  String get taskName => 'Task name';

  @override
  String get fileName => 'File name';

  @override
  String get taskValue => 'Task value';

  @override
  String get taskImage => 'Task image';

  @override
  String get openPdfFile => 'Open PDF file';

  @override
  String get hexValue => 'Hex value';

  @override
  String get taskGroup => 'Task group';

  @override
  String get description => 'Description';

  @override
  String get message => 'Message';

  @override
  String get select => 'Select';

  @override
  String get enterInput => 'Enter input';

  @override
  String get archived => 'Archived';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get createGroupToStart => 'Create a group to get started.';

  @override
  String get createGroupButton => 'Create group';

  @override
  String get back => 'Back';

  @override
  String get useTemplateForGroup => 'Use as a template for new group';

  @override
  String get useTemplateForTask => 'Use as a template for new task';

  @override
  String get copy => 'Copy';

  @override
  String get copyNoun => 'Copy';

  @override
  String get taskState => 'Task state';

  @override
  String get settings => 'Settings';

  @override
  String get tryNewChallenge => 'Try creating a new challenge';

  @override
  String get startWithNewChallenge => 'Start by creating a new challenge';

  @override
  String get startWithChallengeGroup => 'Start by creating a challenge group';

  @override
  String get createChallengeGroup => 'Create challenge group';

  @override
  String get createChallenge => 'Create challenge';

  @override
  String get tryEncryptingData => 'Try encrypting data';

  @override
  String get startWithNewDecryption =>
      'Start by creating a new decryption task';

  @override
  String get startWithDecryptionGroup => 'Start by creating a decryption group';

  @override
  String get createDecryptionGroup => 'Create decryption group';

  @override
  String get createDecryption => 'Create decryption';

  @override
  String get trySigningPdf => 'Try signing a PDF';

  @override
  String get startWithNewPdfSigning =>
      'Start by creating a new PDF signing task';

  @override
  String get startWithPdfSigningGroup =>
      'Start by creating a PDF signing group';

  @override
  String get createPdfSigningGroup => 'Create PDF signing group';

  @override
  String get createPdfSigning => 'Create PDF signing';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String minimumMembersRequired(int minGroupMembers) {
    return 'At least $minGroupMembers members are required to create a group. You can change this in the application settings.';
  }

  @override
  String get unnecessarySharesTitle => 'Unnecessary number of shares';

  @override
  String unnecessarySharesText(String newThreshold, String newShares) {
    return 'You can achieve the same voting rights distribution by setting threshold to $newThreshold and shares to ($newShares). This may improve performance.';
  }

  @override
  String get manySharesWarning => 'Very large number of shares';

  @override
  String get manySharesWarningText =>
      'You may experience degraded performance with certain protocols if the share count is too high. Consider removing some members or lowering the number of shares they receive if this poses an issue.';
}

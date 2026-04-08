// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get languageSettingsTitle => 'Nastavení jazyka';

  @override
  String get languageSettingsDescription =>
      'Vyberte si preferovaný jazyk pro uživatelské rozhraní aplikace.';

  @override
  String get archivationSettingsTitle => 'Nastavení archivace';

  @override
  String get archivationSettingsDescription =>
      'Můžete si vybrat, zda chcete zobrazovat položky, které byly archivovány. Archivované položky budou zobrazeny na svých odpovídajících stránkách.';

  @override
  String get showArchivedItems => 'Zobrazit archivované položky';

  @override
  String get themeSettingsTitle => 'Nastavení motivu aplikace';

  @override
  String get themeSettingsDescription =>
      'Můžete ručně nastavit svůj preferovaný motiv, nebo použít systémový motiv pro automatické nastavení barevného schématu na základě nastavení vašeho operačního systému.';

  @override
  String get useSystemTheme => 'Použít systémový motiv';

  @override
  String get darkMode => 'Tmavý režim';

  @override
  String get generalSettingsTitle => 'Obecná nastavení';

  @override
  String get applicationSettingsTitle => 'Nastavení aplikace';

  @override
  String get deviceAndServerSettingsTitle => 'Zařízení a server';

  @override
  String get groupSettingsTitle => 'Nastavení skupin';

  @override
  String get aboutThisProject => 'O tomto projektu';

  @override
  String get deviceSettingsTitle => 'Nastavení zařízení';

  @override
  String get deviceName => 'Název zařízení';

  @override
  String get nameToIdentifyYourselfHint => 'Jméno pod kterým vás uvidí ostatní';

  @override
  String get changeServerOrDeviceTitle => 'Změnit server nebo zařízení';

  @override
  String get changeServerOrDeviceDescription =>
      'Tímto se vrátíte na registrační obrazovku, kde můžete změnit server nebo zaregistrovat nové zařízení.';

  @override
  String get changeDeviceButton => 'Změnit zařízení';

  @override
  String get dangerZoneTitle => 'Nebezpečná zóna';

  @override
  String get dangerZoneDescription =>
      'Tato akce efektivně smaže vaše zařízení a všechna související data. Po smazání budete muset znovu zaregistrovat své zařízení, abyste mohli pokračovat v používání aplikace.';

  @override
  String get deleteDeviceButton => 'Smazat zařízení';

  @override
  String get groupAutomationSettingsTitle => 'Nastavení automatizace skupin';

  @override
  String get groupAutomationSettingsDescription =>
      'Ve výchozím nastavení budou všechny pozvánky do skupin, které obdržíte, automaticky přijaty. Toto chování můžete změnit v sekci níže, kde je možné zapnout ruční posouzení každé pozvánky.';

  @override
  String get automaticallyAcceptGroupInvitations =>
      'Automaticky přijímat pozvánky do skupin';

  @override
  String get minimumNumberOfMembersToCreateGroup =>
      'Minimální počet členů pro vytvoření skupiny';

  @override
  String get manageGroups => 'Spravovat skupiny';

  @override
  String get manageGroupsDescription =>
      'Spravujte své skupiny a pozvánky do skupin';

  @override
  String get version => 'verze';

  @override
  String get developedBy => 'Vyvinuto skupinou';

  @override
  String get projectWebsite => 'Web projektu';

  @override
  String get crocsWebsite => 'Web CRoCS';

  @override
  String get authors => 'Autoři:';

  @override
  String get noTasksAvailable => 'Žádné úlohy k dispozici';

  @override
  String get noTasksAvailableDescription =>
      'Připojte se ke skupině a vytvořte váši první úlohu.';

  @override
  String get createGroup => 'Vytvořit skupinu';

  @override
  String get createNewTask => 'Vytvořit novou úlohu';

  @override
  String get createNewTaskTitle => 'Vytvořit novou úlohu';

  @override
  String get typeOfTask => 'Typ úlohy';

  @override
  String get signPdf => 'Podepsat PDF';

  @override
  String get challenge => 'Výzva';

  @override
  String get decrypt => 'Dešifrovat';

  @override
  String get pdfSigning => 'podepisování PDF';

  @override
  String get decryption => 'dešifrování';

  @override
  String get nameOfPdfSigningTask => 'Název úlohy pro podepisování PDF';

  @override
  String get nameOfChallengeTask => 'Název úlohy pro výzvu';

  @override
  String get nameOfDecryptionTask => 'Název úlohy pro dešifrování';

  @override
  String enterDescriptionOfTask(String taskType) {
    return 'Zadejte popis úlohy $taskType';
  }

  @override
  String get selectDecryptionType => 'Vyberte typ dešifrování';

  @override
  String get decryptAMessage => 'Dešifrovat zprávu';

  @override
  String get decryptAnImage => 'Dešifrovat obrázek';

  @override
  String get selectImage => 'Vybrat obrázek';

  @override
  String get enterMessageToBeSigned => 'Zadejte zprávu k podpisu';

  @override
  String get enterMessageToBeDecrypted => 'Zadejte zprávu k dešifrování';

  @override
  String get enterMessage => 'Zadejte zprávu';

  @override
  String get enterTheMessage => 'Zadejte zprávu';

  @override
  String get selectGroupForNewTask => 'Vyberte skupinu pro novou úlohu';

  @override
  String get refreshGroups => 'Obnovit skupiny';

  @override
  String get noGroupsAvailableForTaskType =>
      'Pro tento typ úlohy zatím nejsou k dispozici žádné skupiny.';

  @override
  String get createGroupForPdfSigning =>
      'Vytvořit skupinu pro podepisování PDF';

  @override
  String get createGroupForChallenges => 'Vytvořit skupinu pro výzvy';

  @override
  String get createGroupForDecryption => 'Vytvořit skupinu pro dešifrování';

  @override
  String createTaskButton(String taskType) {
    return 'Vytvořit úlohu $taskType';
  }

  @override
  String get selectPdf => 'Vybrat PDF';

  @override
  String get chooseFile => 'Vybrat soubor';

  @override
  String get changeFile => 'Změnit soubor';

  @override
  String get fileTooLarge => 'Soubor je příliš velký';

  @override
  String get pleaseSelectSmallerOne => 'Prosím vyberte menší.';

  @override
  String get dataTooLarge => 'Data jsou příliš velká';

  @override
  String get pleaseSelectSmallerImageOrShorterText =>
      'Prosím vyberte menší obrázek nebo zadejte kratší text.';

  @override
  String get challengeRequestFailed => 'Požadavek na výzvu selhal';

  @override
  String get pleaseTryAgain => 'Prosím zkuste to znovu.';

  @override
  String get decryptionRequestFailed => 'Požadavek na dešifrování selhal';

  @override
  String get signRequestFailed => 'Požadavek na podpis selhal';

  @override
  String get newGroupTitle => 'Nová skupina';

  @override
  String get groupName => 'Název skupiny';

  @override
  String get enterGroupName => 'Zadejte název skupiny';

  @override
  String get members => 'Členové';

  @override
  String get membersHelpText =>
      'Ve výchozím nastavení každý člen obdrží jeden podíl soukromého klíče skupiny. Výsledkem je, že všichni členové mají stejná hlasovací práva.\n\nPočet podílů klíče, které daný člen obdrží, můžete změnit pomocí šipek vedle jeho jména. Kruh kolem avataru uživatele vizualizuje jeho hlasovací sílu.\n\nNapříklad uživatel níže obdrží jeden podíl, což představuje jednu třetinu celkového počtu hlasů.';

  @override
  String get example => 'příklad';

  @override
  String get addMembers => 'Přidat členy';

  @override
  String get scan => 'Skenovat';

  @override
  String get threshold => 'Práh';

  @override
  String get thresholdHelpText =>
      'Žádná úloha skupiny nemůže uspět, pokud není shromážděn alespoň stanovený počet pozitivních hlasů od členů skupiny. Nastavením prahu a počtu podílů, které každý uživatel obdrží, můžete vynutit, aby pouze určité podmnožiny skupiny mohly pokračovat v dané úloze.';

  @override
  String get purpose => 'Účel';

  @override
  String get policy => 'Zásady';

  @override
  String get policyHelpText =>
      'Pokud je ve skupině přítomen bot, můžete nastavit pravidla, které upravují jeho chování (kdy schválit nebo zamítnout požadavky).\n\nV závislosti na konfiguraci bota může ignorovat uživatelsky poskytované pravidla.';

  @override
  String get time => 'Čas';

  @override
  String get declineIfNotSatisfiedImmediately =>
      'Zamítnout, pokud není okamžitě splněno';

  @override
  String get advancedOptions => 'Pokročilé možnosti';

  @override
  String get protocol => 'Protokol';

  @override
  String get customPolicy => 'Vlastní pravidla';

  @override
  String get invalidJson => 'Neplatný JSON';

  @override
  String get moreGroupMembersRequired => 'Vyžadováno více členů skupiny';

  @override
  String get atLeastTwoSharesRequired => 'Vyžadovány alespoň dva podíly';

  @override
  String get atLeastTwoSharesRequiredText =>
      'Buď přidejte nové členy do skupiny, nebo dejte více podílů stávajícím členům.';

  @override
  String get shareSliderDisabledTitle =>
      'Posuvník podílů je pro tento protokol zakázán';

  @override
  String get shareSliderDisabledText =>
      'Při použití protokolu MUSIG2 je práh vždy nastaven na maximální počet podílů. Proto není možné použít posuvník.';

  @override
  String get ok => 'OK';

  @override
  String get create => 'Vytvořit';

  @override
  String get add => 'Přidat';

  @override
  String get searchForPeer => 'Hledat členy';

  @override
  String get noPeersExistOnServer =>
      'Na tomto serveru neexistují žádní jiní členové.';

  @override
  String get noPeersWithSuchNameFound =>
      'Nebyli nalezeni žádní členové s takovým názvem';

  @override
  String get searchTasksByName => 'Hledat úlohy podle názvu...';

  @override
  String get tasks => 'úlohy';

  @override
  String get groups => 'Skupiny';

  @override
  String get challenges => 'Výzvy';

  @override
  String get decryptions => 'Dešifrování';

  @override
  String get signings => 'Podpisy';

  @override
  String noWaitingTasksFoundForQuery(String query) {
    return 'Nebyly nalezeny žádné čekající úlohy pro \"$query\".';
  }

  @override
  String get noWaitingTasksFound =>
      'Momentálně nejsou nalezeny žádné čekající úlohy.';

  @override
  String noTasksFoundForQuery(String query) {
    return 'Nebyly nalezeny žádné úlohy pro \"$query\".';
  }

  @override
  String get reload => 'Obnovit';

  @override
  String get reloadTasks => 'Obnovit úlohy';

  @override
  String get reloadGroups => 'Obnovit skupiny';

  @override
  String get showOnlyPending => 'Zobrazit pouze čekající';

  @override
  String membersSubtitle(
      int userCount, String userPlural, int botCount, String botPlural) {
    return '$userCount uživatel$userPlural, $botCount bot$botPlural';
  }

  @override
  String get images => 'Obrázky';

  @override
  String get view => 'Zobrazit';

  @override
  String get sign => 'Podepsat';

  @override
  String get decline => 'Zamítnout';

  @override
  String get readCard => 'Načíst kartu';

  @override
  String get join => 'Připojit se';

  @override
  String get joinWithCard => 'Připojit se s kartou';

  @override
  String get waitingForConfirmation => 'Čeká se na potvrzení';

  @override
  String get waitingForConfirmationByOthers => 'Čeká se na potvrzení ostatními';

  @override
  String get workingOnTask => 'Pracuje se na úloze';

  @override
  String get needsCardToContinue => 'Pro pokračování je potřeba karta';

  @override
  String get waiting => 'Čeká se';

  @override
  String get newTask => 'Nová úloha';

  @override
  String get newGroup => 'Nová skupina';

  @override
  String get confirmDeletion => 'Potvrdit smazání';

  @override
  String get confirmDeviceDeletion => 'Opravdu chcete smazat toto zařízení?';

  @override
  String get delete => 'Smazat';

  @override
  String get confirmProfileChange => 'Potvrdit změnu profilu';

  @override
  String get confirmServerOrDeviceChange =>
      'Opravdu chcete změnit server nebo zařízení?';

  @override
  String get confirm => 'Potvrdit';

  @override
  String get name => 'Jméno';

  @override
  String get server => 'Server';

  @override
  String get nameMustNotBeEmpty => 'Jméno nesmí být prázdné';

  @override
  String get failedToRegister => 'Registrace selhala';

  @override
  String get register => 'Registrovat';

  @override
  String get useExistingAccount => 'nebo použít existující účet';

  @override
  String get selectAccount => 'Vybrat účet';

  @override
  String get cancel => 'Zrušit';

  @override
  String get edit => 'Upravit';

  @override
  String get noAccountsFound => 'Nebyly nalezeny žádné účty';

  @override
  String get areYouSureDeleteDevices => 'Opravdu chcete smazat tato zařízení?';

  @override
  String get areYouSureDeleteDevice => 'Opravdu chcete smazat toto zařízení?';

  @override
  String get deleteDevicesConfirmation =>
      'Tímto smažete vybraná zařízení a veškerou jejich komunikaci. Tuto akci nelze vrátit zpět.';

  @override
  String get deleteDeviceConfirmation =>
      'Tímto smažete vybrané zařízení a veškerou jeho komunikaci. Tuto akci nelze vrátit zpět.';

  @override
  String devicesDeleted(int count) {
    return 'Smazáno $count zařízení.';
  }

  @override
  String deviceDeleted(int count) {
    return 'Smazáno $count zařízení.';
  }

  @override
  String get taskDetail => 'Detail úlohy';

  @override
  String get taskName => 'Název úlohy';

  @override
  String get fileName => 'Název souboru';

  @override
  String get taskValue => 'Hodnota úlohy';

  @override
  String get taskImage => 'Obrázek úlohy';

  @override
  String get openPdfFile => 'Otevřít PDF soubor';

  @override
  String get previewDocument => 'Zobrazit dokument';

  @override
  String get hexValue => 'Hexadecimální hodnota';

  @override
  String get taskGroup => 'Skupina úlohy';

  @override
  String get description => 'Popis';

  @override
  String get message => 'Zpráva';

  @override
  String get select => 'Vybrat';

  @override
  String get enterInput => 'Zadejte vstup';

  @override
  String get archived => 'Archivováno';

  @override
  String get selfDevice => '(vlastní)';

  @override
  String get myGroups => 'Moje skupiny';

  @override
  String get otherGroups => 'Ostatní skupiny';

  @override
  String get noOtherGroupsAvailable =>
      'Žádné další dešifrovací skupiny nejsou k dispozici.';

  @override
  String get noGroupsYet => 'Zatím nejsou vytvořeny žádné skupiny.';

  @override
  String get createGroupToStart =>
      'Vytvořte první skupinu pro používání aplikace.';

  @override
  String get createGroupButton => 'Vytvořit skupinu';

  @override
  String get back => 'Zpět';

  @override
  String get useTemplateForGroup => 'Použít jako šablonu pro novou skupinu';

  @override
  String get useTemplateForTask => 'Použít jako šablonu pro novou úlohu';

  @override
  String get copy => 'Kopírovat';

  @override
  String get copyNoun => 'Kopie';

  @override
  String get taskState => 'Stav úlohy';

  @override
  String get settings => 'Nastavení';

  @override
  String get tryNewChallenge => 'Zkuste vytvořit novou výzvu';

  @override
  String get startWithNewChallenge => 'Začněte vytvořením nové výzvy';

  @override
  String get startWithChallengeGroup => 'Začněte vytvořením skupiny pro výzvy';

  @override
  String get createChallengeGroup => 'Vytvořit skupinu pro výzvy';

  @override
  String get createChallenge => 'Vytvořit výzvu';

  @override
  String get tryEncryptingData => 'Zkuste zašifrovat data';

  @override
  String get startWithNewDecryption =>
      'Začněte vytvořením nové úlohy dešifrování';

  @override
  String get startWithDecryptionGroup =>
      'Začněte vytvořením skupiny pro dešifrování';

  @override
  String get createDecryptionGroup => 'Vytvořit skupinu pro dešifrování';

  @override
  String get createDecryption => 'Vytvořit dešifrovací úlohu';

  @override
  String get trySigningPdf => 'Zkuste podepsat PDF';

  @override
  String get startWithNewPdfSigning =>
      'Začněte vytvořením nové úlohy podepisování PDF';

  @override
  String get startWithPdfSigningGroup =>
      'Začněte vytvořením skupiny pro podepisování PDF';

  @override
  String get createPdfSigningGroup => 'Vytvořit skupinu pro podepisování PDF';

  @override
  String get createPdfSigning => 'Vytvořit úlohu podepisování PDF';

  @override
  String get download => 'Stáhnout';

  @override
  String get share => 'Sdílet';

  @override
  String minimumMembersRequired(int minGroupMembers) {
    return 'Pro vytvoření skupiny je potřeba alespoň $minGroupMembers členů. Toto můžete změnit v nastavení aplikace.';
  }

  @override
  String get unnecessarySharesTitle => 'Zbytečně volké množství podílů';

  @override
  String unnecessarySharesText(String newThreshold, String newShares) {
    return 'Můžete dosáhnout stejného rozložení hlasovacích práv nastavením prahu na $newThreshold a podílů na ($newShares). To může zlepšit výkon.';
  }

  @override
  String get manySharesWarning => 'Velké množství podílů';

  @override
  String get manySharesWarningText =>
      'S některými protokoly můžete zaznamenat snížený výkon, pokud je počet podílů příliš vysoký. Zvažte odebrání některých členů nebo snížení počtu podílů, které obdrží, pokud zaznamenáte problém s výkonem.';

  @override
  String get groupCreationFailed => 'Vytvoření skupiny selhalo';

  @override
  String get confirmCloseSettingsTitle =>
      'Nastavení potvrzení zavření aplikace';

  @override
  String get confirmCloseSettingsDesc =>
      'Můžete si vybrat, zda chcete zobrazit potvrzovací dialog při pokusu o zavření aplikace.';

  @override
  String get confirmCloseSettings => 'Potvrdit zavření aplikace';

  @override
  String get authenticateProtectedActionsSettingsTitle =>
      'Nastavení autentizace';

  @override
  String get authenticateProtectedActionsSettingsDesc =>
      'Vyžadovat biometrickou nebo zařízení autentizaci pro citlivé akce pro zvýšení bezpečnosti.';

  @override
  String get authenticateProtectedActionsSettings =>
      'Autentizovat chráněné akce';

  @override
  String get authenticationNotSupported =>
      'Toto zařízení nepodporuje lokální autentizaci';

  @override
  String get confirmQuitTitle => 'Opravdu chcete aplikaci ukončit?';

  @override
  String get confirmQuitYesDontAsk => 'Ano, příště se již neptat';

  @override
  String get no => 'Ne';

  @override
  String get yes => 'Ano';

  @override
  String get pleaseCreateNewGroupForTaskType =>
      'Pro pokračování prosím vytvořte novou skupinu pro tento typ úlohy';

  @override
  String get qrCodeNotBelongToPeer => 'Tento kód nepatří žádnému členu';

  @override
  String get scanPeerCode => 'Naskenujte kód člena';

  @override
  String get javaCardsFrostGroupsHelpText =>
      'Ve FROST skupině můžete použít JavaCards.';
}

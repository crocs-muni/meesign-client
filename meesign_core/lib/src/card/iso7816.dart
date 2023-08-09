class Iso7816 {
  static const int swNoError = 0x9000;
  static const int swBytesRemaining00 = 0x6100;

  static const int swWarningStateUnchanged = 0x6200;

  static const int swWrongLength = 0x6700;

  static const int swLogicalChannelNotSupported = 0x6881;
  static const int swSecureMessagingNotSupported = 0x6882;
  static const int swLastCommandExpected = 0x6883;
  static const int swCommandChainingNotSupported = 0x6884;

  static const int swSecurityStatusNotSatisfied = 0x6982;
  static const int swFileInvalid = 0x6983;
  static const int swDataInvalid = 0x6984;
  static const int swConditionsNotSatisfied = 0x6985;
  static const int swCommandNotAllowed = 0x6986;
  static const int swAppletSelectFailed = 0x6999;

  static const int swWrongData = 0x6a80;
  static const int swFuncNotSupported = 0x6a81;
  static const int swFileNotFound = 0x6a82;
  static const int swRecordNotFound = 0x6a83;
  static const int swFileFull = 0x6a84;
  static const int swIncorrectP1P2 = 0x6a86;

  static const int swWrongP1P2 = 0x6b00;
  static const int swCorrectLength00 = 0x6c00;
  static const int swInsNotSupported = 0x6d00;
  static const int swClaNotSupported = 0x6e00;
  static const int swUnknown = 0x6f00;

  static const int claIso7816 = 0x0;
  static const int insSelect = 0xa4;
  static const int insExternalAuthenticate = 0x82;
}

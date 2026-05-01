import Cocoa

// Kept in sync with lib/util/app_arg_parser.dart. The Dart parser remains
// canonical; this string only exists so --help can short-circuit before
// NSApplicationMain (otherwise the dock icon bounces and a window briefly
// appears, then vanishes).
let usageText = """
MeeSign client.

Usage: meesign_client [options]

Options:
  -h, --help              display usage information
      --version           print version and exit
      --host <addr>       server address
      --name <name>       user name
      --app-dir <dir>     override application support directory
      --temp-dir <dir>    override temporary directory
      --downloads-dir <dir>
      --documents-dir <dir>
      --cache-dir <dir>
"""

let appVersion = "0.5.1"

for arg in CommandLine.arguments.dropFirst() {
  if arg == "--help" || arg == "-h" {
    print(usageText)
    exit(0)
  }
  if arg == "--version" {
    print("MeeSign \(appVersion)")
    exit(0)
  }
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
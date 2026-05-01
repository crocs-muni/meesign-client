#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  bool console_attached = ::AttachConsole(ATTACH_PARENT_PROCESS) != 0;
  if (!console_attached && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
    console_attached = true;
  }
  if (console_attached) {
    // AttachConsole alone doesn't wire stdio fds; reopen them so printf
    // reaches the parent shell. See flutter/flutter#53169.
    FILE* unused;
    freopen_s(&unused, "CONOUT$", "w", stdout);
    freopen_s(&unused, "CONOUT$", "w", stderr);
  }

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  // Short-circuit on --help / --version before any window is created.
  for (const auto& a : command_line_arguments) {
    if (a == "--help" || a == "-h") {
      std::printf("%s", kUsageText);
      std::fflush(stdout);
      return 0;
    }
    if (a == "--version") {
      std::printf("MeeSign %s\n", kAppVersion);
      std::fflush(stdout);
      return 0;
    }
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"MeeSign", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

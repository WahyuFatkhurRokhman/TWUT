#define MyAppName "Twut"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "TWUT Teams"
#define MyAppExeName "TWUT.exe"

[Setup]
AppId={{A94B2E9F-3C1A-4A8B-9B59-2E4F3D1C1234}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

OutputDir=Output
OutputBaseFilename=TWUT-v1.1.0-Windows-X64-Installer
SetupIconFile=assets\app_icon.ico

Compression=lzma
SolidCompression=yes

WizardStyle=modern

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\TWUT"; Filename: "{app}\TWUT.exe"
Name: "{autodesktop}\TWUT"; Filename: "{app}\TWUT.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\TWUT.exe"; Description: "Launch TWUT"; Flags: nowait postinstall skipifsilent
; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{89CF55A5-99B6-4B53-8F9C-90F756B24488}
AppName=Chat Noir
AppVersion=1.2
;AppVerName=Chat Noir 1.2
AppPublisher=Shatko Ivan
AppPublisherURL=https://github.com/fatalryuu/Chat-Noir
AppSupportURL=https://github.com/fatalryuu/Chat-Noir
AppUpdatesURL=https://github.com/fatalryuu/Chat-Noir
DefaultDirName={pf}\Chat Noir
DefaultGroupName=Chat Noir
AllowNoIcons=yes
LicenseFile=C:\Users\vanya\OneDrive\??????? ????\lic.txt
OutputBaseFilename=ChatNoirInstallator
SetupIconFile=G:\bsuir\????\??????\icon.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "G:\bsuir\????\??????\Win32\Debug\MainProject.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "G:\bsuir\????\??????\Win32\Debug\HighScores.txt"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\Chat Noir"; Filename: "{app}\MainProject.exe"
Name: "{commondesktop}\Chat Noir"; Filename: "{app}\MainProject.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\MainProject.exe"; Description: "{cm:LaunchProgram,Chat Noir}"; Flags: nowait postinstall skipifsilent


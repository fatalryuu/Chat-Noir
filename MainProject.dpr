program MainProject;

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {MainForm},
  UnitLose in 'UnitLose.pas' {LoseForm},
  UnitWin in 'UnitWin.pas' {WinForm},
  UnitSave in 'UnitSave.pas' {InputNameForm},
  UnitScores in 'UnitScores.pas' {HighScoreForm},
  Vcl.Themes,
  Vcl.Styles,
  UnitInstruction in 'UnitInstruction.pas' {FormInstruction},
  UnitDeveloperInfo in 'UnitDeveloperInfo.pas' {FormDeveloperInfo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TLoseForm, LoseForm);
  Application.CreateForm(TWinForm, WinForm);
  Application.CreateForm(TInputNameForm, InputNameForm);
  Application.CreateForm(THighScoreForm, HighScoreForm);
  Application.CreateForm(TFormInstruction, FormInstruction);
  Application.CreateForm(TFormDeveloperInfo, FormDeveloperInfo);
  Application.Run;
end.

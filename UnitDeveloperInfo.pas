Unit UnitDeveloperInfo;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
  TFormDeveloperInfo = Class(TForm)
    Info1: TLabel;
    Info2: TLabel;
    Info3: TLabel;
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
    FormDeveloperInfo: TFormDeveloperInfo;

Implementation

{$R *.dfm}

End.

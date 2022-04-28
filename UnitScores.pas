Unit UnitScores;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
  THighScoreForm = Class(TForm)
    MyMemo: TMemo;
    procedure FormShow(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  HighScoreForm: THighScoreForm;

Implementation

{$R *.dfm}

Procedure THighScoreForm.FormShow(Sender: TObject);
Var
    InputFile : TextFile;
    Temp, Str: String;
Begin
    MyMemo.Lines.Clear;
    AssignFile(InputFile, 'HighScores.txt');
    Reset(InputFile);
    Readln(InputFile, Temp);
    Str := Utf8ToAnsi(Temp);
    MyMemo.Lines.Add(Temp);
    MyMemo.Lines.Add(#10#13);

    While (Not EOF(InputFile)) Do
    Begin
        Readln(InputFile, Temp);
        Str := Utf8ToAnsi(Temp);
        MyMemo.Lines.Add(Temp);
    End;

    CloseFile(InputFile);
End;


End.

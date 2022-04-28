Unit UnitWin;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

Type
  TWinForm = Class(TForm)
    Background: TImage;
    Image1: TImage;
    Label1: TLabel;
    Question: TLabel;
    NoBtn: TButton;
    YesBtn: TButton;
    TimeLabel: TLabel;
    Procedure YesBtnClick(Sender: TObject);
    Procedure NoBtnClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormShow(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  WinForm: TWinForm;

Implementation

Uses
    UnitMain, UnitSave;

{$R *.dfm}
Type
    TTable = Array[0..10] Of Array[0..6] Of String;

Function GetNamesAndTime(GivenTime: String): TTable;
Var
    Table: TTable;
    I, J: Integer;
    InputFile: TextFile;
    Path, Temp, Str: String;
Begin
    I := 1;
    J := 3;
    Path := 'HighScores.txt';
    AssignFile(InputFile, Path);
    Reset(InputFile);
    Readln(InputFile);

    Table[0, 0] := 'Checker' + '    ' + Copy(GivenTime, 2, Length(GivenTime) - 1);
    While (I < 11) Do
    Begin
        Readln(InputFile, Table[I, 6]);
        Str := Utf8ToAnsi(Table[I, 6]);
        If (Table[I, 6] <> '') Then
        Begin
            Temp := Table[I, 6];
            Table[I, 0] := Copy(Temp, 3, Length(Temp) - 2);
            Inc(I);
        End
        Else
            I := 11;
    End;

    CloseFile(InputFile);
    GetNamesAndTime := Table;
End;

Procedure SplitIntoNameAndTime(Var Table: TTable);
Var
    MyArr: Array[0..1] Of String;
    I, J, K: Integer;
    Temp, Tmp: String;
Begin
    J := 0;
    I := 1;
    Temp := '';

    While (J < 11) Do
        If (Table[J, 0] <> '') Then
        Begin
            Tmp := Table[J, 0];
            While (Tmp[I] <> ' ') Do
            Begin
                Temp := Temp + Tmp[I];
                Inc(I);
            End;
            MyArr[0] := Temp;
            MyArr[1] := Copy(Tmp, I + 4, 5);
            For K := 0 To 1 Do
                Table[J, K + 1] := MyArr[K];
            Inc(J);
            I := 1;
            Temp := '';
        End
        Else
            J := 11;
End;

Procedure SplitIntoMinsAndSecs(Var Table: TTable);
Var
    ArrForTime: Array[0..1] Of String;
    I, J: Integer;
    Temp, Tmp: String;
Begin
    J := 0;
    I := 1;
    Temp := '';

    While (J < 11) Do
        If (Table[J, 0] <> '') Then
        Begin
            Tmp := Table[J, 2];
            While (Tmp[I] <> ':') Do
            Begin
                Temp := Temp + Tmp[I];
                Inc(I);
            End;
            ArrForTime[0] := Temp;
            ArrForTime[1] := Copy(Tmp, 3, 2);
            Table[J, 3] := ArrForTime[0] + ',' + ArrForTime[1];
            Table[J, 4] := ArrForTime[0];
            Table[J, 5] := ArrForTime[1];
            Inc(J);
            I := 1;
            Temp := '';
        End
        Else
            J := 11;
End;

Procedure TWinForm.FormCreate(Sender: TObject);
Begin
    Background.Canvas.Brush.Color := ClWhite;
    Background.Canvas.Rectangle(0, 0, WinForm.ClientWidth, WinForm.ClientHeight);
End;

Procedure TWinForm.FormShow(Sender: TObject);
Var
    Table: TTable;
    GivenTime: String;
Begin
    GivenTime := MainForm.Mins.Caption + ':' + MainForm.Secs.Caption;
    TimeLabel.Caption := TimeLabel.Caption + GivenTime;
    Table := GetNamesAndTime(GivenTime);
    SplitIntoNameAndTime(Table);
    SplitIntoMinsAndSecs(Table);
    If Table[10, 3] <= Table[0, 3] Then
         Question.Caption := 'Хотите сыграть еще раз?'
    Else
        Question.Caption := 'Хотите записать ваш результат в файл?';
End;

Procedure TWinForm.NoBtnClick(Sender: TObject);
Begin
    If (Question.Caption = 'Хотите сыграть еще раз?') Then
        MainForm.Close
    Else
        Question.Caption := 'Хотите сыграть еще раз?';
End;

Procedure TWinForm.YesBtnClick(Sender: TObject);
Begin
    If (Question.Caption = 'Хотите сыграть еще раз?') Then
    Begin
        MainForm.ResetButton.Click;
        TimeLabel.Caption := 'Время:  ';
        WinForm.Hide;
    End
    Else
    Begin
        InputNameForm.ShowModal;
        Question.Caption := 'Хотите сыграть еще раз?';
    End;
End;

End.

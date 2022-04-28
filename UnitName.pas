Unit UnitName;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, UnitMain;

Type
  TInputNameForm = Class(TForm)
    NameEdit: TEdit;
    SaveButton: TButton;
    SaveToFile: TSaveDialog;
    Procedure SaveButtonClick(Sender: TObject);
    Procedure NameEditChange(Sender: TObject);
    Procedure NameEditKeyPress(Sender: TObject; Var Key: Char);
    Procedure NameEditKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  InputNameForm: TInputNameForm;

Type
    TTable = Array[0..9] Of Array[0..6] Of String;

Implementation

{$R *.dfm}

Procedure TInputNameForm.NameEditChange(Sender: TObject);
Begin
    If NameEdit.Text = '' Then
        SaveButton.Enabled := False
    Else
        SaveButton.Enabled := True;
End;

Procedure TInputNameForm.NameEditKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    If (Shift = [ssShift]) And (Key = VK_INSERT) Then Abort;
End;

Procedure TInputNameForm.NameEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    If (Length(NameEdit.Text) > 7) And Not (Key = #08) Then
        Key := #0;
    If (Key = ' ') Then
        Key := #0;
End;

Function GetNamesAndTime(GivenName, GivenTime: String): TTable;
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

    Table[0, 0] := GivenName + '    ' + Copy(GivenTime, 2, Length(GivenTime) - 1);
    While (I < 10) Do
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
            I := 10;
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

    While (J < 10) Do
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
            J := 10;
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

    While (J < 10) Do
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
            J := 10;
End;

Procedure SortTable(Var Table: TTable);
Var
    Key: Real;
    I, J, K, L: Integer;
    Temp: String;
    Tmp: Array[0..6] Of String;
Begin
    K := 1;

    While (K < 10) Do
        If (Table[K, 3] <> '') Then
        Begin
            Key := StrToFloat(Table[K, 3]);
            J := K;
            While (J > 0) And (StrToFloat(Table[J - 1, 3]) > Key) Do
            Begin
                For L := 0 To 6 Do
                    Tmp[L] := Table[J, L];
                Table[J] := Table[J - 1];
                For L := 0 To 6 Do
                    Table[J - 1, L] := Tmp[L];
                Dec(J);
            End;
            Inc(K);
        End
        Else
            K := 10;
End;

Procedure WriteToFile(Table: TTable);
Var
    Secs, Mins, Path: String;
    K: Integer;
    OutputFile: TextFile;
Begin
    Path := 'HighScores.txt';
    AssignFile(OutputFile, Path);
    Rewrite(OutputFile);

    Write(OutputFile, 'Таблица рекордов' + #10#13);

    K := 0;
    While (K < 10) Do
    Begin
        If (Table[K, 0] <> '') Then
        Begin
            Mins := Table[K, 4];
            Secs := Table[K, 5];
            Writeln(OutputFile, IntToStr(K + 1) + '-' + Table[K, 1] + '    ' + Mins + ':' + Secs);
        End
        Else
            K := 10;
        Inc(K);
    End;

    Application.MessageBox('Ваш результат успешно добавлен в таблицу рекордов!', 'Сохранение', MB_OK);

    Close(OutputFile);
End;

Procedure TInputNameForm.SaveButtonClick(Sender: TObject);
Var
    Table: TTable;
    GivenName, GivenTime: String;
Begin
    GivenName := NameEdit.Text;
    GivenTime := MainForm.Mins.Caption + ':' + MainForm.Secs.Caption;
    Table := GetNamesAndTime(GivenName, GivenTime);
    SplitIntoNameAndTime(Table);
    SplitIntoMinsAndSecs(Table);
    SortTable(Table);
    WriteToFile(Table);
    NameEdit.Text := '';
    InputNameForm.Close;
End;

End.

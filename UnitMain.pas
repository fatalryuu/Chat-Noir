Unit UnitMain;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.Buttons, Math, TypInfo, UnitLose, UnitWin, UnitInstruction, UnitDeveloperInfo, UnitScores, Vcl.Menus;

Type
  TMainForm = Class(TForm)
    ResetButton: TButton;
    Background: TImage;
    Cat: TImage;
    Timer: TTimer;
    Mins: TLabel;
    Secs: TLabel;
    Separator: TLabel;
    Time: TLabel;
    HighScoreBtn: TButton;
    MainMenu: TMainMenu;
    Instruction: TMenuItem;
    InfoAboutDeveloper: TMenuItem;
    Procedure FormCreate(Sender: TObject);
    Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
    Procedure ButtonClick(Sender: TObject);
    Procedure ResetButtonClick(Sender: TObject);
    Procedure TimerTimer(Sender: TObject);
    Procedure HighScoreBtnClick(Sender: TObject);
    Procedure InstructionClick(Sender: TObject);
    Procedure InfoAboutDeveloperClick(Sender: TObject);
    Procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  Private
    Procedure InitButtons();
    Procedure InitField();
    Procedure CatsBrain();
    Procedure MoveCat(X1, Y1, X2, Y2, CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1, CatI, CatJ: Integer; Flag, FlagA: Boolean);
    Procedure UnblockPrevious();
    Procedure CheckIfLost(CatI, CatJ: Integer; Var Flag: Boolean);
    Procedure BrushIntoLime(X1, Y1, X2, Y2, N: Integer);
    Procedure MoveImage(Top, Left, CatI, CatJ: Integer; Var X1, Y1, X2, Y2, I, J, N: Integer; CaseN: Integer);
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  MainForm: TMainForm;
  Matrix: Array[1..13] Of Array[1..13] Of Integer; //основная матрица поля
  ArrayOfBlocked: Array[1..9] Of Integer;
  CatCoords: Array[1..5] Of Integer;
  Btns: Array[1..121] Of TBitBtn;
  Acc, S: Real;
  M: Integer;
  FirstTime: Boolean = True;

Implementation

{$R *.dfm}

Procedure SetButtonColor(ABitBtn: TBitBtn; AColor: TColor);
Var
    Bmp: TBitmap;
Begin
   Bmp := TBitmap.Create;

   Try
      Bmp.Width := ABitBtn.Width;
      Bmp.Height := ABitBtn.Height;

      Bmp.Canvas.Font.Assign(ABitBtn.Font);

      //закрашиваем картинку нужным цветом
      Bmp.Canvas.Brush.Color := AColor;
      Bmp.Canvas.Brush.Style := bsSolid;
      Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));

      //по периметру квадрат другого цвета
      Bmp.Canvas.Pen.Color := Not AColor;
      Bmp.Canvas.Rectangle(0, 0, Bmp.Width, Bmp.Height);

      ABitBtn.Glyph.Assign(Bmp);
   Finally
      Bmp.Free;
   End;
End;

Procedure GetCoords(N: Integer; Var X, Y, I, J: Integer);
Begin
    I := Ceil(N / 11);
    If N Mod 11 <> 0 then
        J := N Mod 11
    Else
        J := 11;
    If (I Mod 2 <> 0) Then
    Begin
        X := 20 + (60 * (J - 1));
        Y := 20 + (50 * (I - 1));
    End;

    If (I Mod 2 = 0) Then
    Begin
        X := 50 + (60 * (J - 1));
        Y := 20 + (50 * (I - 1));
    End;
End;

Procedure TMainForm.InitButtons;
Var
    I: Integer;
    Btn: TBitBtn;
Begin
    If FirstTime Then
        For I := Low(Btns) To High(Btns) Do
        Begin
            Btn := TBitBtn.Create(MainForm);
            Btn.Parent := MainForm;
            Btns[I] := Btn;
        End;
    FirstTime := False;
End;

Procedure InitMatrix();
Var
    I, J: Integer;
Begin
    For I := Low(Matrix) To High(Matrix) Do
        For J := Low(Matrix) To High(Matrix) Do
            Matrix[I, J] := 0;

    For I := Low(Matrix) To High(Matrix) Do
        Matrix[I, 1] := -1;
    For I := Low(Matrix) To High(Matrix) Do
        Matrix[1, I] := -1;
    For I := Low(Matrix) To High(Matrix) Do
        Matrix[High(Matrix), I] := -1;
    For I := Low(Matrix) To High(Matrix) Do
        Matrix[I, High(Matrix)] := -1;
End;

Procedure TMainForm.InitField();
Var
    I, J, K, Iter, Block, X, Y, X1, Y1, X2, Y2, Row, Col: Integer;
    Button: TBitBtn;
    Rgn : HWND;
    Blocked: Set Of Byte;
Begin
    Row := 0;
    Col := 0;
    For I := 1 To 121 Do
        Include(Blocked, I);

    Randomize;
    For I := 1 To 9 Do
    Begin
        Block := 1 + Random(121);
        ArrayOfBlocked[I] := Block;
        Exclude(Blocked, Block);
    End;

    For K := 1 To 121 Do
    Begin
        If K <> 61 Then
        Begin
            If K In Blocked Then
            Begin
                Btns[K].Width := 100;
                Btns[K].Height := 100;
                If (Row Mod 2 = 0) Then
                    Btns[K].Left := 20 + 60 * Col
                Else
                    Btns[K].Left := 50 + 60 * Col;
                Btns[K].Top := 20 + 50 * Row;
                SetButtonColor(Btns[K], ClLime);
                Rgn := CreateEllipticRgn(10, 10, 60, 60);
                SetWindowRgn(Btns[K].Handle, Rgn, True);
                Btns[K].OnClick := ButtonClick;
                Inc(Col);
            End
            Else
            Begin
                GetCoords(K, X, Y, I, J);
                Btns[K].Visible := False;
                Background.Canvas.Brush.Color := ClWhite;
                Background.Canvas.Pen.Color := ClWhite;
                Background.Canvas.Rectangle(X + 10, Y + 10, X + 60, Y + 60);
                Background.Canvas.Brush.Color := ClGreen;
                Background.Canvas.Ellipse(X + 10, Y + 10, X + 60, Y + 60);

                Matrix[I + 1, J + 1] := 1;
                Inc(Col);
            End;
        End
        Else
        Begin
            Btns[K].Width := 100;
            Btns[K].Height := 100;
            Btns[K].Left := 350;
            Btns[K].Top := 270;
            SetButtonColor(Btns[K], ClLime);
            Rgn := CreateEllipticRgn(10, 10, 60, 60);
            SetWindowRgn(Btns[K].Handle, Rgn, True);
            Btns[K].OnClick := ButtonClick;

            GetCoords(K, X, Y, I, J);
            Btns[K].Visible := False;
            Background.Canvas.Brush.Color := ClWhite;
            Background.Canvas.Pen.Color := ClWhite;
            Background.Canvas.Rectangle(X + 10, Y + 10, X + 60, Y + 60);
            Background.Canvas.Brush.Color := ClLime;
            Background.Canvas.Ellipse(X + 10, Y + 10, X + 60, Y + 60);

            CatCoords[1] := X + 10;
            CatCoords[2] := Y + 10;
            CatCoords[3] := X + 60;
            CatCoords[4] := Y + 60;
            CatCoords[5] := K;
            Inc(Col);
        End;
        If (Col = 11) Then
        Begin
            Inc(Row);
            Col := 0;
        End;
    End;
End;

Procedure TMainForm.FormCreate(Sender: TObject);
Var
    Button: TBitBtn;
Begin
    InitButtons;

    Background.Canvas.Brush.Color := ClWhite;

    InitMatrix;

    Cat.Left := 352;
    Cat.Top := 272;
    Matrix[7, 7] := 2;

    InitField;

    Timer.Enabled := False;
    M := 0;
    S := 0;
    Mins.Caption := '0' + IntToStr(M);
    Secs.Caption := '0' + FloatToStr(S);
    Acc := Timer.Interval / 1000;
End;

Procedure TMainForm.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    If (Key = $73) Then
    Begin
        WinForm.Show;
        Timer.Enabled := False;
    End;
End;

Procedure TMainForm.HighScoreBtnClick(Sender: TObject);
Begin
    Timer.Enabled := False;
    HighScoreForm.ShowModal;
    Timer.Enabled := True;
End;

Procedure TMainForm.InfoAboutDeveloperClick(Sender: TObject);
Begin
    Timer.Enabled := False;
    FormDeveloperInfo.ShowModal;
    Timer.Enabled := True;
End;

Procedure TMainForm.InstructionClick(Sender: TObject);
Begin
    Timer.Enabled := False;
    FormInstruction.ShowModal;
    Timer.Enabled := True;
End;

Procedure GetCoordsOfButton(Const Y, X: Integer; Var I, J, X1, Y1, X2, Y2: Integer);
Begin
    Case Y Of
        244..292: I := 1;
        294..342: I := 2;
        344..392: I := 3;
        394..442: I := 4;
        444..492: I := 5;
        494..542: I := 6;
        544..592: I := 7;
        594..642: I := 8;
        644..692: I := 9;
        694..742: I := 10;
        744..792: I := 11;
    End;

    If (I Mod 2 = 0) Then
        Case X Of
            650..698: J := 1;
            730..778: J := 2;
            790..838: J := 3;
            850..898: J := 4;
            910..958: J := 5;
            970..1018: J := 6;
            1030..1078: J := 7;
            1080..1128: J := 8;
            1150..1198: J := 9;
            1210..1258: J := 10;
            1270..1318: J := 11;
        End
    Else If (I Mod 2 <> 0) Then
        Case X Of
            620..668: J := 1;
            680..728: J := 2;
            740..788: J := 3;
            800..848: J := 4;
            860..908: J := 5;
            920..968: J := 6;
            980..1028: J := 7;
            1040..1088: J := 8;
            1100..1148: J := 9;
            1160..1208: J := 10;
            1220..1268: J := 11;
        End;

    If (I Mod 2 = 0) Then
        X1 := 60 + (J - 1) * 60
    Else If (I Mod 2 <> 0) Then
        X1 := 30 + (J - 1) * 60;
    X2 := X1 + 50;
    Y1 := 30 + (I - 1) * 50;
    Y2 := Y1 + 50;
End;

Procedure FindCat(Var CatI, CatJ: Integer);
Var
    I, J: Integer;
Begin
    I := 2;
    J := 2;

    While (I < 13) Do //нахождение котика
    Begin
        J := 1;
        While (J < 13) Do
        Begin
            If (Matrix[I, J] = 2) Then
            Begin
                CatI := I;
                CatJ := J;
                I := 12;
                J := 12;
            End
            Else
                Inc(J);
        End;
        Inc(I);
    End;
End;

Procedure InitVariables(Var CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1: Integer; Var Flag, FlagA: Boolean);
Begin
    Flag := True;
    FlagA := True;

    CR0 := 0;
    CL0 := 0;
    CRU0 := 0;
    CLU0 := 0;
    CRD0 := 0;
    CLD0 := 0;
    CR1 := 0;
    CL1 := 0;
    CRU1 := 0;
    CLU1 := 0;
    CRD1 := 0;
    CLD1 := 0;
End;

Procedure TMainForm.UnblockPrevious();
Var
    X1, Y1, X2, Y2, N: Integer;
Begin
    X1 := CatCoords[1];
    Y1 := CatCoords[2];
    X2 := CatCoords[3];
    Y2 := CatCoords[4];
    N := CatCoords[5];

    Background.Canvas.Brush.Color := ClWhite; //кликабельность прошлой
    Background.Canvas.Pen.Color := ClWhite;
    Background.Canvas.Rectangle(X1, Y1, X2, Y2);
    Background.Canvas.Ellipse(X1, Y1, X2, Y2);
    Btns[N].Visible := True;
End;

Procedure TakeVariables(Var CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1: Integer; Const CatI, CatJ: Integer);
Var
    I, J, K: Integer;
Begin
    I := CatI;
    J := CatJ;

    Inc(J);
    While (Matrix[I, J] <> -1) Do //вправо
    Begin
        Inc(CR0);
        Inc(J);
    End;

    I := CatI;
    J := CatJ;

    Inc(J);
    While (Matrix[I, J] <> 1) Do //вправо
    Begin
        If (Matrix[I, J] <> -1) Then
        Begin
            Inc(CR1);
            Inc(J);
        End
        Else
            Break;
    End;

    I := CatI;
    J := CatJ;

    Dec(J);
    While (Matrix[I, J] <> -1) Do //влево
    Begin
        Inc(CL0);
        Dec(J);
    End;

    I := CatI;
    J := CatJ;

    Dec(J);
    While (Matrix[I, J] <> 1) Do //влево
    Begin
        If (Matrix[I, J] <> -1) Then
        Begin
            Inc(CL1);
            Dec(J);
        End
        Else
            Break;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Dec(I);
    If (I Mod 2 = 0) Then  //вверх вправо
    Begin
        Inc(J);
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CRU0);
                Dec(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CRU0);
                Dec(I);
                Inc(J);
            End;
        End;
    End
    Else
    Begin
        K := 2;
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CRU0);
                Dec(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CRU0);
                Dec(I);
                Inc(J);
            End;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Dec(I);
    If (I Mod 2 = 0) Then  //вверх вправо
    Begin
        Inc(J);
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CRU1);
                    Dec(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CRU1);
                    Dec(I);
                    Inc(J);
                End;
            End
            Else
                Break;
        End;
    End
    Else
    Begin
        K := 2;
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CRU1);
                    Dec(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CRU1);
                    Dec(I);
                    Inc(J);
                End;
            End
            Else
                Break;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Dec(I);
    If (I Mod 2 = 0) Then  //вверх влево
    Begin
        K := 2;
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CLU0);
                Dec(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CLU0);
                Dec(I);
                Dec(J);
            End;
        End;
    End
    Else
    Begin
        Dec(J);
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CLU0);
                Dec(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CLU0);
                Dec(I);
                Inc(J);
            End;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Dec(I);
    If (I Mod 2 = 0) Then  //вверх влево
    Begin
        K := 2;
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CLU1);
                    Dec(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CLU1);
                    Dec(I);
                    Dec(J);
                End;
            End
            Else
                Break;
        End;
    End
    Else
    Begin
        Dec(J);
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CLU1);
                    Dec(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CLU1);
                    Dec(I);
                    Inc(J);
                End;
            End
            Else
                Break;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Inc(I);
    If (I Mod 2 = 0) Then  //вниз вправо
    Begin
        Inc(J);
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CRD0);
                Inc(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CRD0);
                Inc(I);
                Inc(J);
            End;
        End;
    End
    Else
    Begin
        K := 2;
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CRD0);
                Inc(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CRD0);
                Inc(I);
                Inc(J);
            End;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Inc(I);
    If (I Mod 2 = 0) Then  //вниз вправо
    Begin
        Inc(J);
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CRD1);
                    Inc(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CRD1);
                    Inc(I);
                    Inc(J);
                End;
            End
            Else
                Break;
        End;
    End
    Else
    Begin
        K := 2;
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CRD1);
                    Inc(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CRD1);
                    Inc(I);
                    Inc(J);
                End;
            End
            Else
                Break;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Inc(I);
    If (I Mod 2 = 0) Then  //вниз влево
    Begin
        K := 2;
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CLD0);
                Inc(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CLD0);
                Inc(I);
                Dec(J);
            End;
        End;
    End
    Else
    Begin
        Dec(J);
        While (Matrix[I, J] <> -1) Do
        Begin
            If K <> 2 Then
            Begin
                Inc(CLD0);
                Inc(I);
                Inc(K);
            End
            Else
            Begin
                K := 1;
                Inc(CLD0);
                Inc(I);
                Dec(J);
            End;
        End;
    End;

    I := CatI;
    J := CatJ;
    K := 1;

    Inc(I);
    If (I Mod 2 = 0) Then  //вниз влево
    Begin
        K := 2;
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CLD1);
                    Inc(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CLD1);
                    Inc(I);
                    Dec(J);
                End;
            End
            Else
                Break;
        End;
    End
    Else
    Begin
        Dec(J);
        While (Matrix[I, J] <> 1) Do
        Begin
            If (Matrix[I, J] <> -1) Then
            Begin
                If K <> 2 Then
                Begin
                    Inc(CLD1);
                    Inc(I);
                    Inc(K);
                End
                Else
                Begin
                    K := 1;
                    Inc(CLD1);
                    Inc(I);
                    Dec(J);
                End;
            End
            Else
                Break;
        End;
    End;
End;

Procedure TMainForm.BrushIntoLime(X1, Y1, X2, Y2, N: Integer);
Begin
    Btns[N].Visible := False;
    Background.Canvas.Brush.Color := ClWhite;
    Background.Canvas.Pen.Color := ClWhite;
    Background.Canvas.Rectangle(X1, Y1, X2, Y2);
    Background.Canvas.Brush.Color := ClLime;
    Background.Canvas.Ellipse(X1, Y1, X2, Y2);
End;

Procedure TMainForm.MoveImage(Top, Left, CatI, CatJ: Integer; Var X1, Y1, X2, Y2, I, J, N: Integer; CaseN: Integer);
Begin
    Cat.Left := Cat.Left + Left; //вправо
    Cat.Top := Cat.Top + Top;
    Case CaseN Of
        1: Matrix[CatI, CatJ + 1] := 2;
        2: Matrix[CatI, CatJ - 1] := 2;
        3: Begin
            If (CatI Mod 2 <> 0) Then
                Matrix[CatI - 1, CatJ + 1] := 2
            Else
                Matrix[CatI - 1, CatJ] := 2;
        End;
        4: Begin
            If (CatI Mod 2 <> 0) Then
                Matrix[CatI - 1, CatJ] := 2
            Else
                Matrix[CatI - 1, CatJ - 1] := 2;
        End;
        5: Begin
            If (CatI Mod 2 <> 0) Then
                Matrix[CatI + 1, CatJ + 1] := 2
            Else
                Matrix[CatI + 1, CatJ] := 2;
        End;
        6: Begin
            If (CatI Mod 2 <> 0) Then
                Matrix[CatI + 1, CatJ] := 2
            Else
                Matrix[CatI + 1, CatJ - 1] := 2;
        End;
    End;

    GetCoordsOfButton(Cat.Top + 240, Cat.Left + 623, I, J, X1, Y1, X2, Y2);
    N := (I - 1) * 11 + J;

    CatCoords[1] := X1;
    CatCoords[2] := Y1;
    CatCoords[3] := X2;
    CatCoords[4] := Y2;
    CatCoords[5] := N;
End;

Procedure TMainForm.MoveCat(X1, Y1, X2, Y2, CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1, CatI, CatJ: Integer; Flag, FlagA: Boolean);
Var
    I, J, N: Integer;
Begin
    I := CatI;
    J := CatJ;

    If Flag And (CR1 = 0) And (CL1 = 0) And (CRU1 = 0) And (CLU1 = 0) And (CRD1 = 0) And (CLD1 = 0) Then
    Begin
        WinForm.Show;
        Timer.Enabled := False;
        FlagA := False;
        GetCoordsOfButton(Cat.Top + 240, Cat.Left + 623, I, J, X1, Y1, X2, Y2);
        N := (I - 1) * 11 + J;
        BrushIntoLime(X1, Y1, X2, Y2, N);
    End;
    If FlagA And (CR0 = CR1) And (CR0 <= CL0) And (CR0 <= CRU0) And (CR0 <= CLU0) And (CR0 <= CRD0) And (CR0 <= CLD0) Then //если путь открыт
    Begin
        MoveImage(0, 60, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 1);

        If (J < 12) Then
            BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CL0 = CL1) And (CL0 <= CRU0) And (CL0 <= CLU0) And (CL0 <= CRD0) And (CL0 <= CLD0) Then //если он закрыт, проверить имеются ли свободные пути
    Begin
        MoveImage(0, -60, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 2);

        If (J > 0) Then
            BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CRU0 = CRU1) And (CRU0 <= CLU0) And (CRU0 <= CRD0) And (CRU0 <= CLD0) Then
    Begin
        MoveImage(-50, 30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 3);

        If I > 0 Then
            BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CLU0 = CLU1) And (CLU0 <= CRD0) And (CLU0 <= CLD0) Then
    Begin
        MoveImage(-50, -30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 4);

        If (I < 12) Then
            BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CRD0 = CRD1) And (CRD0 <= CLD0) Then
    Begin
        MoveImage(50, 30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 5);

        If I < 12 Then
            BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CLD0 = CLD1) Then
    Begin
        MoveImage(50, -30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 6);

        If I < 12 Then
            BrushIntoLime(X1, Y1, X2, Y2, N);

    End
    Else If FlagA And (CR1 >= CL1) And (CR1 >= CRU1) And (CR1 >= CLU1) And (CR1 >= CRD1) And (CR1 >= CLD1) Then
    Begin
        MoveImage(0, 60, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 1);

        BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CL1 >= CR1) And (CL1 >= CRU1) And (CL1 >= CLU1) And (CL1 >= CRD1) And (CL1 >= CLD1) Then
    Begin
        MoveImage(0, -60, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 2);

        BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CRU1 >= CL1) And (CRU1 >= CR1) And (CRU1 >= CLU1) And (CRU1 >= CRD1) And (CRU1 >= CLD1) Then
    Begin
        MoveImage(-50, 30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 3);

        BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CLU1 >= CL1) And (CLU1 >= CRU1) And (CLU1 >= CR1) And (CLU1 >= CRD1) And (CLU1 >= CLD1) Then
    Begin
        MoveImage(-50, -30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 4);

        BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CRD1 >= CL1) And (CRD1 >= CRU1) And (CRD1 >= CLU1) And (CRD1 >= CR1) And (CRD1 >= CLD1) Then
    Begin
        MoveImage(50, 30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 5);

        BrushIntoLime(X1, Y1, X2, Y2, N);
    End
    Else If FlagA And (CLD1 >= CL1) And (CLD1 >= CRU1) And (CLD1 >= CLU1) And (CLD1 >= CRD1) And (CLD1 >= CR1) Then
    Begin
        MoveImage(50, -30, CatI, CatJ, X1, Y1, X2, Y2, I, J, N, 6);

        BrushIntoLime(X1, Y1, X2, Y2, N);
    End;
End;

Procedure TMainForm.CheckIfLost(CatI, CatJ: Integer; Var Flag: Boolean);
Begin
    If (CatJ = 12) Or (CatI = 12) Or (CatJ = 2) Or (CatI = 2) Then //если стоял на границе
    Begin
        LoseForm.Show;
        Timer.Enabled := False;
        Flag := False;
    End
    Else
        Matrix[CatI, CatJ] := 0; //открываем прошлую
End;

Procedure TMainForm.CatsBrain();
Var
    Flag, FlagA: Boolean;
    X1, Y1, X2, Y2, I, J, K, Counter, X, Y, N: Integer;
    CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1, RAU, RAD, LAU, LAD, CatI, CatJ: Integer;
Begin
    UnblockPrevious; //разблокировка прошлой кнопки

    FindCat(CatI, CatJ); //поиск прошлой позиции кота

    CheckIfLost(CatI, CatJ, Flag); //проверка на проигрыш

    InitVariables(CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1, Flag, FlagA); //инициализациия переменных

    TakeVariables(CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1, CatI, CatJ); //получение значений переменных

    MoveCat(X1, Y1, X2, Y2, CR0, CL0, CRU0, CLU0, CRD0, CLD0, CR1, CL1, CRU1, CLU1, CRD1, CLD1, CatI, CatJ, Flag, FlagA); //перемещение кота
End;

Procedure TMainForm.ButtonClick(Sender: TObject);
Var
    Flag, FlagA: Boolean;
    Pt: TPoint;
    X1, Y1, X2, Y2, I, J, K, Counter, X, Y, N: Integer;
Begin
    Timer.Enabled := True;
    Flag := True;
    FlagA := True;
    Pt := Mouse.CursorPos;

    GetCoordsOfButton(Pt.Y, Pt.X, I, J, X1, Y1, X2, Y2);

    If (I < 12) And (J < 12) And (I <> 0) And (J <> 0) Then
    Begin
        Background.Canvas.Brush.Color := ClWhite; //зарисовка нажатой кнопки
        Background.Canvas.Pen.Color := ClWhite;
        Background.Canvas.Rectangle(X1, Y1, X2, Y2);
        Background.Canvas.Brush.Color := ClGreen;
        Background.Canvas.Ellipse(X1, Y1, X2, Y2);

        Matrix[I + 1, J + 1] := 1;

        N := (I - 1) * 11 + J;

        Btns[N].Visible := False;

        CatsBrain;
    End;
End;

Procedure TMainForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    WND: HWND;
    lpCaption, lpText: PChar;
    Tip: Integer;
    I: Integer;
Begin
    Timer.Enabled := False;
    WND := MainForm.Handle;
    lpCaption := 'Выход';
    lpText := 'Вы уверены, что хотите выйти?';
    Tip := MB_YESNO + MB_ICONINFORMATION + MB_DEFBUTTON2;
    Case MessageBox(WND, lpText, lpCaption, Tip) Of
        IDYES :
        Begin
            For I := 1 To 121 Do
                Btns[I].Free;
            CanClose := True;
        End;
        IDNO :
        Begin
            CanClose := False;
            Timer.Enabled := True;
        End;
    End;

End;

Procedure TMainForm.ResetButtonClick(Sender: TObject);
Var
    I: Integer;
Begin
    Background.Canvas.Brush.Color := ClWhite;
    Background.Canvas.Rectangle(0, 0, Background.Width, Background.Height);

    For I := 1 To 121 Do
        Btns[I].Visible := True;

    FormCreate(Sender);
End;

Procedure TMainForm.TimerTimer(Sender: TObject);
Begin
    S := S + Acc;
    If S >= 60 Then
    Begin
        S := 0;
        M := M + 1;
    End;

    If M < 10 Then
        Mins.Caption := '0' + IntToStr(M)
    Else
        Mins.Caption := IntToStr(M);
    If S < 10 Then
        Secs.Caption := '0' + FloatToStr(S)
    Else
        Secs.Caption := FloatToStr(S);
End;

End.

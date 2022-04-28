Unit UnitLose;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

Type
  TLoseForm = Class(TForm)
    Label1: TLabel;
    YesBtn: TButton;
    NoBtn: TButton;
    Label2: TLabel;
    Image1: TImage;
    Background: TImage;
    Procedure YesBtnClick(Sender: TObject);
    Procedure NoBtnClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  LoseForm: TLoseForm;

Implementation

Uses
    UnitMain;

{$R *.dfm}

Procedure TLoseForm.FormCreate(Sender: TObject);
Begin
    Background.Canvas.Brush.Color := ClWhite;
    Background.Canvas.Rectangle(0, 0, LoseForm.ClientWidth, LoseForm.ClientHeight);
End;

Procedure TLoseForm.NoBtnClick(Sender: TObject);
Begin
    MainForm.Close;
End;

Procedure TLoseForm.YesBtnClick(Sender: TObject);
Begin
    MainForm.ResetButton.Click;
    LoseForm.Hide;
End;

End.

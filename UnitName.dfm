object InputNameForm: TInputNameForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1042#1074#1077#1076#1080#1090#1077' '#1080#1084#1103
  ClientHeight = 53
  ClientWidth = 253
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object NameEdit: TEdit
    Left = 8
    Top = 16
    Width = 137
    Height = 21
    TabOrder = 0
    TextHint = #1042#1074#1077#1076#1080#1090#1077' '#1074#1072#1096#1077' '#1080#1084#1103
    OnChange = NameEditChange
    OnKeyDown = NameEditKeyDown
    OnKeyPress = NameEditKeyPress
  end
  object SaveButton: TButton
    Left = 160
    Top = 14
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    Default = True
    Enabled = False
    TabOrder = 1
    OnClick = SaveButtonClick
  end
  object SaveToFile: TSaveDialog
    Left = 152
    Top = 8
  end
end

object frmPropertySheet: TfrmPropertySheet
  Left = 404
  Top = 210
  Width = 486
  Height = 354
  BorderIcons = [biSystemMenu, biHelp]
  Caption = 'Properties'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object bvlBottom: TBevel
    Left = 0
    Top = 273
    Width = 475
    Height = 14
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object pgcDetails: TPageControl
    Left = 0
    Top = 4
    Width = 478
    Height = 277
    ActivePage = tabDetails
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = pgcDetailsChange
    object tabDetails: TTabSheet
      Caption = '&Details'
      object imgDetails: TImage
        Left = 412
        Top = 8
        Width = 32
        Height = 32
        Picture.Data = {
          07544269746D6170360C0000424D360C00000000000036000000280000002000
          0000200000000100180000000000000C00000000000000000000000000000000
          0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7F7F7F7F7F7F7F000000
          0000000000000000007F7F7F0000000000007F7F7F7F7F7F7F7F7FFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7F000000000000000000BFBFBF
          BFBFBFBFBFBF0000000000007F7F7FBFBFBF0000000000000000007F7F7F7F7F
          7F7F7F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7F000000000000BFBFBFBFBFBF7F7F7F
          BFBFBF000000FFFFFFFFFFFF0000007F7F7FBFBFBFBFBFBFFFFFFF0000000000
          000000007F7F7F7F7F7F7F7F7F7F7F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFF7F7F7F7F7F7F000000BFBFBFBFBFBF7F7F7FFFFFFFBFBFBF
          000000FFFFFFBFBFBFFFFFFFFFFFFF0000007F7F7FBFBFBFBFBFBFBFBFBFFFFF
          FFFFFFFF0000000000000000000000007F7F7F7F7F7F7F7F7FFFFFFFFFFFFFFF
          FFFFFFFFFF7F7F7F7F7F7F000000BFBFBF7F7F7F7F7F7FFFFFFF7F7F7FBFBFBF
          000000BFBFBFFFFFFFBFBFBFFFFFFFFFFFFF0000007F7F7FBFBFBFBFBFBFBFBF
          BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000007F7F7F7F7F7FFF
          FFFFFFFFFF7F7F7F000000BFBFBF7F7F7FFFFFFFFFFFFF7F7F7FBFBFBF000000
          BFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF0000007F7F7FBFBFBFBFBF
          BFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000007F
          7F7FFFFFFF000000BFBFBF7F7F7FFFFFFFFFFFFF7F7F7F7F7F7FBFBFBF000000
          FFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFBFBFBFFFFFFF0000007F7F7FBFBF
          BFBFBFBFBFBFBFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFFFFFFFFFFFFFFF00
          0000FFFFFF000000BFBFBF7F7F7F7F7F7F7F7F7FBFBFBFBFBFBF000000FFFFFF
          BFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF0000007F7F
          7FBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFFBFBFBFFFFFFFFFFFFF00
          0000FFFFFF000000BFBFBFBFBFBFBFBFBFBFBFBF000000000000FFFFFFBFBFBF
          FFFFFFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFBFBFBFFFFFFF0000
          007F7F7FBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF000000FF
          FFFFFFFFFFFFFFFF000000000000000000000000FFFFFFFFFFFFBFBFBFFFFFFF
          FFFFFFBFBFBFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFF
          FF0000007F7F7FBFBFBFBFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF
          FFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFFF
          FFFFFFBFBFBFFFFFFFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBF7F7F
          7F00007F0000007F7F7FBFBFBFBFBFBFFFFFFFBFBFBFFFFFFF000000FFFFFFFF
          FFFFFFFFFFFFFFFF0000007F7F7F000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          BFBFBFFFFFFFFFFFFFBFBFBFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBF0000000000
          7F00007F00007F0000007F7F7FBFBFBFBFBFBFFFFFFFFFFFFF000000FFFFFFFF
          FFFFFFFFFFFFFFFF000000FFFFFF7F7F7F000000FFFFFFFFFFFFBFBFBFBFBFBF
          FFFFFFFFFFFFFFFFFFBFBFBFFFFFFFBFBFBFFFFFFFBFBFBF00007FBFBFBF0000
          7F00007F00007F7F7F7F0000007F7F7FBFBFBFBFBFBF000000FFFFFFFFFFFFFF
          FFFFFFFFFF000000FFFFFFBFBFBFFFFFFF7F7F7F000000FFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFBFBFBFFFFFFFFFFFFFFFFFFF00000000007FBFBFBF00007FBFBF
          BF7F7F7FBFBFBFFFFFFFFFFFFF0000007F7F7FBFBFBF000000FFFFFFFFFFFFFF
          FFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFF7F7F7F000000FFFFFFBFBFBF
          BFBFBFFFFFFFFFFFFFFFFFFF7F7F7F00000000007F00007F00007FBFBFBFBFBF
          BFBFBFBFFFFFFFBFBFBFBFBFBFFFFFFF0000007F7F7FFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFF000000FFFFFFBFBFBFBFBFBFFFFFFFFFFFFF7F7F7F000000FFFFFF
          FFFFFFFFFFFFFFFFFF00000000007F00007F00007F00007F7F7F7FFFFFFFBFBF
          BFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFF7F7F7F000000
          7F7F7F00000000000000007F00007F00007F00007F7F7F7FFFFFFFBFBFBFFFFF
          FFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF000000FFFFFFFFFFFFFF
          FFFFFFFFFF000000FFFFFFFFFFFFBFBFBFFFFFFFFFFFFFFFFFFFBFBFBF7F7F7F
          000000BFBFBF0000FF00007F00007F00007F7F7F7FFFFFFFFFFFFFFFFFFFBFBF
          BFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFBFBFBFFFFFFF000000FFFFFFFF
          FFFF000000FFFFFFFFFFFFFFFFFFFFFFFFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFF
          7F7F7F000000BFBFBF0000FF7F7F7F7F7F7FFFFFFFFFFFFFFFFFFFBFBFBFFFFF
          FFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF000000FF
          FFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBF
          FFFFFF7F7F7F0000007F7F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFBFBF
          BFFFFFFFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFBFBFBFFFFFFFFFFFFF00
          0000000000FFFFFFFF0000FF0000FF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFF7F7F7F000000FFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFF
          FFFFFFFFFFFFFFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBFFFFFFFFFFFFF000000FF
          FFFF000000FFFFFFFF0000FF0000FF0000FF0000FF0000FF0000FF0000FFFFFF
          FFFFFFFFFFFFFFFFFF7F7F7F000000FFFFFFBFBFBFBFBFBFFFFFFFFFFFFFFFFF
          FFFFFFFFBFBFBFFFFFFFBFBFBFFFFFFFBFBFBFBFBFBFBFBFBF000000FFFFFFFF
          FFFF000000FFFFFFFF0000FF0000FF0000FF0000FF0000FF0000FF0000FFFFFF
          7F7F7FFFFFFFFFFFFFFFFFFF7F7F7F000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFBFBFBFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFBFBFBF000000FFFFFFFFFFFFFF
          FFFF000000FFFFFFFF0000FF0000FF0000FF0000FF0000FF0000FF0000FFFFFF
          FFFFFF000000FFFFFF7F7F7FFFFFFF7F7F7F000000FFFFFFFFFFFFBFBFBFBFBF
          BFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFBFBFBFBFBFBF000000FFFFFFFFFFFFFF
          FFFF000000FFFFFFFF0000FF0000FF0000FF0000FF0000FF0000FF0000FFFFFF
          7F7F7FBFBFBFFFFFFFFFFFFF000000FFFFFF7F7F7F000000FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFF
          FFFF000000FFFFFFFF0000FF0000FF0000FF0000FF0000FF0000FF0000FFFFFF
          FFFFFF7F7F7FFFFFFF000000FFFFFFFFFFFFBFBFBF7F7F7F000000FFFFFFFFFF
          FFBFBFBFBFBFBFBFBFBFFFFFFFFFFFFFBFBFBF000000FFFFFFFFFFFFFFFFFFFF
          FFFF000000FFFFFFFFFFFFFFFFFFFF0000FF0000FF0000FF0000FF0000FFFFFF
          000000000000FFFFFF7F7F7FFFFFFFFFFFFF7F7F7FFFFFFF7F7F7F000000FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBF000000FFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF7F7F7F000000FFFFFFFFFFFF000000FFFFFF7F7F7F0000
          00FFFFFFFFFFFFFFFFFFBFBFBF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7F000000FFFFFFFFFFFF7F7F
          7F000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
          000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000007F7F
          7FFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF000000000000000000000000000000FFFFFFFFFFFFFFFF
          FFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000
          00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF}
      end
      object lblDetails: TLabel
        Left = 342
        Top = 12
        Width = 62
        Height = 25
        Alignment = taRightJustify
        Caption = 'Details'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object btnOK: TButton
    Left = 232
    Top = 289
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 316
    Top = 289
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnApply: TButton
    Left = 400
    Top = 289
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Apply'
    TabOrder = 3
    OnClick = btnApplyClick
  end
end

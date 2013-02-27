object FormTIDeployChild_App: TFormTIDeployChild_App
  Left = 373
  Top = 175
  Width = 512
  Height = 476
  Caption = 'FormTIDeployChild_App'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    504
    449)
  PixelsPerInch = 96
  TextHeight = 13
  object PC: TPageControl
    Left = 8
    Top = 8
    Width = 491
    Height = 437
    ActivePage = tsDescription
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = PCChange
    object tsDescription: TTabSheet
      Caption = '&Description'
      DesignSize = (
        483
        409)
      object paeAppName: TtiPerAwareEdit
        Left = 17
        Top = 12
        Width = 220
        Height = 23
        ShowFocusRect = True
        Constraints.MinHeight = 23
        TabOrder = 0
        Caption = 'Application'#39's &name'
        LabelWidth = 100
        ReadOnly = False
        OnChange = paeAppNameChange
        MaxLength = 20
        CharCase = ecNormal
        PasswordChar = #0
        OnKeyPress = paeAppNameKeyPress
      end
      object paeAppDescription: TtiPerAwareMemo
        Left = 17
        Top = 104
        Width = 461
        Height = 301
        ShowFocusRect = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        Constraints.MinHeight = 23
        TabOrder = 1
        LabelStyle = lsTopLeft
        Caption = 'Application'#39's group &description'
        LabelWidth = 160
        ReadOnly = False
        OnChange = paeAppNameChange
        ScrollBars = ssVertical
        WordWrap = True
        MaxLength = 2000
      end
      object paeCompression: TtiPerAwareComboBoxStatic
        Left = 17
        Top = 68
        Width = 220
        Height = 23
        ShowFocusRect = True
        Constraints.MinHeight = 23
        TabOrder = 2
        Caption = '&Compression'
        LabelWidth = 100
        ReadOnly = False
        OnChange = paeCompressionChange
        DropDownCount = 8
        CharCase = ecNormal
      end
      object paeIcon: TtiPerAwareImageEdit
        Left = 292
        Top = 8
        Width = 153
        Height = 81
        ShowFocusRect = True
        Constraints.MinHeight = 23
        TabOrder = 3
        LabelStyle = lsTopLeft
        Caption = '&Icon'
        ReadOnly = False
        ScrollBars = ssBoth
        Stretch = False
        Filter = 
          'All (*.jpg;*.jpeg;*.bmp;*.ico;*.emf;*.wmf)|*.jpg;*.jpeg;*.bmp;*.' +
          'ico;*.emf;*.wmf|JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*' +
          '.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bmp|Icons (*.ico)|*.ico|Enhanced' +
          ' Metafiles (*.emf)|*.emf|Metafiles (*.wmf)|*.wmf'
      end
      object paeDisplayText: TtiPerAwareEdit
        Left = 17
        Top = 40
        Width = 220
        Height = 23
        ShowFocusRect = True
        Constraints.MinHeight = 23
        TabOrder = 4
        Caption = 'Display &text'
        LabelWidth = 100
        ReadOnly = False
        OnChange = paeAppNameChange
        MaxLength = 0
        CharCase = ecNormal
        PasswordChar = #0
      end
    end
    object tsFiles: TTabSheet
      Caption = '&Files'
      ImageIndex = 1
      DesignSize = (
        483
        409)
      object lblFileCount: TLabel
        Left = 28
        Top = 392
        Width = 54
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'lblFileCount'
      end
      object sbSaveOne: TSpeedButton
        Left = 1
        Top = 28
        Width = 23
        Height = 22
        Hint = 'Save One'
        Enabled = False
        Flat = True
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777770000000000000770330000007703077033000000770307703300000077
          0307703300000000030770333333333333077033000000003307703077777777
          0307703077777777030770307777777703077030777777770307703077777777
          0007703077777777070770000000000000077777777777777777}
        ParentShowHint = False
        ShowHint = True
        OnClick = sbSaveOneClick
      end
      object LVFiles: TtiListView
        Left = 28
        Top = 9
        Width = 449
        Height = 376
        ShowFocusRect = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        MultiSelect = False
        SmallImages = ilListView
        ViewStyle = vsReport
        RowSelect = True
        OnItemEdit = LVFilesItemEdit
        OnItemInsert = LVFilesItemInsert
        OnItemDelete = LVFilesItemDelete
        OnFilterData = LVFilesFilterData
        OnGetFont = LVFilesGetFont
        ApplyFilter = True
        ApplySort = False
        OnGetImageIndex = LVFilesGetImageIndex
        ListColumns = <
          item
            DisplayLabel = 'Deploy from'
            FieldName = 'DeployFromPathAndName'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end
          item
            DisplayLabel = 'Deploy to path'
            FieldName = 'DeployToPath'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end
          item
            DisplayLabel = 'Dirty ?'
            FieldName = 'DeployFromDirty'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end
          item
            DisplayLabel = 'Launch ?'
            FieldName = 'Launch'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end>
        SortOrders = <>
        AfterRefreshData = LVFilesAfterRefreshData
        OnItemArive = LVFilesItemArive
        OnItemLeave = LVFilesItemLeave
        RuntimeGenCols = False
        VisibleButtons = [tiLVBtnVisNew, tiLVBtnVisEdit, tiLVBtnVisDelete]
        CanStartDrag = False
        DesignSize = (
          449
          376)
      end
    end
    object tsParams: TTabSheet
      Caption = '&Parameters'
      ImageIndex = 2
      DesignSize = (
        483
        409)
      object LVParams: TtiListView
        Left = 4
        Top = 8
        Width = 473
        Height = 397
        ShowFocusRect = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        MultiSelect = False
        ViewStyle = vsReport
        RowSelect = True
        OnItemEdit = LVParamsItemEdit
        OnItemInsert = LVParamsItemInsert
        OnItemDelete = LVFilesItemDelete
        OnFilterData = LVFilesFilterData
        ApplyFilter = True
        ApplySort = False
        ListColumns = <
          item
            DisplayLabel = 'Display Text'
            FieldName = 'DisplayText'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end
          item
            DisplayLabel = 'Parameters'
            FieldName = 'ParamStr'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end
          item
            DisplayLabel = 'Description'
            FieldName = 'Description'
            DataType = lvtkString
            Derived = False
            Alignment = taLeftJustify
          end>
        SortOrders = <>
        RuntimeGenCols = False
        VisibleButtons = [tiLVBtnVisNew, tiLVBtnVisEdit, tiLVBtnVisDelete]
        CanStartDrag = False
        DesignSize = (
          473
          397)
      end
    end
  end
  object ilListView: TImageList
    BlendColor = clWhite
    BkColor = clWhite
    DrawingStyle = dsTransparent
    Left = 72
    Top = 206
    Bitmap = {
      494C010101000400040010001000FFFFFF00FF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C6008484840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C6000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C6000000000000FFFF0000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C6000000000000000000000000000000000000FFFF0000000000C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C6000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000000000C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C60000000000FFFFFF0000FFFF000000000000000000000000000000
      0000C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C6000000000000FFFF0000FFFF0000FFFF0000000000C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00000000000000
      000000000000000000000000000000FFFF00FFFFFF0000FFFF0000000000C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF0000000000FFFF
      FF0000FFFF0000FFFF0000FFFF00FFFFFF0000FFFF0000FFFF0000FFFF000000
      0000C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C6000000
      0000FFFFFF0000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      000000000000C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C6000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C6000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C60000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C6C6C600C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C60000000000FFFFFF0000FFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF0000000000C6C6C600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C6000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00C003000000000000C003000000000000
      C003000000000000C003000000000000C003000000000000C003000000000000
      C203000000000000C003000000000000C083000000000000D103000000000000
      CA03000000000000C503000000000000C283000000000000C7E3000000000000
      C2D3000000000000C00300000000000000000000000000000000000000000000
      000000000000}
  end
end

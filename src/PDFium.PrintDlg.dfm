object PrintDlg: TPrintDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Printer'
  ClientHeight = 634
  ClientWidth = 720
  Color = clBtnShadow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 720
    Height = 89
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 1
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    ExplicitLeft = -5
    object LabelImprimante: TLabel
      Left = 10
      Top = 16
      Width = 32
      Height = 13
      Caption = 'Printer'
    end
    object LabelCopies: TLabel
      Left = 10
      Top = 56
      Width = 39
      Height = 13
      Caption = 'Copies :'
    end
    object cbPrinters: TComboBox
      Left = 93
      Top = 11
      Width = 303
      Height = 27
      Style = csOwnerDrawFixed
      ItemHeight = 21
      TabOrder = 0
      OnChange = cbPrintersChange
    end
    object btProperties: TButton
      Left = 403
      Top = 9
      Width = 114
      Height = 34
      Caption = 'Properties'
      TabOrder = 1
      OnClick = btPropertiesClick
    end
    object seCopies: TSpinEdit
      Left = 60
      Top = 53
      Width = 49
      Height = 22
      MaxValue = 999
      MinValue = 1
      TabOrder = 2
      Value = 1
    end
    object cbGrouped: TCheckBox
      Left = 114
      Top = 57
      Width = 87
      Height = 17
      Caption = 'Collate'
      TabOrder = 3
    end
    object cbAnnotations: TCheckBox
      Left = 207
      Top = 57
      Width = 177
      Height = 17
      Caption = 'Print annotations'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = cbAnnotationsClick
    end
  end
  object Panel6: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 584
    Width = 720
    Height = 50
    Margins.Left = 0
    Margins.Top = 1
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel2'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = -5
    ExplicitTop = 583
    object btCancel: TButton
      AlignWithMargins = True
      Left = 602
      Top = 5
      Width = 113
      Height = 40
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 601
    end
    object btPrint: TButton
      AlignWithMargins = True
      Left = 479
      Top = 5
      Width = 113
      Height = 40
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Caption = 'Print'
      Default = True
      TabOrder = 0
      OnClick = btPrintClick
      ExplicitLeft = 478
    end
  end
  object Panel2: TPanel
    AlignWithMargins = True
    Left = 401
    Top = 90
    Width = 319
    Height = 493
    Margins.Left = 1
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alRight
    BevelOuter = bvNone
    Caption = 'Panel2'
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    ShowCaption = False
    TabOrder = 2
    ExplicitLeft = 391
    ExplicitHeight = 497
    object PaintBox: TPaintBox
      Left = 15
      Top = 55
      Width = 290
      Height = 380
      OnPaint = PaintBoxPaint
    end
    object lbScale: TLabel
      Left = 10
      Top = 8
      Width = 61
      Height = 13
      Caption = 'Scale: 100%'
    end
    object lbPageSize: TLabel
      Left = 15
      Top = 30
      Width = 52
      Height = 13
      Caption = '21 x 29 cm'
    end
    object btFirst: TButton
      Tag = -2
      Left = 16
      Top = 448
      Width = 48
      Height = 41
      Caption = '9'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clGray
      Font.Height = -27
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TabStop = False
      OnClick = btNavigate
    end
    object btPrev: TButton
      Tag = -1
      Left = 70
      Top = 448
      Width = 48
      Height = 41
      Caption = '3'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clGray
      Font.Height = -27
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      TabStop = False
      OnClick = btNavigate
    end
    object btLast: TButton
      Tag = 2
      Left = 256
      Top = 448
      Width = 48
      Height = 41
      Caption = ':'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clGray
      Font.Height = -27
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      TabStop = False
      OnClick = btNavigate
    end
    object btNext: TButton
      Tag = 1
      Left = 202
      Top = 448
      Width = 48
      Height = 41
      Caption = '4'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clGray
      Font.Height = -27
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      TabStop = False
      OnClick = btNavigate
    end
    object edPage: TEdit
      Left = 124
      Top = 455
      Width = 72
      Height = 21
      TabStop = False
      TabOrder = 4
      Text = '1 / 1'
      OnChange = edPageChange
      OnExit = edPageExit
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 90
    Width = 400
    Height = 493
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel3'
    ParentBackground = False
    ParentColor = True
    ShowCaption = False
    TabOrder = 3
    ExplicitLeft = -3
    ExplicitTop = 87
    ExplicitHeight = 525
    object Panel5: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 377
      Width = 400
      Height = 116
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel2'
      Padding.Left = 5
      Padding.Top = 5
      Padding.Right = 5
      Padding.Bottom = 5
      ParentBackground = False
      ShowCaption = False
      TabOrder = 2
      ExplicitTop = 384
      ExplicitHeight = 141
      object CardPanel1: TCardPanel
        Left = 5
        Top = 5
        Width = 390
        Height = 106
        Align = alClient
        ActiveCard = CardEchelle
        BevelOuter = bvNone
        Caption = 'CardPanel1'
        ParentBackground = False
        ParentColor = True
        TabOrder = 0
        OnCardChange = CardPanel1CardChange
        ExplicitTop = 49
        ExplicitWidth = 389
        object CardEchelle: TCard
          Left = 0
          Top = 0
          Width = 390
          Height = 106
          Caption = 'Echelle'
          CardIndex = 0
          ParentColor = True
          TabOrder = 0
          ExplicitWidth = 389
          object Label6: TLabel
            Left = 242
            Top = 76
            Width = 11
            Height = 13
            Caption = '%'
          end
          object rbScale: TRadioButton
            Left = 10
            Top = 6
            Width = 113
            Height = 17
            Caption = 'Fit'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = rbScaleClick
          end
          object rbRealSize: TRadioButton
            Tag = 1
            Left = 10
            Top = 29
            Width = 113
            Height = 17
            Caption = 'Actual size'
            TabOrder = 1
            OnClick = rbScaleClick
          end
          object rbReduice: TRadioButton
            Tag = 2
            Left = 10
            Top = 52
            Width = 218
            Height = 17
            Caption = 'Shrink oversized pages'
            TabOrder = 2
            OnClick = rbScaleClick
          end
          object rbCustomScale: TRadioButton
            Tag = 3
            Left = 10
            Top = 77
            Width = 147
            Height = 17
            Caption = 'Custom scale'
            TabOrder = 3
            OnClick = rbScaleClick
          end
          object edCustomScale: TEdit
            Left = 168
            Top = 73
            Width = 71
            Height = 21
            Enabled = False
            TabOrder = 4
            Text = '100'
            OnChange = edCustomScaleChange
            OnExit = edCustomScaleExit
          end
        end
        object cdMulti: TCard
          Left = 0
          Top = 0
          Width = 390
          Height = 106
          Caption = 'Mise en page'
          CardIndex = 1
          TabOrder = 1
          ExplicitWidth = 389
          object LabelpagesparFeuilles: TLabel
            Left = 5
            Top = 11
            Width = 82
            Height = 13
            Caption = 'Pages per sheet:'
          end
          object LabelOrdrePages: TLabel
            Left = 5
            Top = 49
            Width = 57
            Height = 13
            Caption = 'Page order:'
          end
          object cbSheets: TComboBox
            Left = 120
            Top = 8
            Width = 96
            Height = 27
            Style = csOwnerDrawFixed
            ItemHeight = 21
            ItemIndex = 0
            TabOrder = 0
            Text = '2'
            OnChange = cbSheetsChange
            Items.Strings = (
              '2'
              '4'
              '6'
              '9'
              '16')
          end
          object cbPageOrder: TComboBox
            Left = 120
            Top = 41
            Width = 170
            Height = 27
            Style = csOwnerDrawFixed
            ItemHeight = 21
            ItemIndex = 0
            TabOrder = 1
            Text = 'Horizontal'
            OnChange = cbPageOrderChange
            Items.Strings = (
              'Horizontal'
              'Horizontal reversed'
              'Vertical'
              'Vertical reversed')
          end
          object cbPageContour: TCheckBox
            Left = 5
            Top = 85
            Width = 154
            Height = 17
            Caption = 'Print page border'
            TabOrder = 2
            OnClick = cbPageContourClick
          end
        end
      end
    end
    object Panel7: TPanel
      Left = 0
      Top = 0
      Width = 400
      Height = 145
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel2'
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      ExplicitLeft = -3
      ExplicitTop = -3
      object LabelpagesImprimer: TLabel
        Left = 10
        Top = 6
        Width = 82
        Height = 18
        Caption = 'Pages to print'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -14
        Font.Name = 'Source Sans Pro'
        Font.Style = []
        ParentFont = False
      end
      object Labelimpairespaires: TLabel
        Left = 15
        Top = 110
        Width = 94
        Height = 13
        Caption = 'Even or odd pages:'
      end
      object rbAllPages: TRadioButton
        Left = 15
        Top = 30
        Width = 186
        Height = 17
        Caption = 'All'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbAllPagesClick
      end
      object rbCurrentPage: TRadioButton
        Left = 15
        Top = 54
        Width = 169
        Height = 17
        Caption = 'Current page'
        TabOrder = 1
        OnClick = rbAllPagesClick
      end
      object rbCustomPages: TRadioButton
        Left = 15
        Top = 77
        Width = 73
        Height = 17
        Caption = 'Pages'
        TabOrder = 2
        OnClick = rbAllPagesClick
      end
      object edPages: TEdit
        Left = 98
        Top = 73
        Width = 197
        Height = 21
        Enabled = False
        TabOrder = 3
        Text = '1'
        OnChange = edPagesChange
      end
      object cbOddPages: TComboBox
        Left = 182
        Top = 105
        Width = 197
        Height = 27
        Style = csOwnerDrawFixed
        ItemHeight = 21
        ItemIndex = 0
        TabOrder = 4
        Text = 'Even and odd pages'
        OnChange = cbOddPagesChange
        Items.Strings = (
          'Even and odd pages'
          'Odd pages only'
          'Even pages only')
      end
    end
    object Panel8: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 146
      Width = 400
      Height = 191
      Margins.Left = 0
      Margins.Top = 1
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel2'
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      ExplicitWidth = 399
      object LabelOrientation: TLabel
        Left = 10
        Top = 50
        Width = 58
        Height = 13
        Caption = 'Orientation:'
      end
      object Labelrectoverso: TLabel
        Left = 10
        Top = 20
        Width = 105
        Height = 13
        Caption = 'Double-sided printing:'
      end
      object rbAuto: TRadioButton
        Left = 15
        Top = 69
        Width = 201
        Height = 20
        Caption = 'Automatic portrait/landscape'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = rbAutoClick
      end
      object rbPortrait: TRadioButton
        Tag = 1
        Left = 15
        Top = 95
        Width = 169
        Height = 20
        Caption = 'Portrait'
        TabOrder = 2
        OnClick = rbAutoClick
      end
      object rbLandscape: TRadioButton
        Tag = 2
        Left = 15
        Top = 118
        Width = 169
        Height = 20
        Caption = 'Landscape'
        TabOrder = 3
        OnClick = rbAutoClick
      end
      object cbRectoVerso: TComboBox
        Left = 182
        Top = 17
        Width = 197
        Height = 27
        Style = csOwnerDrawFixed
        ItemHeight = 21
        ItemIndex = 0
        TabOrder = 0
        Text = 'Off'
        OnChange = cbRectoVersoChange
        Items.Strings = (
          'Off'
          'Flip on long edge'
          'Flip on short edge')
      end
      object cbGrayscale: TCheckBox
        Left = 10
        Top = 144
        Width = 276
        Height = 17
        Caption = 'Print in grayscale (black and white)'
        TabOrder = 4
        OnClick = cbGrayscaleClick
      end
      object cbCenter: TCheckBox
        Left = 10
        Top = 167
        Width = 276
        Height = 17
        Caption = 'Center in the page'
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = cbCenterClick
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 337
      Width = 400
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel4'
      Padding.Left = 3
      ParentBackground = False
      ShowCaption = False
      TabOrder = 3
      object Shape1: TShape
        AlignWithMargins = True
        Left = 6
        Top = 36
        Width = 391
        Height = 1
        Align = alBottom
        Brush.Style = bsClear
        Pen.Color = clMedGray
        ExplicitLeft = 0
        ExplicitTop = -24
        ExplicitWidth = 400
      end
      object tabScale: TLabel
        Left = 3
        Top = 0
        Width = 68
        Height = 33
        Align = alLeft
        Alignment = taCenter
        AutoSize = False
        Caption = 'Scale'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        OnClick = tabScaleClick
        ExplicitLeft = -6
        ExplicitTop = -1
        ExplicitHeight = 34
      end
      object tabPageLayout: TLabel
        Tag = 1
        Left = 71
        Top = 0
        Width = 85
        Height = 33
        Align = alLeft
        Alignment = taCenter
        AutoSize = False
        Caption = 'Page layout'
        Layout = tlCenter
        OnClick = tabScaleClick
        ExplicitLeft = 68
        ExplicitHeight = 34
      end
      object tabShape: TShape
        Left = 3
        Top = 30
        Width = 68
        Height = 8
        Brush.Color = clTeal
        Pen.Style = psClear
      end
    end
  end
end

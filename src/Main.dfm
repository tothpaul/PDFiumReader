object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'PDFium Reader (c)2017-2019 Execute SARL'
  ClientHeight = 554
  ClientWidth = 608
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inline PDFium: TPDFiumFrame
    Left = 0
    Top = 48
    Width = 608
    Height = 506
    HorzScrollBar.Tracking = True
    VertScrollBar.Increment = 27
    VertScrollBar.Tracking = True
    Align = alClient
    DoubleBuffered = True
    Color = clGray
    ParentBackground = False
    ParentColor = False
    ParentDoubleBuffered = False
    TabOrder = 0
    OnResize = PDFiumResize
    ExplicitTop = 48
    ExplicitWidth = 608
    ExplicitHeight = 506
  end
  object pnButtons: TPanel
    Left = 0
    Top = 0
    Width = 608
    Height = 48
    Align = alTop
    Caption = 'pnButtons'
    ParentBackground = False
    ParentShowHint = False
    ShowCaption = False
    ShowHint = True
    TabOrder = 1
    object btZPlus: TPaintBox
      Tag = 4
      AlignWithMargins = True
      Left = 108
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Zoom in'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = btZPlusClick
      OnDblClick = btZPlusClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 41
    end
    object btZMinus: TPaintBox
      Tag = 2
      AlignWithMargins = True
      Left = 74
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Zoom out'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = btZPlusClick
      OnDblClick = btZPlusClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 46
    end
    object btOpen: TPaintBox
      AlignWithMargins = True
      Left = 6
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Open file'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = Open1Click
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitTop = 10
    end
    object pbZoom: TPaintBox
      AlignWithMargins = True
      Left = 140
      Top = 10
      Width = 72
      Height = 28
      Hint = 'Zoom'
      Margins.Top = 9
      Margins.Bottom = 9
      Align = alLeft
      OnMouseDown = pbZoomMouseDown
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = pbZoomPaint
      ExplicitLeft = 106
    end
    object btPageWidth: TPaintBox
      Tag = 6
      AlignWithMargins = True
      Left = 288
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Page width'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = mnFitWidthClick
      OnDblClick = mnFitWidthClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 338
      ExplicitTop = 24
    end
    object btFullPage: TPaintBox
      Tag = 8
      AlignWithMargins = True
      Left = 254
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Page level'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = mnPageLevelClick
      OnDblClick = mnPageLevelClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 220
      ExplicitTop = 10
    end
    object btActualSize: TPaintBox
      Tag = 10
      AlignWithMargins = True
      Left = 220
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Actual size'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = mnActualSizeClick
      OnDblClick = mnActualSizeClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 186
      ExplicitTop = 10
    end
    object btAbout: TPaintBox
      Tag = 12
      AlignWithMargins = True
      Left = 578
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Execute SARL'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alRight
      OnClick = btAboutClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 338
      ExplicitTop = 24
    end
    object btPrint: TPaintBox
      Tag = 18
      AlignWithMargins = True
      Left = 40
      Top = 12
      Width = 24
      Height = 24
      Hint = 'Print'
      Margins.Left = 5
      Margins.Top = 11
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alLeft
      OnClick = btPrintClick
      OnMouseEnter = ButtonMouseEnter
      OnMouseLeave = ButtonMouseLeave
      OnPaint = ButtonPaint
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 46
    end
    object pnPages: TPanel
      Left = 317
      Top = 1
      Width = 158
      Height = 46
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'pnPages'
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 0
      Visible = False
      OnResize = pnPagesResize
      ExplicitLeft = 283
      object btNext: TPaintBox
        Tag = 16
        AlignWithMargins = True
        Left = 39
        Top = 11
        Width = 24
        Height = 24
        Hint = 'Page width'
        Margins.Left = 5
        Margins.Top = 11
        Margins.Right = 5
        Margins.Bottom = 11
        Align = alLeft
        OnClick = btNextClick
        OnDblClick = btNextClick
        OnMouseEnter = ButtonMouseEnter
        OnMouseLeave = ButtonMouseLeave
        OnPaint = ButtonPaint
        ExplicitLeft = 374
        ExplicitTop = 10
      end
      object btPrev: TPaintBox
        Tag = 14
        AlignWithMargins = True
        Left = 5
        Top = 11
        Width = 24
        Height = 24
        Hint = 'Page width'
        Margins.Left = 5
        Margins.Top = 11
        Margins.Right = 5
        Margins.Bottom = 11
        Align = alLeft
        OnClick = btPrevClick
        OnDblClick = btPrevClick
        OnMouseEnter = ButtonMouseEnter
        OnMouseLeave = ButtonMouseLeave
        OnPaint = ButtonPaint
        ExplicitTop = 9
      end
      object lbPages: TLabel
        Left = 113
        Top = 0
        Width = 24
        Height = 46
        Align = alLeft
        Caption = '(0/0)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5066061
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 13
      end
      object shPage: TShape
        Left = 77
        Top = 32
        Width = 31
        Height = 1
        Brush.Style = bsClear
        Pen.Color = 13355979
      end
      object edPage: TEdit
        AlignWithMargins = True
        Left = 74
        Top = 16
        Width = 33
        Height = 14
        Margins.Left = 6
        Margins.Top = 16
        Margins.Right = 6
        Margins.Bottom = 16
        TabStop = False
        Align = alLeft
        Alignment = taCenter
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5066061
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = True
        ParentFont = False
        TabOrder = 0
        Text = '0'
        OnExit = edPageExit
        OnKeyDown = edPageKeyDown
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 176
    Top = 256
    object File1: TMenuItem
      Caption = '&File'
      object Open1: TMenuItem
        Caption = '&Open...'
        ShortCut = 16463
        OnClick = Open1Click
      end
      object Close1: TMenuItem
        Caption = 'Close'
        OnClick = Close1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Quit1: TMenuItem
        Caption = '&Quit'
        ShortCut = 16465
        OnClick = Quit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Copy1: TMenuItem
        Caption = 'Copy'
        ShortCut = 16451
        OnClick = Copy1Click
      end
    end
  end
  object ppZoom: TPopupMenu
    OnPopup = ppZoomPopup
    Left = 336
    Top = 256
    object N101: TMenuItem
      Tag = 10
      Caption = '10%'
      OnClick = MenuZoomClick
    end
    object N251: TMenuItem
      Tag = 25
      Caption = '25%'
      OnClick = MenuZoomClick
    end
    object N501: TMenuItem
      Tag = 50
      Caption = '50%'
      OnClick = MenuZoomClick
    end
    object N1001: TMenuItem
      Tag = 75
      Caption = '75%'
      OnClick = MenuZoomClick
    end
    object N1002: TMenuItem
      Tag = 100
      Caption = '100%'
      OnClick = MenuZoomClick
    end
    object N1251: TMenuItem
      Tag = 125
      Caption = '125%'
      OnClick = MenuZoomClick
    end
    object N1501: TMenuItem
      Tag = 150
      Caption = '150%'
      OnClick = MenuZoomClick
    end
    object N2001: TMenuItem
      Tag = 200
      Caption = '200%'
      OnClick = MenuZoomClick
    end
    object N4001: TMenuItem
      Tag = 400
      Caption = '400%'
      OnClick = MenuZoomClick
    end
    object N8001: TMenuItem
      Tag = 800
      Caption = '800%'
      OnClick = MenuZoomClick
    end
    object N16001: TMenuItem
      Tag = 1600
      Caption = '1600%'
      OnClick = MenuZoomClick
    end
    object N24001: TMenuItem
      Tag = 2400
      Caption = '2400%'
      OnClick = MenuZoomClick
    end
    object N32001: TMenuItem
      Tag = 3200
      Caption = '3200%'
      OnClick = MenuZoomClick
    end
    object N64001: TMenuItem
      Tag = 6400
      Caption = '6400%'
      OnClick = MenuZoomClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnActualSize: TMenuItem
      Caption = 'Actual size'
      OnClick = mnActualSizeClick
    end
    object mnPageLevel: TMenuItem
      Caption = 'Zoom to page level'
      OnClick = mnPageLevelClick
    end
    object mnFitWidth: TMenuItem
      Caption = 'Fit width'
      OnClick = mnFitWidthClick
    end
  end
end

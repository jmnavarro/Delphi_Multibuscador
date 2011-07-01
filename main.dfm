object MainForm: TMainForm
  Left = 249
  Top = 129
  Width = 463
  Height = 343
  ActiveControl = b_buscar
  Caption = 'Multi-buscador de archivos'
  Color = 15922418
  Constraints.MinHeight = 288
  Constraints.MinWidth = 357
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object s: TShape
    Left = 127
    Top = 6
    Width = 322
    Height = 274
    Anchors = [akLeft, akTop, akRight, akBottom]
    Brush.Color = clBtnFace
    Pen.Color = 12164479
  end
  object Label1: TLabel
    Left = 135
    Top = 16
    Width = 113
    Height = 13
    Caption = 'Carpetas de búsqueda:'
    Color = clBtnFace
    ParentColor = False
  end
  object Bevel1: TBevel
    Left = 251
    Top = 17
    Width = 191
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object Label2: TLabel
    Left = 135
    Top = 142
    Width = 57
    Height = 13
    Caption = 'Resultados:'
    Color = clBtnFace
    ParentColor = False
  end
  object Bevel2: TBevel
    Left = 195
    Top = 143
    Width = 246
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object Label3: TLabel
    Left = 42
    Top = 11
    Width = 70
    Height = 13
    Caption = 'Multi-buscador'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 48
    Top = 27
    Width = 55
    Height = 13
    Caption = 'de archivos'
  end
  object l_lwdjm: TLabel
    Left = 13
    Top = 67
    Width = 102
    Height = 13
    Cursor = crHandPoint
    Hint = 'Navegar a "La web de JM"'
    Caption = 'www.lawebdejm.com'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = l_AutoresClick
  end
  object Label6: TLabel
    Left = 18
    Top = 139
    Width = 64
    Height = 13
    Caption = 'Tiempo (sg.):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 18
    Top = 123
    Width = 64
    Height = 13
    Caption = 'Encontrados:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label8: TLabel
    Left = 8
    Top = 107
    Width = 60
    Height = 13
    Caption = 'Estadísticas:'
  end
  object Label9: TLabel
    Left = 18
    Top = 155
    Width = 63
    Height = 13
    Caption = 'Hilos activos:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Shape1: TShape
    Left = 7
    Top = 121
    Width = 114
    Height = 1
    Pen.Color = 12164479
  end
  object l_encontrados: TLabel
    Left = 82
    Top = 123
    Width = 38
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '?'
  end
  object l_tiempo: TLabel
    Left = 82
    Top = 139
    Width = 38
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '?'
  end
  object l_hilos: TLabel
    Left = 82
    Top = 155
    Width = 38
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0'
  end
  object l_salva: TLabel
    Left = 24
    Top = 49
    Width = 81
    Height = 13
    Cursor = crHandPoint
    Hint = 'Navegar a la web de Salvador Jover'
    Caption = 'www.sjover.com'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = l_AutoresClick
  end
  object b_anadir: TButton
    Left = 241
    Top = 114
    Width = 62
    Height = 20
    Action = a_anadir
    Anchors = [akTop, akRight]
    TabOrder = 0
  end
  object b_eliminar: TButton
    Left = 310
    Top = 114
    Width = 62
    Height = 20
    Action = a_eliminar
    Anchors = [akTop, akRight]
    TabOrder = 1
  end
  object lv_resultado: TListView
    Left = 135
    Top = 160
    Width = 306
    Height = 111
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Nombre'
        Width = 100
      end
      item
        Caption = 'En la carpeta'
        Width = 167
      end
      item
        Caption = 'Hilo'
        Width = 35
      end>
    RowSelect = True
    PopupMenu = pm_resultado
    TabOrder = 2
    ViewStyle = vsReport
    OnColumnClick = lv_resultadoColumnClick
    OnCompare = lv_resultadoCompare
    OnDblClick = a_abrirExecute
    OnEdited = lv_resultadoEdited
    OnEditing = lv_busquedasEditing
  end
  object b_modificar: TButton
    Left = 379
    Top = 114
    Width = 62
    Height = 20
    Action = a_modificar
    Anchors = [akTop, akRight]
    TabOrder = 3
  end
  object b_buscar: TButton
    Left = 310
    Top = 286
    Width = 66
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Buscar'
    Default = True
    TabOrder = 4
    OnClick = b_buscarClick
  end
  object ico: TAnimate
    Left = 12
    Top = 18
    Width = 16
    Height = 16
    Active = False
    StopFrame = 8
  end
  object lv_busquedas: TListView
    Left = 135
    Top = 35
    Width = 306
    Height = 76
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = '#'
        Width = 20
      end
      item
        Caption = 'Carpeta'
        Width = 170
      end
      item
        Alignment = taCenter
        Caption = 'Subcarpetas'
        Width = 72
      end
      item
        Alignment = taRightJustify
        Caption = 'Total'
        Width = 40
      end>
    ColumnClick = False
    Items.Data = {
      9B0000000300000000000000FFFFFFFFFFFFFFFF030000000000000001310843
      3A5C2A2E69636F0253ED013F00000000FFFFFFFFFFFFFFFF0300000000000000
      01321D433A5C4172636869766F732064652070726F6772616D615C2A2E657865
      0253ED013F00000000FFFFFFFFFFFFFFFF0300000000000000013308443A5C2A
      2E7478740253ED013FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    RowSelect = True
    PopupMenu = pm_busqueda
    TabOrder = 6
    ViewStyle = vsReport
    OnChange = lv_busquedasChange
    OnDblClick = a_modificarExecute
    OnEditing = lv_busquedasEditing
  end
  object b_acerca: TButton
    Left = 7
    Top = 287
    Width = 22
    Height = 22
    Anchors = [akLeft, akBottom]
    Caption = '?'
    TabOrder = 7
    OnClick = b_acercaClick
  end
  object b_Cancelar: TButton
    Left = 382
    Top = 286
    Width = 66
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancelar'
    Enabled = False
    TabOrder = 8
    OnClick = b_CancelarClick
  end
  object pm_busqueda: TPopupMenu
    Left = 136
    Top = 82
    object Aadir1: TMenuItem
      Action = a_anadir
    end
    object Eliminar1: TMenuItem
      Action = a_eliminar
    end
    object Modificar1: TMenuItem
      Action = a_modificar
    end
  end
  object acciones: TActionList
    Left = 98
    Top = 253
    object a_anadir: TAction
      Category = 'Rutas'
      Caption = '&Añadir'
      ShortCut = 45
      OnExecute = a_anadirExecute
    end
    object a_eliminar: TAction
      Category = 'Rutas'
      Caption = '&Eliminar'
      Enabled = False
      ShortCut = 46
      OnExecute = a_eliminarExecute
    end
    object a_modificar: TAction
      Category = 'Rutas'
      Caption = '&Modificar'
      Enabled = False
      ShortCut = 113
      OnExecute = a_modificarExecute
    end
    object a_abrir: TAction
      Category = 'Resultados'
      Caption = '&Abrir'
      Enabled = False
      OnExecute = a_abrirExecute
    end
    object a_abrircarpeta: TAction
      Category = 'Resultados'
      Caption = 'Abrir &carpeta contenedora'
      Enabled = False
      OnExecute = a_carpetaExecute
    end
    object a_explorar: TAction
      Category = 'Resultados'
      Caption = '&Explorar carpeta contenedora'
      Enabled = False
      OnExecute = a_explorarExecute
    end
    object a_cambiarnombre: TAction
      Category = 'Resultados'
      Caption = '&Cambiar nombre'
      Enabled = False
      ShortCut = 113
      OnExecute = a_cambiarnombreExecute
    end
    object a_eliminararch: TAction
      Category = 'Resultados'
      Caption = '&Eliminar'
      Enabled = False
      ShortCut = 46
      OnExecute = a_eliminararchExecute
    end
    object a_copiararch: TAction
      Category = 'Resultados'
      Caption = 'Copiar'
      Enabled = False
      ShortCut = 16451
      OnExecute = a_copiararchExecute
    end
    object a_propiedades: TAction
      Category = 'Resultados'
      Caption = 'Propiedades'
      Enabled = False
      OnExecute = a_propiedadesExecute
    end
  end
  object tiempo: TTimer
    Enabled = False
    OnTimer = tiempoTimer
    Left = 70
    Top = 253
  end
  object pm_resultado: TPopupMenu
    OnPopup = pm_resultadoPopup
    Left = 136
    Top = 242
    object Abrir1: TMenuItem
      Action = a_abrir
      Default = True
    end
    object Abrircarpetacontenedora1: TMenuItem
      Action = a_abrircarpeta
    end
    object Explorarcarpetacontenedora1: TMenuItem
      Action = a_explorar
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Copiar1: TMenuItem
      Action = a_copiararch
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object EliminarArch: TMenuItem
      Action = a_eliminararch
    end
    object Cambiarnombre1: TMenuItem
      Action = a_cambiarnombre
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Propiedades1: TMenuItem
      Action = a_propiedades
    end
  end
end

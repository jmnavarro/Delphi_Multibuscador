object AnadirRutaForm: TAnadirRutaForm
  Left = 287
  Top = 236
  ActiveControl = e_carpeta
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Añadir carpeta de búsqueda'
  ClientHeight = 155
  ClientWidth = 314
  Color = 15922418
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object s: TShape
    Left = 3
    Top = 2
    Width = 308
    Height = 116
    Brush.Color = clBtnFace
    Pen.Color = 12164479
  end
  object Label1: TLabel
    Left = 17
    Top = 24
    Width = 43
    Height = 13
    Caption = 'Carpeta:'
    Transparent = True
  end
  object Label2: TLabel
    Left = 17
    Top = 56
    Width = 44
    Height = 13
    Caption = 'Máscara:'
    Transparent = True
  end
  object Panel1: TPanel
    Left = 65
    Top = 19
    Width = 235
    Height = 22
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = clWindow
    TabOrder = 5
    object i_carpeta: TImage
      Left = 214
      Top = 2
      Width = 16
      Height = 14
      Cursor = crHandPoint
      Hint = 'Examinar'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        07544269746D6170D6020000424DD60200000000000036000000280000001000
        00000E0000000100180000000000A0020000120B0000120B0000000000000000
        0000EEEEEF9D6967998180B4B4B6D4D7DAEDEFF0FDFDFDFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD5BFC0BF5D3FC76134B75D3AAD64
        47A56556987674A5A4A6C5CBCEE3E6E8FCFDFDFDFDFDFFFFFFFFFFFFFFFFFFFF
        FFFFCEA7A5C16D55D06E40D46F3CD36C39D06736C96134B45535A157419A6D5F
        A7877FB7ABACD5D6D8F9FAFBFFFFFFFFFFFFCA9A97D58C74CC7755D57C50D276
        49D27345D1703FD36E3BD46E3BD26736CA6434BE5B33A5543EE7E2E2FFFFFFFF
        FFFFCA9B99DE9D85DA9377DA916DD98D66D8875FD68057D17244CF6B3BCF6D3C
        D16E3DD26D3CC46436D8BFBAFFFFFFFFFFFFC19695E1A18AE1A38BE1A588E0A1
        81DE9B7ADD9572DB8E69D78259D17143CF6B3ACF6A39C26638BC7964F8F3F3FF
        FFFFB3807CE7B19BE0A690DDA793ECC0A9E7B59CE5AE93E3A78BE1A283DE9978
        D98B65D47B50C1673BC67248D2AEA6FFFFFFB4726CEFC2AEE9B7A2D09586E6C0
        B0EBC5B4EEC8B5ECC1ABE8B79FE5B196E4AC90E1A386D29173D5926DCC9684FD
        FCFCB8726AF5D2C0F4CEBAE7B7A3CE8E7FE4B39FE2B2A1DFAD9BEFCDBCEFCCBA
        ECC4B0EABCA7E1B5A0E4BDA7D6A28EE5D2D1BB7871F8DDCDF5D5C3F4CFBBF4CB
        B5EEBEA8E9B19ADFA087D09384EFD4C8EFD1C4EFD0C1EAC8B9E9C9BAF1D2BFD9
        B8B1BF8078FDE7D9F7DCCDF5D5C4F3CEBCF1C9B5F2C6B0EFBFA7E5AC94DC9E88
        DEA089DFA08AA97974E2CCC5E8CEC5C59B96B77670FBE6D8FCE8DAF8DED0F7D9
        CAF6D6C3E8BAA7E1AE9BE9B49EEEBAA2F0BA9FE0957A8A605EF4F4F5FFFFFFF8
        F5F5DBC4C4E2BFB5F8E1D3FDE9DCFBE2D3DDB4A7C0928FD4ACA9D5B6B0CB948D
        CE988ED19588B39C9CFCFCFCFFFFFFFFFFFFFEFEFED2B2B2B57976BE7F78C78D
        84C9BAB9FDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFEFCFCFDFDFDFFFFFFFFFFFFFF
        FFFF}
      ShowHint = True
      OnClick = i_carpetaClick
    end
  end
  object b_cancelar: TButton
    Left = 240
    Top = 126
    Width = 68
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 0
  end
  object b_aceptar: TButton
    Left = 165
    Top = 126
    Width = 68
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Aceptar'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object e_carpeta: TEdit
    Left = 68
    Top = 23
    Width = 210
    Height = 15
    BorderStyle = bsNone
    TabOrder = 2
  end
  object e_mascara: TEdit
    Left = 65
    Top = 51
    Width = 235
    Height = 21
    TabOrder = 3
    Text = '*.*'
  end
  object cbx_subcarpetas: TCheckBox
    Left = 17
    Top = 91
    Width = 133
    Height = 17
    Caption = 'Buscar en subcarpetas'
    Checked = True
    Color = clBtnFace
    ParentColor = False
    State = cbChecked
    TabOrder = 4
  end
end

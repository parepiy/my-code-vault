Sub assort_update()
    Application.ScreenUpdating = False
    Dim wh As Workbook, ob As Workbook, pricelog As String
    Dim lastrow As Long, lastCol As String

    Set wh = ActiveWorkbook
    pricelog = wh.Name

    ' à»Ô´ä¿Åì Assortment
    Set ob = Workbooks.Open(fileName:="D:\OneDrive\OneDrive - cjmart\TD\Assortment\TD Assortment Report.xlsb", UpdateLinks:=False)

    With ob.Sheets("Sheet0")
        .Outline.ShowLevels RowLevels:=0, ColumnLevels:=2
        On Error Resume Next: .ShowAllData: On Error GoTo 0

        ' à¤ÅÕÂÃì¢éÍÁÙÅà¡èÒ
        .Range("A2:BK" & .Rows.Count).ClearContents
        .Range("A1").Value = Date

        ' ¤Ñ´ÅÍ¡¢éÍÁÙÅ¨Ò¡ä¿Åì»Ñ¨¨ØºÑ¹
        With wh.Sheets("raw_assort") ' »ÃÑºª×èÍªÕµ¶éÒ¨Óà»ç¹
            Dim sourceRange As Range
            Set sourceRange = .Range("A1:BJ" & .Cells(.Rows.Count, "A").End(xlUp).Row)
            sourceRange.Copy
        End With

        .Range("B2").PasteSpecial xlPasteValues

        ' ¤Ñ´ÅÍ¡¤ÍÅÑÁ¹ì AS
        .Range("AS2:AS" & .Cells(.Rows.Count, "AS").End(xlUp).Row).Copy

        .Range("A2").PasteSpecial xlPasteValues

        ' àµÔÁÊÙµÃáÅÐ AutoFill
        lastrow = .Cells(.Rows.Count, "A").End(xlUp).Row

        .Range("BL3").Formula = "=IFERROR(XLOOKUP(B3,'[" & pricelog & "]sup_price_bigq'!$H:$H,'[" & pricelog & "]sup_price_bigq'!$N:$N)*AW3,XLOOKUP(A3,'[" & pricelog & "]cost'!$F:$F,'[" & pricelog & "]cost'!$O:$O,0))"
        .Range("BL3:BR3").AutoFill Destination:=.Range("BL3:BR" & lastrow)

        ' sup code sup name
        .Range("BT3").Formula = "=XLOOKUP(B3,'[" & pricelog & "]cost'!$E:$E,'[" & pricelog & "]cost'!$N:$N,"""")"
        .Range("BS3").Formula = "=XLOOKUP(B3,'[" & pricelog & "]cost'!$E:$E,'[" & pricelog & "]cost'!$M:$M,"""")"
        .Range("BS3:CB3").AutoFill Destination:=.Range("BS3:CB" & lastrow)

        ' Contribution
        .Range("CA3").Formula = "=Distribution('[" & pricelog & "]Sales Mix'!$A:$I,'[" & pricelog & "]Sales Mix'!$A:$A,'[" & pricelog & "]Sales Mix'!$1:$1,B3,AV3)"
        lastCol = Split(.Cells(2, .Columns.Count).End(xlToLeft).Address, "$")(1)

        .Range("BU3:" & lastCol & "3").AutoFill Destination:=.Range("BU3:" & lastCol & lastrow)
        .Range("A3:" & lastCol & "3").AutoFill Destination:=.Range("A3:" & lastCol & lastrow), Type:=xlFillFormats

        ' »Ô´ÅÔ§¡ì
        breaklink

        ' »Ô´ Outline ãËé´Ù§èÒÂ
        .Outline.ShowLevels RowLevels:=0, ColumnLevels:=1
    End With

    ' ¡ÅÑºä»·Õè B2
    ob.Sheets("Sheet0").Range("B2").Select

    MsgBox "Update Done!", vbInformation
    Application.ScreenUpdating = True
End Sub

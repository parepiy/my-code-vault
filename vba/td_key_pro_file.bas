Sub key_pro()
'save promotion key file in the same location
Dim wbSrc As Workbook, wbTmp As Workbook
Dim wsSrc As Worksheet, wsTmp As Worksheet
Dim fileName As String
Dim firstRow As Long, lastRow As Long
Dim rngHeader As Range, cell As Range
Dim templatePath As String, savePath As String

Application.ScreenUpdating = False
Application.DisplayAlerts = False

    On Error GoTo CleanUp
    
    Set wbSrc = ActiveWorkbook
    Set wsSrc = wbSrc.ActiveSheet
    
    Call breaklink
    
    fileName = Left(wbSrc.Name, InStrRev(wbSrc.Name, ".") - 1)
    With wsSrc
        .Cells.UnMerge
        .Cells.EntireColumn.Hidden = False
        .AutoFilterMode = False
        .UsedRange.value = .UsedRange.value
    End With
    
    templatePath = "C:\Users\piyathida.pi\Documents\Custom Office Templates\Book.xltx"
    Set wbTmp = Workbooks.Open(templatePath)
    Set wsTmp = wbTmp.Worksheets(1)
    wsSrc.UsedRange.Copy
    wsTmp.Range("A1").PasteSpecial xlPasteAll
    wbSrc.Close False
    
    With wsTmp
        lastRow = .Cells(.Rows.Count, "I").End(xlUp).Row
        If .Cells(lastRow, "I").value = "*" Then .Rows(lastRow).Delete
        
        lastRow = .Cells(.Rows.Count, "I").End(xlUp).Row
        firstRow = .Cells(lastRow, "I").End(xlUp).Row
        If firstRow > 1 Then .Rows("1:" & firstRow - 1).Delete
        Set rngHeader = .Range("A1:CC1")
        .Range("A1").value = "Remark"
        
        With .Rows(1)
            .Replace "(¡ÃÍ¡)", "", xlPart
            .Replace "(¤ÅÔ¡àÅ×Í¡)", "", xlPart
            .Replace "(Text)", "", xlPart
        End With
    End With
    
    For Each cell In rngHeader
        If Left(cell.value, 6) = "TD WSP" Then cell.value = "TD WSP (In-vat)"
        cell.value = Replace(cell.value, vbLf, "")
    Next cell
    savePath = "D:\OneDrive\OneDrive - cjmart\Pare\Raw Data\key_promotion\"
    wbTmp.SaveAs savePath & fileName & ".xlsx", FileFormat:=xlOpenXMLWorkbook
    
CleanUp:
Application.ScreenUpdating = True
Application.DisplayAlerts = True
End Sub

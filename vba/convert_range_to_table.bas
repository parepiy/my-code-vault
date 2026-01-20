Sub convert_to_table()
'
' convert_to_table Macro
'convert sheet range to table, loop through every sheets

'
Dim i As Integer
Dim ws As Worksheet
Dim sh As Integer

sh = ActiveWorkbook.Sheets.Count
For Each ws In ActiveWorkbook.Worksheets
    Application.CutCopyMode = False
    ws.Activate
    ActiveSheet.AutoFilterMode = False
    If ws.ListObjects.Count = 0 Then
    ActiveSheet.ListObjects.Add(xlSrcRange, Range("A1", Range("A1").End(xlToRight).End(xlDown)), , xlYes).Name _
    = "table_" & ActiveSheet.Name
    Else
        ws.ListObjects(1).Name = "table_" & ActiveSheet.Name
    End If
    Range("c1").Value = "article_no"
    Range("c2").Value = ActiveSheet.Name
    Range("c2").Select
    Selection.AutoFill Destination:=Range("c2:c" & Range("A" & Rows.Count).End(xlUp).Row), Type:=xlFillCopy
Next ws
MsgBox "Total Sheets of " & sh
End Sub

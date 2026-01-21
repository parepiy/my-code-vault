'how to use
'call ClearTable("Sheet1","Table1")
'ClearTable "Sheet1", "Table1"
Sub ClearTable(sheetName As String, tableName As String)
    Dim tbl As ListObject
    Dim ws As Worksheet

    Set ws = ThisWorkbook.Sheets(sheetName)
    Set tbl = ws.ListObjects(tableName)

    If Not tbl.DataBodyRange Is Nothing Then
        tbl.DataBodyRange.Delete
    End If
End Sub

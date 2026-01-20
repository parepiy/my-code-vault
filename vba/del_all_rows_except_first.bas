Sub DeleteAllRowsExceptOne()
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim lastrow As ListRow
    
    ' Set the worksheet and table
    Set ws = ActiveWorkbook.Sheets("Admin") ' Change "Sheet1" to your sheet name
    Set tbl = ws.ListObjects("Table1") ' Change "Table1" to your table name
    
    ' Check if the table has more than one row
    If tbl.ListRows.Count > 1 Then
        ' Delete all rows except the first one
        tbl.DataBodyRange.Offset(1, 0).Resize(tbl.ListRows.Count - 1).Rows.Delete
    End If
    
    ' Clear the contents of the remaining row
    tbl.ListRows(1).Range.ClearContents
End Sub

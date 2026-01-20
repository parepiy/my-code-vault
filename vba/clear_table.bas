Sub Clear_table7()
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim lastrow As ListRow
    
    ' Set the worksheet and table
    Set ws = ActiveWorkbook.Sheets("Price Change") ' Change "Sheet1" to your sheet name
    Set tbl = ws.ListObjects("Table7") ' Change "Table1" to your table name
    
    ' Check if the table has more than one row
    If tbl.ListRows.Count > 1 Then
        ' Delete all rows except the first one
        tbl.DataBodyRange.Offset(1, 0).Resize(tbl.ListRows.Count - 1).Rows.Delete
    End If
End Sub

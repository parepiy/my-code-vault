Function PrepareLogSheet() As Worksheet

    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ActiveWorkbook.Worksheets("Download_Log")
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ActiveWorkbook.Worksheets.Add
        ws.Name = "Download_Log"
        ws.Range("A1:C1").Value = Array("Row", "URL", "Reason")
    Else
        ws.Cells.Clear
        ws.Range("A1:C1").Value = Array("Row", "URL", "Reason")
    End If

    Set PrepareLogSheet = ws
End Function

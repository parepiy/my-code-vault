Sub UnhideAllWorksheet()
Dim ws As Worksheet
    For Each ws In ActiveWorkbook.Worksheets
        On Error Resume Next
        ws.Visible = xlSheetVisible
        On Error GoTo 0
    Next ws
End Sub

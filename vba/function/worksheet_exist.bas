Function WorksheetExists(wsName As String, wb As Workbook) As Boolean
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = wb.Worksheets(wsName)
    On Error GoTo 0

    WorksheetExists = Not ws Is Nothing
End Function

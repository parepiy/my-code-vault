Sub save_new_file()
    Dim wb As Workbook
    Dim ws As Worksheet
    Dim pq As Object
    Dim fileName As String, fileCode As String
    Dim savePath As String

    Set wb = ActiveWorkbook
    savePath = "D:\OneDrive\OneDrive - cjmart\Pare\Raw Data\Request\"

    Application.DisplayAlerts = False
    Application.ScreenUpdating = False
    On Error GoTo CleanUp

    fileName = Trim(InputBox("Input File Name", "File Name"))
    If fileName = "" Then GoTo CleanUp

    fileCode = Format(Date, "yyyymmdd")

    ' del Power Queries
    For Each pq In wb.Queries
        pq.Delete
    Next pq

    ' loop sheet in reverse (safe)
    Dim i As Long
    For i = wb.Worksheets.Count To 1 Step -1
        Set ws = wb.Worksheets(i)

        If ws.Name = "Admin" Then
            ws.Delete
        Else
            With ws.UsedRange
                .value = .value
            End With
        End If
    Next i

    wb.SaveAs _
        fileName:=savePath & fileName & "_" & fileCode & ".xlsx", _
        FileFormat:=xlOpenXMLWorkbook

    Shell "explorer.exe /select,""" & _
          savePath & fileName & "_" & fileCode & ".xlsx""", vbNormalFocus

CleanUp:
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True
End Sub

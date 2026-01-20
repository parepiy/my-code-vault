Sub DownloadAndSaveImages()
    Dim ws As Worksheet
    Dim logWs As Worksheet
    Dim i As Long, lastrow As Long
    Dim imgURL As String, imgName As String
    Dim savePath As String, ext As String
    Dim http As Object
    Dim byteData() As Byte
    Dim fileNum As Integer
    Dim successCnt As Long, failCnt As Long
    
    If ActiveWorkbook.Path = "" Then
        MsgBox "Please save the workbook first.", vbCritical
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    Application.StatusBar = "Preparing download..."

    Set ws = ActiveWorkbook.Sheets(1) ' »ÃÑºª×èÍªÕ·ËÒ¡µéÍ§¡ÒÃ
    lastrow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    savePath = ActiveWorkbook.Path & "\" ' à«¿ã¹â¿Åà´ÍÃìà´ÕÂÇ¡Ñºä¿Åì Excel
    
    If Dir(savePath, vbDirectory) = "" Then MkDir savePath
    
    Set logWs = PrepareLogSheet

    For i = 2 To lastrow
        imgName = Trim(ws.Cells(i, "A").Value)
        imgURL = Trim(ws.Cells(i, "B").Value)
        
        Application.StatusBar = "Downloading " & i - 1 & " / " & lastrow - 1
        
        If imgName = "" Or imgURL = "" Then
            LogFail logWs, i, imgURL, "Missing name or URL"
            failCnt = failCnt + 1
            GoTo NextRow
        End If
        
        ext = GetFileExtension(imgURL)
        If ext = "" Then ext = "jpg"
        
        If Not DownloadImage(imgURL, savePath & CleanFileName(imgName) & "." & ext) Then
            LogFail logWs, i, imgURL, "Download Faild"
            failCnt = failCnt + 1
        Else
            successCnt = successCnt + 1
        End If
            
NextRow:
        DoEvents
    Next i
    Application.StatusBar = False
    Application.ScreenUpdating = True
    
    MsgBox "Completed!" & vbCrLf & _
                "Success: " & successCnt & vbCrLf & _
                "Failed: " & failCnt, vbInformation
                
End Sub

Sub LogFail(ws As Worksheet, rowNum As Long, url As String, reason As String)
    Dim r As Long
    r = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row + 1
    ws.Cells(r, 1).Value = rowNum
    ws.Cells(r, 2).Value = url
    ws.Cells(r, 3).Value = reason
End Sub

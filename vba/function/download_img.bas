Function DownloadImage(url As String, fullPath As String) As Boolean

    Dim http As Object
    Dim byteData() As Byte
    Dim fileNum As Integer
    Dim attempt As Integer

    For attempt = 1 To 3   ' retry 3 times

        Set http = CreateObject("MSXML2.ServerXMLHTTP")
        On Error GoTo Retry

        http.Open "GET", url, False
        http.setTimeouts 5000, 5000, 5000, 5000
        http.Send

        If http.Status = 200 Then
            byteData = http.responseBody
            fileNum = FreeFile
            Open fullPath For Binary As #fileNum
            Put #fileNum, , byteData
            Close #fileNum
            DownloadImage = True
            Exit Function
        End If

Retry:
        Set http = Nothing
        On Error GoTo 0
        DoEvents
    Next attempt

    DownloadImage = False
End Function

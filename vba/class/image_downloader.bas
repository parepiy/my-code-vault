Private pUrl As String
Private pSavePath As String
Private pRetry As Integer
Private pTimeout As Long

Public Property Let Url(value As String)
    pUrl = value
End Property

Public Property Get Url() As String
    Url = pUrl
End Property
Public Property Let SavePath(value As String)
    pSavePath = value
End Property

Public Property Get SavePath() As String
    SavePath = pSavePath
End Property
Public Property Let Retry(value As String)
    pRetry = value
End Property

Public Property Get Retry() As String
    Retry = pRetry
End Property
Public Property Let Timeout(value As String)
    pTimeout = value
End Property

Public Property Get Timeout() As String
    Timeout = pTimeout
End Property

Public Function Download() As Boolean
    Dim http As Object
    Dim i As Integer

    For i = 1 To pRetry
        Set http = CreateObject("MSXML2.ServerXMLHTTP")
        http.setTimeouts pTimeout, pTimeout, pTimeout, pTimeout

        On Error Resume Next
        http.Open "GET", pUrl, False
        http.Send

        If http.Status = 200 Then
            SaveBinary http.responseBody
            Download = True
            Exit Function
        End If
        On Error GoTo 0
    Next i
End Function

Private Sub SaveBinary(data As Variant)
    Dim f As Integer
    f = FreeFile
    Open pSavePath For Binary As #f
    Put #f, , data
    Close #f
End Sub

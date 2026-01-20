Function GetFileExtension(url As String) As String
    Dim tmp As String
    tmp = Split(url, "?")(0)
    If InStr(tmp, ".") > 0 Then
        GetFileExtension = LCase(Mid(tmp, InStrRev(tmp, ".") + 1))
    End If
End Function

Function ConvertSharePointPathToLocal(ByVal fullPath As String) As String
    Dim sharePointPrefix As String
    Dim localPrefix As String

    sharePointPrefix = "https://cjmart-my.sharepoint.com/personal/piyathida_pi_cjmart_co_th/Documents"
    localPrefix = "D:\OneDrive\OneDrive - cjmart"

    ' if SharePoint URL
    If LCase(fullPath) Like "https://*" Then
        If InStr(1, fullPath, sharePointPrefix, vbTextCompare) > 0 Then
            ConvertSharePointPathToLocal = Replace( _
                Replace(fullPath, sharePointPrefix, localPrefix, , , vbTextCompare), _
                "/", "\")
        Else
            ConvertSharePointPathToLocal = ""
        End If
    Else
        ' already local
        ConvertSharePointPathToLocal = fullPath
    End If
End Function

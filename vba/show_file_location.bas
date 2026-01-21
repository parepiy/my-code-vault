'use with convert sharepoint to local function
Sub ShowFileLocation()
    Dim wb As Workbook
    Dim filePath As String
    Dim localPath As String
    Dim response As VbMsgBoxResult

    Set wb = ActiveWorkbook

    ' check save
    If wb.Path = "" Then
        MsgBox "This workbook has not been saved yet.", vbExclamation
        Exit Sub
    End If

    filePath = wb.FullName
    localPath = ConvertSharePointPathToLocal(filePath)

    If localPath = "" Then
        MsgBox "Cannot resolve local file path.", vbCritical
        Exit Sub
    End If

    response = MsgBox( _
        "File location:" & vbCrLf & _
        localPath & vbCrLf & vbCrLf & _
        "Open file location?", _
        vbQuestion + vbYesNo, _
        "File Location")

    If response = vbYes Then
        Shell "explorer.exe /select,""" & localPath & """", vbNormalFocus
    End If
End Sub

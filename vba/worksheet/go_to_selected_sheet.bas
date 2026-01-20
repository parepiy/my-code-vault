Private Sub Worksheet_Change(ByVal Target As Range)
Dim sh As Worksheet
If Not Intersect(Target, Me.Range("N5")) Is Nothing Then
    On Error GoTo mss
    Set sh = Worksheets(Range("N5").Value)
    If sh.Visible = xlSheetHidden Or sh.Visible = xlSheetVeryHidden Then
        sh.Visible = xlSheetVisible
        sh.Select
    Else
        sh.Select
    End If
    Exit Sub
mss:
    MsgBox "Sheet " & Range("N5").Value & " is not available."
End If
End Sub

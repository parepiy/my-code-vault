Sub hide_sheet()
    Dim ws As Worksheet
    Dim mode As XlSheetVisibility

    Set ws = ActiveSheet

    If MsgBox("Hide sheet as Very Hidden?" & vbCrLf & _
              "Yes = Very Hidden" & vbCrLf & _
              "No = Hidden", _
              vbQuestion + vbYesNo) = vbYes Then
        mode = xlVeryHidden
    Else
        mode = xlHidden
    End If

    ws.Visible = mode
End Sub

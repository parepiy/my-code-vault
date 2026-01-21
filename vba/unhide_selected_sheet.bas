Sub UnhideSelectedSheets()
    Dim ws As Worksheet
    Dim hiddenSheets As Collection
    Dim sheetList As String
    Dim i As Long, idx As Long
    Dim userInput As String
    Dim selections() As String
    Dim invalidItems As String

    Set hiddenSheets = New Collection
    sheetList = "Hidden Sheets List:" & vbCrLf

    ' à¡çºªÕ··Õè Hidden ËÃ×Í VeryHidden
    For Each ws In ActiveWorkbook.Worksheets
        If ws.Visible <> xlSheetVisible Then
            hiddenSheets.Add ws
            sheetList = sheetList & hiddenSheets.Count & ". " & ws.Name & vbCrLf
        End If
    Next ws

    ' ¶éÒäÁèÁÕªÕ·«èÍ¹ÍÂÙè
    If hiddenSheets.Count = 0 Then
        MsgBox "No hidden sheets found.", vbInformation
        Exit Sub
    End If

    ' áÊ´§ MsgBox ÃÒÂª×èÍ¡èÍ¹
    MsgBox sheetList, vbInformation, "Hidden Sheets"

    ' ÃÑºÍÔ¹¾Øµ¨Ò¡¼Ùéãªé
    userInput = InputBox("Input sheet numbers to unhide (ex: 1,3):", "Unhide Sheets")
    If Trim(userInput) = "" Then Exit Sub

    selections = Split(userInput, ",")

    For i = LBound(selections) To UBound(selections)
        If IsNumeric(Trim(selections(i))) Then
            idx = CLng(Trim(selections(i)))
            If idx >= 1 And idx <= hiddenSheets.Count Then
                hiddenSheets(idx).Visible = xlSheetVisible
            Else
                invalidItems = invalidItems & selections(i) & ", "
            End If
        Else
            invalidItems = invalidItems & selections(i) & ", "
        End If
    Next i
    
    If invalidItems <> "" Then
        MsgBox "Some inputs were invalid: " & Left(invalidItems, Len(invalidItems) - 2), vbExclamation
    Else
        MsgBox "Selected sheets are unhidden.", vbInformation
    End If
End Sub

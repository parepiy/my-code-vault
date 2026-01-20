Sub highlight()
'
' highlight Macro
'highlight entire row from the first column to last
' Keyboard Shortcut: Ctrl+d
'
Dim headerFirstCol As Long
Dim headerLastCol As Long
Dim rowNum As Long
Dim c As Long

    Application.CutCopyMode = False

    ' find first col that has data
    headerFirstCol = 0
    For c = 1 To Columns.Count
        If Not IsEmpty(Cells(1, c)) Then
            headerFirstCol = c
            Exit For
        End If
    Next c

    ' if not found show msgbox
    If headerFirstCol = 0 Then
        MsgBox "äÁè¾ºËÑÇµÒÃÒ§ã¹á¶Ç 1", vbExclamation
        Exit Sub
    End If

    ' find last col
    headerLastCol = Cells(1, Columns.Count).End(xlToLeft).Column

    ' active row
    rowNum = ActiveCell.Row

    ' hightlight entire row
    Range(Cells(rowNum, headerFirstCol), Cells(rowNum, headerLastCol)).Interior.Color = 14614168

    ' shift cursor down 1 row
    Cells(rowNum + 1, ActiveCell.Column).Select
End Sub

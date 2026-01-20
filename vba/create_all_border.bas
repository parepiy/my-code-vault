Sub border()
'
' border Macro
'

'Select first cell you want to create border first
Dim rng As Range
Dim b as Variant

    Set rng = Range(ActiveCell, ActiveCell.End(xlToRight).End(xlDown))
    rng.Select
    ' ลบเส้นทะแยง
    rng.Borders(xlDiagonalDown).LineStyle = xlNone
    rng.Borders(xlDiagonalUp).LineStyle = xlNone

    ' create border
    For Each b In Array( _
        xlEdgeLeft, xlEdgeTop, xlEdgeBottom, xlEdgeRight, _
        xlInsideVertical, xlInsideHorizontal)

        With rng.Borders(b)
            .LineStyle = xlContinuous
            .ColorIndex = 0
            .Weight = xlThin
        End With
    Next b
End Sub

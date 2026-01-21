Sub A_SelectAllMakeTable2()
    Dim ws As Worksheet
    Dim rng As Range

    For Each ws In ActiveWorkbook.Worksheets

        ' ข้ามชีทที่มี table อยู่แล้ว
        If ws.ListObjects.Count > 0 Then GoTo NextSheet

        ' เช็กว่า A1 มีข้อมูล
        If Trim(ws.Range("A1").value) = "" Then GoTo NextSheet

        Set rng = ws.Range("A1").CurrentRegion

        ' อย่างน้อยต้องมากกว่า 1 แถว
        If rng.Rows.Count < 2 Then GoTo NextSheet

        ws.ListObjects.Add(xlSrcRange, rng, , xlYes).TableStyle = "TableStyleMedium15"

NextSheet:
    Next ws
End Sub

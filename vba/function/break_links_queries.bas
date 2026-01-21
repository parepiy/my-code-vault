Function CleanWorkbookLinksAndQueries(wb As Workbook) As Long
    Dim linkType As Variant
    Dim link As Variant
    Dim q As Object
    Dim conn As Object
    Dim removedCount As Long

    Application.DisplayAlerts = False
    On Error Resume Next

    ' ===== 1. Break External Links =====
    For Each linkType In Array( _
            xlLinkTypeExcelLinks, _
            xlOLELinks, _
            xlPublishers, _
            xlSubscribers)

        If Not IsEmpty(wb.LinkSources(Type:=linkType)) Then
            For Each link In wb.LinkSources(Type:=linkType)
                wb.BreakLink Name:=link, Type:=linkType
                removedCount = removedCount + 1
            Next link
        End If
    Next linkType

    ' ===== 2. Remove Power Queries =====
    For Each q In wb.Queries
        q.Delete
        removedCount = removedCount + 1
    Next q

    ' ===== 3. Remove Workbook Connections =====
    For Each conn In wb.Connections
        conn.Delete
        removedCount = removedCount + 1
    Next conn

    On Error GoTo 0
    Application.DisplayAlerts = True

    CleanWorkbookLinksAndQueries = removedCount
End Function

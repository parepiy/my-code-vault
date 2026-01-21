Sub LoopThroughFiles()
    Dim folderPath As String
    Dim fileName As String
    Dim wb As Workbook
    Dim ws As Worksheet
    Dim oldWord As String, newWord As String

    folderPath = "D:\KF Files\New Template Acc Files\"
    oldWord = "adj max cost"
    newWord = "product_tier"

    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual
    On Error GoTo CleanUp

    fileName = Dir(folderPath & "*.xls*")

    Do While fileName <> ""

        On Error Resume Next
        Set wb = Workbooks.Open(folderPath & fileName, UpdateLinks:=False)
        If wb Is Nothing Then
            On Error GoTo 0
            GoTo NextFile
        End If
        On Error GoTo 0

        For Each ws In wb.Worksheets
            If Not ws.UsedRange Is Nothing Then
                ws.UsedRange.Replace _
                    What:=oldWord, _
                    Replacement:=newWord, _
                    LookAt:=xlPart, _
                    MatchCase:=False
            End If
        Next ws

        wb.Close SaveChanges:=True

NextFile:
        Set wb = Nothing
        fileName = Dir
    Loop

CleanUp:
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.Calculation = xlCalculationAutomatic
End Sub

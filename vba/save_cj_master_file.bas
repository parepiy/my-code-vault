Sub cj_master_save()
Dim wb As Workbook: Set wb = ActiveWorkbook
Dim result As VbMsgBoxResult
Dim file_name As String, save_path As String, base_path As String

Application.ScreenUpdating = False

On Error GoTo CleanUp

result = MsgBox("Confirm to save CJ Master", vbOKCancel + vbQuestion, "Confirmation")
If result <> vbOK Then GoTo CleanUp

base_path = "D:\OneDrive\OneDrive - cjmart\CJ Data\cj master\"

Select Case True
    Case Left(wb.Name, 6) = "Status"
        save_path = base_path & "Status Master\"
        file_name = "Status Master "
    Case Left(wb.Name, 7) = "Article"
        save_path = base_path & "Article Master\"
        file_name = "Article Master "
    Case Left(wb.Name, 7) = "CJ_D002"
        save_path = base_path & "D002_Moving\"
        file_name = "CJ_D002_Moving_"
    Case Else
        MsgBox "Unkonw file type. Save cancelled.", vbCritical
        GoTo CleanUp
End Select

    file_name = save_path & file_name & Format(Now, "YYYYMMDD") & ".xlsx"
    wb.SaveAs file_name
    
    Shell "explorer.exe /select,""" & file_name & """", vbNormalFocus
    
CleanUp:
Application.ScreenUpdating = True
End Sub

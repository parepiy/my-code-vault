file_name = save_path & file_name & Format(Now, "YYYYMMDD") & ".xlsx"
wb.SaveAs file_name

Shell "explorer.exe /select,""" & file_name & """", vbNormalFocus

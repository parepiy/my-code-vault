'Pick A File to Add via Dialog (PNG or JPG)
 With Application.FileDialog(msoFileDialogFilePicker)
      .AllowMultiSelect = False
      .Title = "Select Comment Image"
      .ButtonName = "Insert Image"
      .Filters.Clear
      .Filters.Add "Images", "*.png; *.jpg"
      
      If .Show <> -1 Then Exit Sub
      PicturePath = .SelectedItems(1)
End With

'Application.FileDialog(type)
'msoFileDialogFilePicker >> choose file
'msoFileDialogFolderPicker >> choose folder
'msoFileDialogSaveAs >> save as
'msoFileDialogOpen >> open (similar to file picker but older)

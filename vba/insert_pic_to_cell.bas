Sub insert_pic()

'ctr + shift + i

Dim PicturePath As String
Dim CommentBox As Comment
Dim tgt As Range
Dim FixedWidth As Single

  FixedWidth = 150 'picture width (pt)
  Set tgt = ActiveCell

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

    tgt.ClearComments
    
    Set CommentBox = tgt.AddComment("")

    With CommentBox.Shape
        .Fill.UserPicture PicturePath
        .LockAspectRatio = True
        .Width = FixedWidth
    End With

  CommentBox.Visible = False
End Sub

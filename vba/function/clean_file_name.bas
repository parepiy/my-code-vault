Function CleanFileName(fname As String) As String
    Dim badChars As Variant, c As Variant
    badChars = Array("/", "\", ":", "*", "?", """", "<", ">", "|")
    For Each c In badChars
        fname = Replace(fname, c, "_")
    Next
    CleanFileName = fname
End Function

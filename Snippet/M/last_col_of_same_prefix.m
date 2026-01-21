POGCols = List.Select(Cols, each Text.StartsWith(_, "POG Store")),
LastPOG = if List.Count(POGCols) > 0 then List.Last(POGCols) else null,

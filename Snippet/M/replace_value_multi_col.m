//list col with numbers data
NumCols =
    List.Select(
        Table.ColumnNames(Dedup),
        each _ = "Sales Store" or Text.StartsWith(_, "ROS") or Text.StartsWith(_, "POG")
    ),
//replace - with actual 0
FixNumbers =
    Table.TransformColumns(
        Dedup,
        List.Transform(
            NumCols,
            each {
                _,
                (v) =>
                    try
                        Number.FromText(
                            Text.Replace(Text.Trim(Text.From(v)), "-", "0")
                        )
                    otherwise
                        0,
                type number
            }
        )
    )

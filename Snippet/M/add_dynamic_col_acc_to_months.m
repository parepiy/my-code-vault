AllCols = Table.ColumnNames(Sorted),

Months =
    List.Transform(
        List.Select(AllCols, each Text.StartsWith(_, "ROS QTY ")),
        each Text.AfterDelimiter(_, "ROS QTY ")
    ),

AddTTL =
    (tbl as table, rosPrefix as text, ttlPrefix as text) =>
        List.Accumulate(
            Months,
            tbl,
            (t, m) =>
                let
                    rosCol = rosPrefix & " " & m,
                    pogCol = "POG Store " & m,
                    ttlCol = ttlPrefix & "_" & Text.Upper(m) & "_25",
                    ok =
                        List.Contains(Table.ColumnNames(t), rosCol)
                        and List.Contains(Table.ColumnNames(t), pogCol)
                in
                    if ok then
                        Table.AddColumn(
                            t,
                            ttlCol,
                            each Record.Field(_, rosCol) * Record.Field(_, pogCol),
                            type number
                        )
                    else
                        t
        ),

WithTTLQty = AddTTL(Sorted, "ROS QTY", "TTL_QTY"),
WithTTLAmt = AddTTL(WithTTLQty, "ROS AMT", "TTL_AMT"),

NumCols =
    List.Select(
        Table.ColumnNames(Dedup),
        each _ = "Sales Store" or Text.StartsWith(_, "ROS") or Text.StartsWith(_, "POG")
    ),
// keep col begin with ROS or POG and col Sales Store

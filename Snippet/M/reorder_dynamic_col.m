fixed_col1 = {
    "CJX Division","Product","Product Name","Category Name","Sub Category Name",
    "Supplier","Supplier Name","Old Status","Tax",
    "GTIN(S)","GTIN(M)","GTIN(L)",
    "Sales price (S)","Sales price (M)","Sales price (L)",
    "UOM(S)","UOM(M)","UOM(L)",
    "Fact.S","Fact.M","Fact.L",
    "shelf_life","min_shelf_life",
    "Net Cost Base Unit inc.VAT","%GP โครงสร้าง","%Back by Sup","RSP inc.VAT",
    "pick.AUN","pick.NUMER#","Sales Store"
},

fixed_col2 = {
    "DC1_ScmAssort","DC1_DCStockQty","DC1_DOHDC",
    "DC2_ScmAssort","DC2_DCStockQty","DC2_DOHDC"
},

fixed_col3 = {"cjx_assort"},

Cols = Table.ColumnNames(AddedAssort),

POGCols = List.Select(Cols, each Text.StartsWith(_, "POG Store")),
LastPOG = if List.Count(POGCols) > 0 then List.Last(POGCols) else null,

ros_qty = List.Select(Cols, each Text.StartsWith(_, "ROS QTY")),
ros_amt = List.Select(Cols, each Text.StartsWith(_, "ROS AMT")),
ttl_qty = List.Select(Cols, each Text.StartsWith(_, "TTL_QTY")),
ttl_amt = List.Select(Cols, each Text.StartsWith(_, "TTL_AMT")),

other_cols =
    List.Difference(
        Cols,
        fixed_col1 & fixed_col2 & fixed_col3 & ros_qty & ros_amt & ttl_qty & ttl_amt & {LastPOG}
    ),

FinalOrder =
    List.RemoveNulls(
        fixed_col1 & {LastPOG} & fixed_col2 &
        ros_qty & ros_amt & ttl_qty & ttl_amt &
        fixed_col3 & other_cols
    ),

Result = Table.ReorderColumns(AddedAssort, FinalOrder)

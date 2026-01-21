let
// =====================================================
// LOAD
// =====================================================
FilePath = Excel.CurrentWorkbook(){[Name="master_sku"]}[Content]{0}[Column1],
Source = Excel.Workbook(File.Contents(FilePath), null, true),
Filtered = Table.SelectRows(Source, each Text.EndsWith([Name], "2025")),
FirstTable = Filtered[Data]{0},
Expanded = Table.ExpandTableColumn(Filtered, "Data", Table.ColumnNames(FirstTable)),
RemovedName = Table.RemoveColumns(Expanded, {"Name"}),
SkippedTop = Table.Skip(RemovedName, 1),
Promoted = Table.PromoteHeaders(SkippedTop, [PromoteAllScalars=true]),

// =====================================================
// BASIC CLEAN
// =====================================================
RemovedCols =
    Table.RemoveColumns(
        Promoted,
        {"DIVISION Name", "Category", "Sub Category", "Status"}
    ),
Dedup = Table.Distinct(RemovedCols, {"Product"}),

// =====================================================
// SAFE NUMBER FIX
// =====================================================
NumCols =
    List.Select(
        Table.ColumnNames(Dedup),
        each _ = "Sales Store" or Text.StartsWith(_, "ROS") or Text.StartsWith(_, "POG")
    ),

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
    ),

Sorted = Table.Sort(FixNumbers, {{"Product", Order.Ascending}}),

// =====================================================
// AUTO TTL (QTY / AMT) — detects months dynamically
// =====================================================
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

// =====================================================
// TYPE FIX (CORE)
// =====================================================
ChangedType =
    Table.TransformColumnTypes(
        WithTTLAmt,
        {
            {"First Sales Date", type date},
            {"Sales price (S)", type number},
            {"Sales price (M)", type number},
            {"Sales price (L)", type number},
            {"Fact.S", type number},
            {"Fact.M", type number},
            {"Fact.L", type number},
            {"RSP inc.VAT", type number},
            {"%GP โครงสร้าง", Percentage.Type},
            {"%Back by Sup", Percentage.Type},
            {"Net Cost Base Unit inc.VAT", type number},
            {"Sales Store", type number},
            {"Unit Factor RSP", Int64.Type}
        }
    ),

// =====================================================
// MERGE STATUS
// =====================================================
StatusBuff = Table.Buffer(status),
MergedStatus =
    Table.NestedJoin(
        ChangedType,
        {"Product"},
        StatusBuff,
        {"Article Number"},
        "Status",
        JoinKind.LeftOuter
    ),
ExpandedStatus = Table.ExpandTableColumn(MergedStatus, "Status", {"Old Status"}),

FilteredStatus =
    Table.SelectRows(
        ExpandedStatus,
        each
            [Old Status] <> "TD"
            and not Text.StartsWith([Old Status], "C")
            and not Text.StartsWith([Old Status], "S")
            and not Text.StartsWith([Old Status], "PM")
            and [Old Status] <> "OLC"
            and [Old Status] <> "D"
    ),

// =====================================================
// MERGE SHELF LIFE
// =====================================================
MergedShelf =
    Table.NestedJoin(FilteredStatus, {"Product"}, shelf_life, {"ARTICLE NUMBER"}, "shelf", JoinKind.LeftOuter),
ExpandedShelf =
    Table.ExpandTableColumn(MergedShelf, "shelf", {" อายุก่อนรับเข้าคลัง", "อายุสินค้าเต็ม"}, {"min_shelf_life", "shelf_life"}),

// =====================================================
// MERGE PICKING
// =====================================================
PickingBuff = Table.Buffer(cj_picking),
MergedPicking =
    Table.NestedJoin(
        ExpandedShelf,
        {"Product"},
        PickingBuff,
        {"ARTICLE NUMBER"},
        "Picking",
        JoinKind.LeftOuter
    ),
ExpandedPicking =
    Table.ExpandTableColumn(
        MergedPicking,
        "Picking",
        {"AUN", "NUMER#"},
        {"pick.AUN", "pick.NUMER#"}
    ),

// =====================================================
// MERGE DC1 / DC2
// =====================================================
MergedDC1 =
    Table.NestedJoin(
        ExpandedPicking,
        {"Product"},
        #"CJX DC1 Report",
        {"Product"},
        "DC1",
        JoinKind.LeftOuter
    ),
ExpandedDC1 =
    Table.ExpandTableColumn(
        MergedDC1,
        "DC1",
        {"DC1_ScmAssort", "DC1_DCStockQty", "DC1_DOHDC"}
    ),

MergedDC2 =
    Table.NestedJoin(
        ExpandedDC1,
        {"Product"},
        #"CJX DC2 Report",
        {"Product"},
        "DC2",
        JoinKind.LeftOuter
    ),
ExpandedDC2 =
    Table.ExpandTableColumn(
        MergedDC2,
        "DC2",
        {"DC2_ScmAssort", "DC2_DCStockQty", "DC2_DOHDC"}
    ),

// =====================================================
// MERGE DIVISION / ACTIVE STORE
// =====================================================
MergedDiv =
    Table.NestedJoin(ExpandedDC2, {"Product"}, cjx_division, {"ARTICLE NUMBER"}, "Division", JoinKind.LeftOuter),
ExpandedDiv = Table.ExpandTableColumn(MergedDiv, "Division", {"CJX Division"}),

MergedActive =
    Table.NestedJoin(
        ExpandedDiv,
        {"Product"},
        cjx_active_store,
        {"article_no"},
        "active",
        JoinKind.LeftOuter
    ),
ExpandedActive = Table.ExpandTableColumn(MergedActive, "active", {"active_store"}),
FilledActive = Table.ReplaceValue(ExpandedActive, null, 0, Replacer.ReplaceValue, {"active_store"}),
AddedAssort =
    Table.AddColumn(
        FilledActive,
        "cjx_assort",
        each if [active_store] > 0 then "Yes" else "No"
    ),

// =====================================================
// REORDER (DYNAMIC + SAFE)
// =====================================================
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

in
Result

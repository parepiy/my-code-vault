// as a function
(header as text) as text =>
let
    t1 = Text.Replace(header, Character.FromNumber(160), " "),
    t2 = Text.Clean(t1),
    t3 = Text.Trim(t2),
    t4 = Text.Combine(
            List.Select(
                Text.SplitAny(t3, " "),
                each _ <> ""
            ),
            " "
         )
in
    t4

= Table.TransformColumnNames(PreviousStep, CleanHeaderFunction)

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

////
AddTTL =
    (tbl as table, rosPrefix as text, ttlPrefix as text) =>
คือ การประกาศ function ใน M language  "FunctionName = (param1, param2, ...) => expression"

////
List.Accumulate(
    Months,
    tbl,
    (t, m) =>
        ...
)
ความหมายแบบคน
“วน list Months ทีละค่า
เอา table เดิมมาแก้
แล้วส่ง table ใหม่กลับไปใช้รอบถัดไป”

โครงสร้าง List.Accumulate
List.Accumulate(
    list,        // list ที่จะ loop
    seed,        // ค่าเริ่มต้น
    accumulator  // function ที่ใช้สะสมค่า
)

////
(t, m) =>  คือ anonymous function (function ที่ไม่มีชื่อ)
t = accumulator (ค่าที่สะสมอยู่ตอนนี้)
m = current (element ปัจจุบันจาก months)
แปลเป็นภาษาคน
รอบแรก:
  t = tbl
  m = "Jan"
รอบสอง:
  t = table ที่มี TTL_JAN แล้ว
  m = "Feb"

👉 t เปลี่ยนค่าไปเรื่อย ๆ
👉 m คือเดือนปัจจุบัน

////
let ... in ... คือ expression block

“ประกาศตัวแปรหลายตัว
แล้วคืนค่า ‘ตัวเดียว’ จาก in”

let ช่วยอะไร
  แยก logic เป็นชื่อที่มีความหมาย
  ลด duplication
  อ่านรู้เรื่องทันที

กฎเหล็กของ let
  ตัวแปรทุกตัว
    ประกาศได้
    อ้างถึงกันได้
  ไม่มี return
  ค่าที่ function ส่งออกมา =
    👉 expression หลัง in เท่านั้น




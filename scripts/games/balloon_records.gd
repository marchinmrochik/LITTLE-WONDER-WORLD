class_name BalloonRecords
extends RefCounted
static var storage_path := "user://balloon_records.json"
static func valid(value: Dictionary) -> bool:
 if value.get("version")!=1 or not value.get("runs") is Array or value.runs.size()>30:return false
 for row: Variant in value.runs:
  if not row is Dictionary or row.get("difficulty","") not in ["easy","normal","advanced"]:return false
  for key: String in ["score","created"]:
   var n: Variant=row.get(key)
   if not (n is int or n is float) or not is_finite(float(n)) or n<0 or n!=floor(n):return false
  if row.score>10000:return false
 return true
static func load_runs() -> Array:
 return JsonStore.read_document(storage_path,valid).document.get("runs",[])
static func record(score: int,difficulty: String) -> bool:
 var read := JsonStore.read_document(storage_path,valid)
 if read.status=="incompatible":return false
 var rows: Array=read.document.get("runs",[])
 rows.append({"score":score,"difficulty":difficulty,"created":int(Time.get_unix_time_from_system())})
 rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:return a.score>b.score if a.score!=b.score else a.created>b.created)
 var counts := {};var kept: Array=[]
 for row: Dictionary in rows:
  counts[row.difficulty]=int(counts.get(row.difficulty,0))+1
  if counts[row.difficulty]<=10:kept.append(row)
 return JsonStore.write_document(storage_path,{"version":1,"runs":kept},valid)==OK
static func top(difficulty: String) -> Array:
 return load_runs().filter(func(row: Dictionary) -> bool:return row.difficulty==difficulty)

extends Node
signal changed
signal storage_failed
const LIMIT := 100
var storage_path := "user://assessment_history.json"
var document: Dictionary={"version":1,"sessions":[]}
var load_status := "new"
var last_save_error: Error=OK

func _ready() -> void: reload()
func reload() -> void:
	var result := JsonStore.read_document(storage_path,valid_document)
	load_status=result.status
	document={"version":1,"sessions":[]} if result.document.is_empty() else result.document
	last_save_error=OK

func valid_document(value: Dictionary) -> bool:
	if value.get("version")!=1 or not value.get("sessions") is Array or value.sessions.size()>LIMIT: return false
	var ids := {}
	for row: Variant in value.sessions:
		if not row is Dictionary: return false
		for key: String in ["id","topic","locale","difficulty","signature","started"]:
			if not row.get(key) is String or row[key].is_empty() or row[key].length()>240: return false
		if ids.has(row.id) or row.locale not in ["en","uk"] or row.difficulty not in ["easy","normal","advanced"] or row.get("status") not in ["active","interrupted","completed"]: return false
		var revision: Variant=row.get("revision")
		if not (revision is float or revision is int) or not is_finite(revision) or revision<1 or revision!=floor(revision) or row.get("mode")!="check":return false
		ids[row.id]=true
		if not row.get("items") is Array or row.items.size()!=5 or not row.get("answers") is Array or row.answers.size()>5: return false
		var items := {}
		for item: Variant in row.items:
			if not item is String or item.is_empty() or items.has(item): return false
			items[item]=true
		var sorted: Array=row.items.duplicate();sorted.sort()
		if row.signature!=row.topic+":"+str(int(revision))+":"+row.locale+":"+row.difficulty+":"+"|".join(sorted):return false
		var answered := {}
		for answer: Variant in row.answers:
			if not answer is Dictionary or not items.has(answer.get("item")) or answered.has(answer.item): return false
			answered[answer.item]=true
			for key: String in ["first_correct","assisted","solved"]:
				if not answer.get(key) is bool: return false
			var attempts: Variant=answer.get("attempts")
			if not (attempts is float or attempts is int) or not is_finite(attempts) or attempts<1 or attempts!=floor(attempts): return false
			if answer.first_correct and (not answer.solved or attempts!=1):return false
		if row.status=="completed" and (row.answers.size()!=5 or metrics(row).solved!=5): return false
	return true

func commit(candidate: Dictionary) -> bool:
	last_save_error=ERR_INVALID_DATA if load_status=="incompatible" else JsonStore.write_document(storage_path,candidate,valid_document)
	if last_save_error!=OK: storage_failed.emit();return false
	document=candidate
	changed.emit()
	return true

func begin_check(topic: String,revision: int,locale: String,difficulty: String,items: Array[String]) -> String:
	var sorted := items.duplicate();sorted.sort()
	var id := str(Time.get_unix_time_from_system())+"-"+str(Time.get_ticks_usec())
	var row := {"id":id,"topic":topic,"revision":revision,"mode":"check","locale":locale,"difficulty":difficulty,"signature":topic+":"+str(revision)+":"+locale+":"+difficulty+":"+"|".join(sorted),"started":Time.get_datetime_string_from_system(),"status":"active","items":items.duplicate(),"answers":[]}
	var candidate := document.duplicate(true)
	candidate.sessions.append(row)
	while candidate.sessions.size()>LIMIT:candidate.sessions.pop_front()
	return id if commit(candidate) else ""

func session(id: String) -> Dictionary:
	for row: Dictionary in document.sessions:
		if row.id==id:return row.duplicate(true)
	return {}

func record(id: String,item: String,first_correct: bool,assisted: bool,attempts: int,solved: bool) -> bool:
	var candidate := document.duplicate(true)
	for row: Dictionary in candidate.sessions:
		if row.id!=id:continue
		if row.status!="active" or item not in row.items:return false
		var replacement := {"item":item,"first_correct":first_correct,"assisted":assisted,"attempts":attempts,"solved":solved}
		for i: int in range(row.answers.size()):
			if row.answers[i].item==item:
				var old: Dictionary=row.answers[i]
				if old.solved or attempts<old.attempts or first_correct!=old.first_correct or (old.assisted and not assisted):return false
				row.answers[i]=replacement
				return commit(candidate)
		row.answers.append(replacement)
		return commit(candidate)
	return false

func finish(id: String,completed: bool) -> bool:
	if id.is_empty():return false
	var candidate := document.duplicate(true)
	for row: Dictionary in candidate.sessions:
		if row.id==id:
			if row.status!="active":return row.status=="completed" and completed
			row.status="completed" if completed else "interrupted"
			return commit(candidate)
	return false

func metrics(row: Dictionary) -> Dictionary:
	var result := {"independent":0,"assisted":0,"solved":0,"retries":0}
	for answer: Dictionary in row.get("answers",[]):
		result.retries+=int(answer.attempts)-1
		if not answer.solved:continue
		result.solved+=1
		result.independent+=int(answer.first_correct and not answer.assisted)
		result.assisted+=int(answer.assisted)
	return result

func previous_comparable(id: String) -> Dictionary:
	var current := session(id)
	if current.is_empty() or current.status!="completed":return {}
	var previous := {}
	for row: Dictionary in document.sessions:
		if row.id==id:break
		if row.status=="completed" and row.signature==current.signature:previous=row
	return previous.duplicate(true)

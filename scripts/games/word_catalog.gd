class_name WordCatalog
extends RefCounted
static var cache: Dictionary={}
static func items(locale: String) -> Array:
	var cache_key: String= locale+"_"+SettingsManager.values.body_character
	if cache.has(cache_key):return cache[cache_key].duplicate(true)
	var result: Array=[];var seen: Dictionary={}
	for source: Array in [["animals","animals"],["foods","foods"],["colors","colors"],["shapes","shapes"],["world_plants","items"],["world_body","items"],["coloring","pages"],["counting","counting"],["memory","memory"],["puzzles","puzzles"]]:
		var catalog: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/"+source[0]+".json"))
		var source_items: Array=catalog[source[1]]
		if source[0]=="world_body":source_items=WorldCatalog.items("body")
		for entry: Dictionary in source_items:
			append(result,seen,locale,entry["ukrainian" if locale=="uk" else "english"],entry.get("illustration",entry.get("preview","")),entry.word_key,source[0]+":"+entry.id,entry.get("art_region",[]))
	for entry: Dictionary in LetterCatalog.load_data().alphabets[locale]:append(result,seen,locale,entry.example,entry.illustration,entry.example_key,"alphabet:"+entry.id)
	cache[cache_key]=result
	return result.duplicate(true)
static func append(result: Array,seen: Dictionary,locale: String,text: String,art: String,key: String,id: String,region: Array=[]) -> void:
	if seen.has(text.to_lower()):return
	var letters: Array[String]=[];var glyphs := ""
	for entry: Dictionary in LetterCatalog.load_data().alphabets[locale]:glyphs+=entry.upper
	for i: int in range(text.length()):
		var glyph := text.substr(i,1).to_upper()
		if glyph in glyphs:letters.append(glyph)
	if letters.is_empty():return
	seen[text.to_lower()]=true
	result.append({"id":"word:"+id,"text":text,"letters":letters,"illustration":art,"word_key":key,"art_region":region})

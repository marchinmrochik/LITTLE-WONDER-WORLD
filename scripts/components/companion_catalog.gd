class_name CompanionCatalog
extends RefCounted
const IDS: Array[String]=["fox","cat","dog","rabbit","bear","lion","elephant","duck","pig","sheep","horse"]
static func valid(id: String) -> bool:return id in IDS
static func illustration(id: String) -> String:
	return "res://assets/characters/foxie.svg" if id=="fox" else "res://assets/objects/animals/"+id+".svg"
static func word_key(id: String) -> String:return "BOOK_WORD_FOX" if id=="fox" else "WORD_"+id.to_upper()
static func label_key(id: String) -> String:return word_key(id)

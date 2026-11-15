class_name DrawWordDeck
extends RefCounted
const EASY_KEYS := ["WORD_CAT","WORD_DOG","WORD_DUCK","WORD_RABBIT","FOOD_WORD_APPLE","FOOD_WORD_BANANA","FOOD_WORD_CARROT","FOOD_WORD_PEAR","SHAPE_WORD_CIRCLE","SHAPE_WORD_SQUARE","SHAPE_WORD_STAR","SHAPE_WORD_HEART","BOOK_WORD_HOUSE","BOOK_WORD_FISH","BOOK_WORD_FLOWER","WORLD_PLANTS_LEAF_WORD","WORLD_PLANTS_TREE_WORD","WORLD_PLANTS_FLOWER_WORD","WORLD_BODY_EYE_WORD","WORLD_BODY_NOSE_WORD","WORLD_BODY_HAND_WORD"]
const CATEGORIES := ["all","animals","food","nature","things","body"]
var pool: Array=[]
var bag: Array=[]
var last_id := ""
var advanced := false
var difficulty := "normal"
static func category(entry: Dictionary) -> String:
 var id: String=entry.id;var art: String=entry.illustration
 if "world_body:" in id:return "body"
 if "world_plants:" in id:return "nature"
 if "/animals/" in art or art.get_file().get_basename() in ["beetle","goat","hedgehog","raccoon","turkey","turtle","whale","zebra"]:return "animals"
 if "/food/" in art or art.get_file().get_basename() in ["icecream","jelly","onion","yogurt"]:return "food"
 if art.get_file().get_basename() in ["sun","moon","mushroom","nest","fountain"]:return "nature"
 return "things"
func configure(locale: String,difficulty: String,group: String) -> void:
 self.difficulty=difficulty;advanced=difficulty=="advanced";pool=[];bag=[];last_id=""
 for entry: Dictionary in WordCatalog.items(locale):
  if entry.word_key.begins_with("COLOR_WORD_") or entry.word_key.begins_with("COUNT_NUMBER_"):continue
  if difficulty=="easy" and entry.word_key not in EASY_KEYS:continue
  if group!="all" and category(entry)!=group:continue
  pool.append(entry)
func count_required() -> int:return 2 if advanced else 1
func available() -> bool:return pool.size()>=count_required()
func next() -> Array:
 if not available():return []
 if bag.is_empty():
  bag=pool.duplicate(true);bag.shuffle()
  if bag.size()>1 and str(bag[0].id)==last_id:bag.push_back(bag.pop_front())
 if bag.size()>1 and str(bag[0].id)==last_id:bag.push_back(bag.pop_front())
 var first: Dictionary=bag.pop_front();last_id=first.id
 var result: Array=[first]
 if advanced:
  var others := pool.filter(func(e: Dictionary) -> bool:return e.id!=first.id)
  result.append(others.pick_random())
 return result

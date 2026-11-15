class_name MelodyPractice
extends RefCounted
# Original short motifs using only the instrument's eight existing pitches.
const MELODIES := [[0,2,4,2,0,2,4,7],[4,3,2,1,0,1,2,0],[0,0,4,4,5,4,2,0],[0,2,4,5,4,2,1,0],[7,6,4,2,3,4,2,0]]
var melody := 0
var index := 0
var mistakes := 0
func restart(value: int) -> void:
 melody=clampi(value,0,MELODIES.size()-1);index=0;mistakes=0
func done() -> bool:return index>=MELODIES[melody].size()
func expected() -> int:return -1 if done() else MELODIES[melody][index]
func submit(note: int) -> bool:
 if done():return false
 if note!=expected():mistakes+=1;return false
 index+=1;return true

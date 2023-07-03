extends Node
class_name WeekParser

# what this does is turn psych engine formatted weeks into data that is useful to the game's Freeplay/Story Menu

var loadedWeeks:Dictionary
var weekList:Array[String]

var songs:Array
var weekCharacters:Array
var weekBefore:String
var weekName:String
var difficulties:String

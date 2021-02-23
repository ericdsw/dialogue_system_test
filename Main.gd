extends Control

onready var dialogue := get_node("Dialogue") as Dialogue
onready var next_timer := get_node("NextTimer") as Timer

var used_messages := []
var current_offset := 0


func _show_for_offset() -> void:
	dialogue.update_message(used_messages[current_offset])
	

func _reset() -> void:
	next_timer.stop()
	current_offset = 0
	used_messages = []
	

func _on_FunnyButton_pressed() -> void:
	_reset()
	used_messages = [
		"So,{p=0.5} you decided for a funny message...",
		"let's see...",
		"...",
		"Bro,{p=0.5} you are putting me on the spotlight",
		"[shake rate=20 level=10]NO IM NOT NERVOUS,{p=0.2} YOU ARE NERVOUS,{p=0.5} SHUT UP![/shake]"
	]
	_show_for_offset()

func _on_SadButton_pressed() -> void:
	_reset()
	used_messages = [
		"Why on earth would you want to hear a sad message?",
		"Like,{p=0.5} just look around us!",
		"I don't think we need more sad stuff so...",
		"[wave]I'm gonna sing a song instead~[/wave]",
		"[wave]About{p=1.0} eh...[/wave]",
		"nevermind..."
	]
	_show_for_offset()


func _on_WeirdButton_pressed() -> void:
	_reset()
	used_messages = [
		"Anatidaephobia is the fear that,{p=0.5} somewhere,{p=0.5} at any given time",
		"a [rainbow]duck[/rainbow] is watching you...",
		"MENACINGLY",
		"But seriously, if a duck was randomly watching me{p=0.5} I would freak out too..."
	]
	_show_for_offset()


func _on_NextTimer_timeout() -> void:
	current_offset += 1
	if current_offset < used_messages.size():
		_show_for_offset()


func _on_Dialogue_message_completed() -> void:
	next_timer.start()

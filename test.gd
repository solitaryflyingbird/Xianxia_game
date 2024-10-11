extends Node


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		MainData.modify_player_stat("money", 1)

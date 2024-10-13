extends Button


var event_manager  # event_manager에 대한 참조

func _ready():
	connect("pressed", self, "_on_button_pressed")

# 버튼이 눌렸을 때 호출되는 함수
func _on_button_pressed():
	MainData.add_item_to_inventory(1, 1)
	print("Item added. Current inventory:", MainData.get_player_data()["variable_attributes"]["inventory"])

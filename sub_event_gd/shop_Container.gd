extends VBoxContainer

var event_manager  # event_manager에 대한 참조

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	event_manager = get_node("/root/main_data/event_manager") 
	print(event_manager, "parent")
	# 아이템 1에 대한 버튼 생성
	var button_1 = Button.new()
	button_1.text = MainData.item_data[1]["name"]
	add_child(button_1)
	
	# 버튼 클릭 시 이벤트 연결 (10031번 이벤트)
	button_1.connect("pressed", self, "_on_button_pressed", [10031])
	
	# 아이템 3에 대한 버튼 생성
	var button_3 = Button.new()
	button_3.text = MainData.item_data[3]["name"]
	add_child(button_3)
	
	# 버튼 클릭 시 이벤트 연결 (10041번 이벤트)
	button_3.connect("pressed", self, "_on_button_pressed", [10041])


# 버튼 클릭 시 호출되는 함수
func _on_button_pressed(event_id):
	var event_to_add = event_manager.get_event_by_id(event_id)
	if event_to_add:
		event_manager.add_event_to_queue(event_to_add) 

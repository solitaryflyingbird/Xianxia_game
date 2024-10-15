extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	MainData.connect("data_changed", self, "update_inventory_ui")
	
	# 처음 인벤토리 UI를 초기화
	update_inventory_ui()

# 인벤토리 UI를 업데이트하는 함수
func update_inventory_ui():
	# 자식 라벨(Label) 노드를 찾아서 해당 라벨에 텍스트를 이어서 작성
	var item_label = get_node("Label")  # "Label"이라는 이름의 자식 노드를 가져옴

	# MainData에서 player_data의 인벤토리 정보 가져오기
	var inventory = MainData.player_data["variable_attributes"]["inventory"]
	
	# 새로운 텍스트를 초기화
	var new_text = ""

	# 인벤토리 데이터를 순회하며 아이템 이름과 수량을 하나의 라벨에 이어서 작성
	for item in inventory:
		var item_info = MainData.item_data[item["id"]]
		var item_name = item_info["name"]
		var item_quantity = item["quantity"]
		
		# 줄바꿈을 추가하면서 텍스트 이어붙이기
		new_text += item_name + " x " + str(item_quantity) + "\n"
	
	# 기존 라벨에 이어서 작성된 텍스트 설정
	item_label.text = new_text

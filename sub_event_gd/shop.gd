extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.focus_mode = Control.FOCUS_NONE
	connect("pressed", self, "_on_button_pressed")

# 버튼이 눌렸을 때 호출되는 함수
func _on_button_pressed():
	# 자식 노드 중 'Item Container' 이름을 가진 노드를 찾아서 visible 속성을 토글
	var item_container = get_node("shop_Container")  # 'Item Container' 이름의 자식 노드를 찾음
	if item_container:
		item_container.visible = !item_container.visible  # visible 속성을 반대로 토글

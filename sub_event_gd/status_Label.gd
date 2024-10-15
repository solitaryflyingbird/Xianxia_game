extends Label

func _ready():
	data_gathering()
	# MainData의 data_changed 신호를 연결
	MainData.connect("data_changed", self, "_on_data_changed")

# 데이터 변경 신호가 발생했을 때 호출될 함수
func _on_data_changed():
	data_gathering()

# 데이터를 라벨에 출력
func data_gathering():
	var player_data = MainData.get_player_data()

	# 출력할 정보 선택
	var player_name = player_data["fixed_attributes"]["name"]

	# Label 노드에 텍스트 출력
	text = "이름 : " + player_name + "\n" + \
		   "나이 : " + str(player_data["variable_attributes"]["age"]) + "살\n" + \
		   "경지 : " + player_data["variable_attributes"]["cultivation_stage"] +"\n"+ \
		   "공헌패 : " + str(player_data["variable_attributes"]["money"])  +"\n"+ \
		   "계절 : " + player_data["variable_attributes"]["season"] +"\n"+ \
		   "건강 : "  + str(player_data["variable_attributes"]["health"])+"\n"+ \
		   "수명 : "  + str(player_data["variable_attributes"]["remain_life"])		

extends Node

signal data_changed

# 아이템 데이터베이스
var item_data = {
	1: {"name": "소형 영약", "type": "consumable", "effect": "health_restore", "value": 20},
	2: {"name": "기본 검", "type": "weapon", "attack": 10, "durability": 100},
	3: {"name": "중형 영약", "type": "consumable", "effect": "health_restore", "value": 50},
	4: {"name": "강화된 검", "type": "weapon", "attack": 20, "durability": 150}
}
var max_value = {"health" : 100}
var player_data = {
	"fixed_attributes": {
		"name": "아랑",
		"gender": "남자",
		"spiritual_root": ["화","수","목","금","토"],
		"appearance": 7,
		"intelligence": 8,
		"luck": 5
	},
	"variable_attributes": {
		"season" : "봄",
		"age": 20,
		"remain_life" : 80,
		"health" : 100,
		"experience_point" : 0,
		"cultivation_stage": "연기기 1성",
		"money": 1000, # 소지한 공헌 양
		"inventory": [
			{"id": 1, "quantity": 5},  # 소형 영약
			{"id": 2, "quantity": 1}   # 기본 검
		]
	}
}

func call_function(function_name: String, params: Dictionary = {}):
	match function_name:
		"modify_player_stat":
			modify_player_stat(params)
		"advance_time":
			advance_time()
		_:
			print("Error: Function " + function_name + " not found in MainData")

func get_player_data():
	return player_data

func get_item_data(item_id):
	return item_data.get(item_id)

# 수치 조작 함수
func modify_player_stat(params: Dictionary, data: Dictionary = player_data, depth: int = 0):
	var max_depth = 15  # 재귀 깊이 제한
	if depth > max_depth:
		print("Error: Maximum recursion depth reached")
		return false

	var stat_name = params.get("stat_name", "")
	var value = params.get("value", 0)
	for key in data.keys():
		var item = data[key]
		if typeof(item) == TYPE_DICTIONARY:
			if modify_player_stat({"stat_name": stat_name, "value": value}, item, depth + 1):
				return true
		elif typeof(item) == TYPE_ARRAY:
			continue
		elif key == stat_name:
			data[key] += value
			# max_value 체크 및 적용
			if max_value.has(stat_name):
				data[key] = min(data[key], max_value[stat_name])
			print(stat_name + " has been modified to " + str(data[key]))
			emit_signal("data_changed")
			return true
	if data == player_data:
		print("Error: Invalid stat name - " + stat_name)
	return false

			
# 시간 흐름 함수 춘하추동
func advance_time():
	var current_season = player_data["variable_attributes"]["season"]
	if current_season == "봄":
		player_data["variable_attributes"]["season"] = "여름"
	elif current_season == "여름":
		player_data["variable_attributes"]["season"] = "가을"
	elif current_season == "가을":
		player_data["variable_attributes"]["season"] = "겨울"
	elif current_season == "겨울":
		player_data["variable_attributes"]["season"] = "봄"
		player_data["variable_attributes"]["age"] += 1
		player_data["variable_attributes"]["remain_life"] -= 1
	print("advance_time")
	emit_signal("data_changed")

# 아이템 추가 함수
func add_item_to_inventory(item_id: int, quantity: int):
	var inventory = player_data["variable_attributes"]["inventory"]
	for item in inventory:
		if item["id"] == item_id:
			item["quantity"] += quantity
			emit_signal("data_changed")
			return
	
	# 아이템이 인벤토리에 없으면 새로 추가
	inventory.append({"id": item_id, "quantity": quantity})
	emit_signal("data_changed")

# 아이템 제거 함수
func remove_item_from_inventory(item_id: int, quantity: int):
	var inventory = player_data["variable_attributes"]["inventory"]
	for i in range(inventory.size()):
		var item = inventory[i]
		if item["id"] == item_id:
			if item["quantity"] > quantity:
				item["quantity"] -= quantity
			else:
				inventory.remove(i)
			emit_signal("data_changed")
			return

# 아이템 정보 조회 함수
func get_item_info(item_id: int):
	return item_data.get(item_id, null)
	
	

extends Node2D

##################################################
const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)	# 화면 크기
const MARGIN: float = 50.0							# 화면 테두리 여백
const POINT_COUNT: int = 49							# 생성할 점의 개수
const CIRCLE_RADIUS: float = 15.0					# 일반 점 반지름
const CIRCLE_COLOR: Color = Color.FIREBRICK			# 일반 점 색상
const LINE_COLOR: Color = Color.CORAL				# 경로 선 색상
const LINE_WIDTH: float = 5.0						# 경로 선 두께

var color_rect_node: ColorRect						# 배경 노드

var points: Array = []								# 무작위로 생성된 점 목록
var path: Array = []									# 최적화된 경로

##################################################
func _ready() -> void:
	color_rect_node = $ColorRect
	color_rect_node.z_index = -10	# 배경 그리는 순서를 가장 아래로 보내기

##################################################
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
	# 스페이스 키나 엔터 키를 누르면
		if GM.get_generate_stage() == 0:
		# 스테이지 0일 때
			GM.set_generate_stage(GM.get_generate_stage() + 1)
			init_points()
			# 점 생성
		elif GM.get_generate_stage() == 1:
		# 스테이지 1일 때
			GM.set_generate_stage(GM.get_generate_stage() + 1)
			nearest_neighbor()
			# 최근접 이웃으로 초기 경로 생성
		elif GM.get_generate_stage() == 2:
		# 스테이지 2일 때
			GM.set_generate_stage(GM.get_generate_stage() + 1)
			two_opt()
			# 2-opt로 경로 최적화
	elif Input.is_action_just_pressed("ui_cancel"):
	# esc 키를 누르면
		points.clear()
		path.clear()
		GM.set_generate_stage(0)
		GM.set_n_n_total_distance(0.0)
		GM.set_two_opt_total_distance(0.0)
		queue_redraw()
		# 각 요소 리셋

##################################################
func init_points() -> void:
	points.clear()
	path.clear()
	
	for i in range(POINT_COUNT):
		points.append(Vector2(\
			randf_range(MARGIN, SCREEN_SIZE.x - MARGIN), \
			randf_range(MARGIN, SCREEN_SIZE.y - MARGIN)))
	
	queue_redraw()
	# 무작위 점들 초기화

##################################################
func nearest_neighbor() -> void:
# 최근접 이웃(Nearest Neighbor) 알고리즘으로 경로 생성
	var duplicate_points: Array = points.duplicate()
	path.append(duplicate_points.pop_front())	# 시작점
	
	while duplicate_points.size() > 0:	# 점 목록 복사 Array가 남아있으면 반복
		var near_point: Vector2 = duplicate_points.front()
		var near_point_distance: float = path.back().distance_to(near_point)
		# 임의의 점을 가장 가까운 점이라 지정 후
		
		for point in duplicate_points:	# 가장 가까운 점을 찾는 연산
			var point_distance: float = path.back().distance_to(point)
			if point_distance < near_point_distance:
					near_point = point
					near_point_distance = point_distance
		
		duplicate_points.erase(near_point)	# 가장 가까운 점으로 등록된 점은 삭제
		path.append(near_point)				# 경로 목록에 추가
	
	path.append(path.front())						# 시작점으로 되돌아오기
	queue_redraw()									# 점과 경로 그리기
	GM.set_n_n_total_distance(get_total_distance())	# 경로의 총 거리 계산

##################################################
func two_opt() -> void:
# 2-opt 최적화 알고리즘
	var improved: bool = true	# 개선 여부 확인 변수
	
	while improved:	# 개선이 됐다면 반복
		improved = false	# 개선 없음으로 설정 후
		for i in range(1, path.size() - 2):
			for j in range(i + 1, path.size() - 1):
				var path_a = path[i - 1]
				var path_b = path[i]
				var path_c = path[j]
				var path_d = path[j + 1]
				# 두 경로(네 점)을 순회하며 연산
				'''
				i를 기준으로 앞의 구간과, j = i + 1이므로 i와
				하나 떨어진 뒤 구간을 비교하기 위해서 아래와 같이 변수를 설정
				var path_a = path[i - 1]
				var path_b = path[i]
				var path_c = path[j]
				var path_d = path[j + 1]
				
				위 변수에 알맞고, 마지막 경로는 처음으로 돌아오는 경로이므로
				아래와 같이 순회 범위를 제한함
				for i in range(1, path.size() - 2):
					for j in range(i + 1, path.size() - 1):
				'''
		
				var current_distance: float = \
					path_a.distance_to(path_b) + path_c.distance_to(path_d)
				var new_distance: float = \
					path_a.distance_to(path_c) + path_b.distance_to(path_d)
				# 변경 전화 후의 거리를 계산
		
				if new_distance < current_distance:	# 거리를 비교하여 줄어들면
					var reversed_section: Array = path.slice(i, j + 1)
					reversed_section.reverse()
					
					for k in range(reversed_section.size()):
						path[i + k] = reversed_section[k]
					# 해당 경로의 점들을 통으로 순서를 반대로 바꿈
					
					improved = true	# 개선이 되었으므로 true로 설정
	
	queue_redraw()
	GM.set_two_opt_total_distance(get_total_distance())

##################################################
func get_total_distance() -> float:	# 경로의 총 거리 계산
	var total_distance: float = 0.0
	for i in range(path.size() - 1):
		total_distance += path[i].distance_to(path[i + 1])
	
	return total_distance

##################################################
func _draw() -> void:
	if points.size() > 0:
		for point in points:
			draw_circle(point, CIRCLE_RADIUS, CIRCLE_COLOR)
			draw_circle(points.front(), CIRCLE_RADIUS * 3, Color.GOLD)
			# 시작점 강조
	
	if path.size() > 0:
		for i in range(path.size() - 1):
			draw_line(path[i], path[i + 1], LINE_COLOR, LINE_WIDTH)

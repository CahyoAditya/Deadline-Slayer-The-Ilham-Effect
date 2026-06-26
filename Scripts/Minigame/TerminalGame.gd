extends Node

var easy_patterns: Array[String] = [
	"ctx.fillRect(0, 0, w, h)", "import plotly.express as px", "var gkv_score = 100",
	"print(\"Halo Pak MAA\")", "var vertex_x = 10.0", "draw_triangle()",
	"var vr_ready = true", "ctx.moveTo(0, 0)", "ctx.lineTo(x, y)",
	"var data_pertanian = []", "return A_grade", "var class_ipb_url = \"class.ipb.ac.id\"",
	"await timer", "func start():", "pass"
]

var medium_patterns: Array[String] = [
	"var df = pd.read_csv('pertanian.csv')", "var transform_matrix = Transform3D()",
	"fig = px.scatter(df, x='Curah_Hujan', y='Panen')", "if deadline <= 0: panic()",
	"ctx.bezierCurveTo(20, 100, 200, 100, 200, 20)", "var camera = Camera3D.new()",
	"ctx.arc(x, y, radius, 0, PI * 2)", "EventBus.emit_signal(\"gkv_submitted\")",
	"Input.is_action_pressed(\"interact\")", "get_tree().reload_current_scene()",
	"var tween = create_tween()", "GameManager.trigger_win()"
]

var hard_patterns: Array[String] = [
	"func _hitung_transformasi_3d(matrix: Transform3D) -> Vector3:",
	"fig.update_layout(title='Visualisasi Data Pertanian IPB')",
	"var point_cloud = generate_3d_representation()",
	"ctx.strokeText(\"TUGAS GKV\", 50, 50)",
	"func _render_vr_environment(eye: int) -> void:",
	"if mahasiswa.kewarasan < 20.0: mental_breakdown()",
	"EventBus.progress_threshold_reached.connect(_on_threshold)",
	"for threshold in GameManager.event_config.thresholds:",
	"message_panel.set_anchors_preset(Control.PRESET_CENTER)",
	"flashlight.visible = flashlight_on and battery_level > 0.0"
]

func _ready() -> void:
	pass # _load_pattern_resources() disabled to use GKV hardcoded patterns

func get_pattern() -> String:
	var progress := ProgressSystem.get_progress()
	# If the Specter is active, always use hard patterns to maximise panic
	if GameManager.is_specter_active:
		return hard_patterns.pick_random()
	if progress < 34.0:
		return easy_patterns.pick_random()
	if progress < 67.0:
		return medium_patterns.pick_random()
	return hard_patterns.pick_random()

func _load_pattern_resources() -> void:
	var easy := _load_pattern_set("res://Resources/Patterns/easy_patterns.tres")
	var medium := _load_pattern_set("res://Resources/Patterns/medium_patterns.tres")
	var hard := _load_pattern_set("res://Resources/Patterns/hard_patterns.tres")

	if easy != null:
		easy_patterns = easy.patterns
	if medium != null:
		medium_patterns = medium.patterns
	if hard != null:
		hard_patterns = hard.patterns

func _load_pattern_set(path: String) -> PatternSet:
	if ResourceLoader.exists(path):
		return load(path) as PatternSet
	return null

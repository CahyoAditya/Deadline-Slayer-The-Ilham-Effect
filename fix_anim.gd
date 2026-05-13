@tool
extends EditorScript

func _run():
	var lib = load("res://anims/protagonist/walking.fbx") as AnimationLibrary
	if lib:
		var anim = lib.get_animation("mixamo_com")
		if anim:
			anim = anim.duplicate()
			for i in range(anim.get_track_count() - 1, -1, -1):
				var path = str(anim.track_get_path(i))
				if path == "." or path == "Armature" or path.begins_with("Armature:"):
					anim.remove_track(i)
					print("Removed track: ", path)
			
			var new_lib = AnimationLibrary.new()
			new_lib.add_animation("mixamo_com", anim)
			ResourceSaver.save(new_lib, "res://anims/protagonist/walking_fixed.res")
			print("Saved fixed animation library to res://anims/protagonist/walking_fixed.res!")
			
			# Also automatically update the Player.tscn
			var scene = load("res://Scenes/Player.tscn")
			if scene:
				var state = scene.get_state()
				# Instead of messing with PackedScene (which is complex), we just tell the user to update it.
extends Control


func _on_exit_btn_pressed():
	get_tree().quit()


func _on_start_btn_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://main.tscn")


func _on_credits_btn_pressed():
	get_tree().change_scene_to_file("res://ui/game_credits.tscn")

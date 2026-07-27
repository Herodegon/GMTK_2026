extends Node

signal hide_tutorial_prompt

signal radio_interact
signal radio_prompt

signal beer_interact

signal start_catch_event
signal send_fish(fish: Node3D)
signal remove_fish(fish: Node3D)
signal end_catch_event
signal win_catch_event(fish: Node3D)
signal lose_catch_event

signal progress_to_target(percentage: float)
signal to_final_countdown_timer(float: float)
signal to_final_countdown_timer_text(text: String)

signal update_fish_count(count: int)

signal start_ending
signal fade_out

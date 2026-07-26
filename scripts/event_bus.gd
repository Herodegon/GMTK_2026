extends Node

signal radio_interact
signal radio_prompt

signal beer_interact

signal start_catch_event
signal end_catch_event
signal win_catch_event
signal lose_catch_event

signal progress_to_target(percentage: float)
signal to_final_countdown_timer(float: float)
signal to_final_countdown_timer_text(text: String)

signal update_fish_count(count: int)

signal start_ending
signal fade_out

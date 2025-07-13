extends Control

@onready var day_Labels : Label = $DayControl/day
@onready var hours_Labels: Label = $clockbg/clockControl/hours
@onready var minutes_Labels: Label = $clockbg/clockControl/minutes

func _on_time_system_updated(date_time: DateTime) -> void:
	update_label(day_Labels,date_time.days,false)
	update_label(hours_Labels,date_time.hours)
	update_label(minutes_Labels,date_time.minutes)

func add_leading_zero(label : Label ,value : int )-> void:
	if value < 10:
		label.text +='0' 

func update_label(label:Label , value:int, should_have_zero: bool = true) ->void:
	label.text = ""
	
	if should_have_zero:
		add_leading_zero(label,value)
		
	label.text += str(value)
	

extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var left_barrier_position = -6
export var rightbarrier_position = 17
var currnet_barrier_depth = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	draw_side_barriers(0,100)
	currnet_barrier_depth = 100
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	draw_side_barriers(0,100)
#	update_dirty_quadrants()
#	pass

func draw_side_barriers(from_y_pos, to_y_pos):
	for y in range(from_y_pos,to_y_pos):
		self.set_cell(left_barrier_position,y,3)
			
	for y in range(from_y_pos,to_y_pos):
		self.set_cell(rightbarrier_position,y,2)

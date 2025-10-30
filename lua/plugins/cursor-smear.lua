return {
	"sphamba/smear-cursor.nvim",
	event = "CursorMoved",
	enabled = true,
	opts = {
		-- Smear cursor when switching buffers or windows.
		smear_between_buffers = false,
		smear_between_neighbor_lines = true,

		-- Draw the smear in buffer space instead of screen space when scrolling
		scroll_buffer_space = true,
		smear_to_cmd = false,
		smear_insert_mode = true,
		transparent_bg_fallback_color = "#adbcff",
		--smear_diagonally = false,
		time_interval = 7,

		stiffness = 0.8,
		trailing_stiffness = 0.6,
		stiffness_insert_mode = 0.5,
		trailing_stiffness_insert_mode = 0.4,
		damping = 0.95,
		damping_insert_mode = 0.95,
		distance_stop_animating = 0.5,
	},
}

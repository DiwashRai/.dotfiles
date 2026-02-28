return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	opts = {
		diff = {
			layout = "side-by-side",
			max_computation_time_ms = 5000,
			ignore_trim_whitespace = true,
			cycle_next_hunk = false,
			cycle_next_file = false,
			jump_to_first_change = true,
		},
	},
}

test:
	nvim --headless -c "PlenaryBustedDirectory lua/spec { minimal_init = './lua/spec/minimal_init.lua', sequential = true }" -c qa

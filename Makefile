test:
	nvim --headless -u ./lua/spec/minimal_init.lua -c "PlenaryBustedDirectory lua/spec { sequential = true }" -c cquit

.PHONY: shell

get-deps:
	mix deps.get

tests: get-deps
	mix test

shell: get-deps
	iex -S mix

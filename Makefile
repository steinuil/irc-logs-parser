.PHONY: check
check:
	bundle exec steep check --no-builtin --fallback-any-is-error

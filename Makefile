default: console

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: console

console:
	@docker run --rm -ti -v $(shell pwd):/buildpack -e "STACK=heroku-22" -w /buildpack heroku/heroku:22-build \
		bash -c 'mkdir /app /cache /env; bin/compile /app/ /cache/ /env/; source /app/.profile.d/*; exec bash'

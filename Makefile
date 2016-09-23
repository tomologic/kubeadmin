.PHONY: build rmi

build:
	docker build -t tomologic/$(shell basename $(CURDIR)) .

rmi:
	docker rmi tomologic/$(shell basename $(CURDIR))

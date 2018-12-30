APP_NAME = sage

CONTAINER = $(APP_NAME)
DEV_IMAGE = $(APP_NAME)-test

#### Development targets


dev-build:
        docker build --rm -t $(DEV_IMAGE) --label type=$(DEV_IMAGE) .

dev-run:
        docker run -it --rm --name $(CONTAINER) -p 8888:8888 -h localhost $(DEV_IMAGE) sage -notebook=jupyter --no-browser --ip='*' --port=8888
# Rules for Docker projects
ifdef IS_DOCKER_PROJECT

.PHONY: docker-image docker-push
docker-image: $(DOCKERTIME)
docker-push: $(DOCKERPUSHTIME)

# Docker build rule
$(DOCKERTIME): $(DOCKERFILE) $(DOCKER_CONTEXT_FILES)
	$(BUILD_STATUS) -t docker-image --lang docker -s "Build Docker image"
	docker build --pull --no-cache --force-rm $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMAGE_NAME):$(GIT_VERSION) $(DOCKER_CONTEXT)
	docker tag $(DOCKER_IMAGE_NAME):$(GIT_VERSION) $(DOCKER_IMAGE_NAME):latest
	touch $@

# Docker push rule
$(DOCKERPUSHTIME): $(DOCKERTIME)
	$(FILEBOX_STATUS) -t docker-push --lang docker -s "Push Docker image"
	docker push $(DOCKER_IMAGE_NAME):$(GIT_VERSION)
	docker push $(DOCKER_IMAGE_NAME):latest
	touch $@

endif # ifdef IS_DOCKER_PROJECT

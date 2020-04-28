# Rules for Docker projects
ifdef IS_DOCKER_PROJECT

.PHONY: docker-image
docker-image: $(DOCKERTIME)

# Generic Docker build rule
$(DOCKERTIME): $(DOCKERFILE) $(DOCKER_CONTEXT)
	$(BUILD_STATUS) -t docker-image --lang docker -s "Build Docker image"
	docker build --pull --no-cache --force-rm -t $(DOCKER_IMAGE_NAME):latest $(PROJECT_ROOT)
	touch $@

endif # ifdef IS_DOCKER_PROJECT

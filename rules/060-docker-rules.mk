# Rules for Docker projects
ifdef IS_DOCKER_PROJECT

.PHONY: docker-images
docker-images: $(DOCKERTIMES)

# Generic Docker build rule
$(CACHE_DIR)/docker-image-%.time: $(PROJECT_ROOT)/%/Dockerfile
	$(BUILD_STATUS) -t docker-image-$(DOCKER_NAME_FROM_TARGET) --lang docker -s "Building Docker image"
	docker build --pull --no-cache --force-rm -t $(DOCKER_NAME_FROM_TARGET):latest `dirname $<`
	touch $@

endif # ifdef IS_DOCKER_PROJECT

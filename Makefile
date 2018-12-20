EXECUTABLE=ExampleLambda
PROJECT_PATH=ExampleLambda
LAMBDA_ZIP=lambda.zip

clean:
	rm $(LAMBDA_ZIP) || true
	rm -r $(PROJECT_PATH)/.build_linux || true

build:
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src/$(PROJECT_PATH)" \
			swift \
			swift build --build-path ./.build_linux

package_lambda: clean build
	zip -r -j $(LAMBDA_ZIP) bootstrap $(PROJECT_PATH)/.build_linux/debug/$(EXECUTABLE)

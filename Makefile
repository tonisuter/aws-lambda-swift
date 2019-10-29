EXAMPLE_LAMBDA=SquareNumber
EXAMPLE_EXECUTABLE=SquareNumber
EXAMPLE_PROJECT_PATH=Examples/SquareNumber

# EXAMPLE_LAMBDA=SyntaxHighlighter
# EXAMPLE_EXECUTABLE=SyntaxHighlighter
# EXAMPLE_PROJECT_PATH=Examples/SyntaxHighlighter
# EXAMPLE_LAMBDA=RESTCountries
# EXAMPLE_EXECUTABLE=RESTCountries
# EXAMPLE_PROJECT_PATH=Examples/RESTCountries
LAMBDA_ZIP=lambda.zip
LAYER_FOLDER=swift-lambda-runtime
LAYER_ZIP=swift-lambda-runtime.zip
SHARED_LIBS_FOLDER=$(LAYER_FOLDER)/swift-shared-libs
SWIFT_DOCKER_IMAGE=swift:5.1.1

# System specific configuration

UNAME_S := $(shell uname -s)

clean_lambda:
	rm $(LAMBDA_ZIP) || true
	rm -rf $(EXAMPLE_PROJECT_PATH)/.build || true

build_lambda:
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src/$(EXAMPLE_PROJECT_PATH)" \
			$(SWIFT_DOCKER_IMAGE) \
			swift build

package_lambda: clean_lambda build_lambda
	zip -r -j $(LAMBDA_ZIP) $(EXAMPLE_PROJECT_PATH)/.build/debug/$(EXAMPLE_EXECUTABLE)

deploy_lambda: package_lambda
	aws lambda update-function-code --function-name $(EXAMPLE_LAMBDA) --zip-file fileb://lambda.zip

clean_layer:
	rm $(LAYER_ZIP) || true
	rm -r $(SHARED_LIBS_FOLDER) || true

create_layer: clean_layer
	mkdir -p $(LAYER_FOLDER)
	mkdir -p $(SHARED_LIBS_FOLDER)/lib
	cp ./bootstrap "$(LAYER_FOLDER)/bootstrap"
	chmod 755 "$(LAYER_FOLDER)/bootstrap"
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src" \
			$(SWIFT_DOCKER_IMAGE) \
			cp /lib64/ld-linux-x86-64.so.2 $(SHARED_LIBS_FOLDER)
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src" \
			$(SWIFT_DOCKER_IMAGE) \
			cp -t $(SHARED_LIBS_FOLDER)/lib \
					/lib/x86_64-linux-gnu/libc.so.6 \
					/lib/x86_64-linux-gnu/libcom_err.so.2 \
					/lib/x86_64-linux-gnu/libcrypt.so.1 \
					/lib/x86_64-linux-gnu/libdl.so.2 \
					/lib/x86_64-linux-gnu/libgcc_s.so.1 \
					/lib/x86_64-linux-gnu/libkeyutils.so.1 \
					/lib/x86_64-linux-gnu/libm.so.6 \
					/lib/x86_64-linux-gnu/libpthread.so.0 \
					/lib/x86_64-linux-gnu/libresolv.so.2 \
					/lib/x86_64-linux-gnu/librt.so.1 \
					/lib/x86_64-linux-gnu/libutil.so.1 \
					/lib/x86_64-linux-gnu/libz.so.1 \
					/usr/lib/swift/linux/libBlocksRuntime.so \
					/usr/lib/swift/linux/libFoundation.so \
					/usr/lib/swift/linux/libFoundationNetworking.so \
					/usr/lib/swift/linux/libdispatch.so \
					/usr/lib/swift/linux/libicudataswift.so.61 \
					/usr/lib/swift/linux/libicui18nswift.so.61 \
					/usr/lib/swift/linux/libicuucswift.so.61 \
					/usr/lib/swift/linux/libswiftCore.so \
					/usr/lib/swift/linux/libswiftDispatch.so \
					/usr/lib/swift/linux/libswiftGlibc.so \
					/usr/lib/swift/linux/libswiftSwiftOnoneSupport.so \
					/usr/lib/x86_64-linux-gnu/libasn1.so.8 \
					/usr/lib/x86_64-linux-gnu/libatomic.so.1 \
					/usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 \
					/usr/lib/x86_64-linux-gnu/libcurl.so.4 \
					/usr/lib/x86_64-linux-gnu/libffi.so.6 \
					/usr/lib/x86_64-linux-gnu/libgmp.so.10 \
					/usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
					/usr/lib/x86_64-linux-gnu/libgssapi.so.3 \
					/usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 \
					/usr/lib/x86_64-linux-gnu/libhcrypto.so.4 \
					/usr/lib/x86_64-linux-gnu/libheimbase.so.1 \
					/usr/lib/x86_64-linux-gnu/libheimntlm.so.0 \
					/usr/lib/x86_64-linux-gnu/libhogweed.so.4 \
					/usr/lib/x86_64-linux-gnu/libhx509.so.5 \
					/usr/lib/x86_64-linux-gnu/libidn2.so.0 \
					/usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
					/usr/lib/x86_64-linux-gnu/libkrb5.so.26 \
					/usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
					/usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
					/usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
					/usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
					/usr/lib/x86_64-linux-gnu/libnettle.so.6 \
					/usr/lib/x86_64-linux-gnu/libnghttp2.so.14 \
					/usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
					/usr/lib/x86_64-linux-gnu/libpsl.so.5 \
					/usr/lib/x86_64-linux-gnu/libroken.so.18 \
					/usr/lib/x86_64-linux-gnu/librtmp.so.1 \
					/usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
					/usr/lib/x86_64-linux-gnu/libsqlite3.so.0 \
					/usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
					/usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
					/usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
					/usr/lib/x86_64-linux-gnu/libunistring.so.2 \
					/usr/lib/x86_64-linux-gnu/libwind.so.0 \
					/usr/lib/x86_64-linux-gnu/libxml2.so.2

test_layer: package_lambda
	echo '{"number": 9 }' | sam local invoke --force-image-build -v . "SquareNumberFunction"

package_layer: create_layer
	zip -r $(LAYER_ZIP) bootstrap $(SHARED_LIBS_FOLDER)

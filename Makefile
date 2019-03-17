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
SHARED_LIBS_FOLDER=swift-shared-libs
LAYER_ZIP=swift-lambda-runtime.zip

clean_lambda:
	rm $(LAMBDA_ZIP) || true
	rm -rf $(EXAMPLE_PROJECT_PATH)/.build || true

build_lambda:
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src/$(EXAMPLE_PROJECT_PATH)" \
			swift \
			swift build

package_lambda: clean_lambda build_lambda
	zip -r -j $(LAMBDA_ZIP) $(EXAMPLE_PROJECT_PATH)/.build/debug/$(EXAMPLE_EXECUTABLE)

deploy_lambda: package_lambda
	aws lambda update-function-code --function-name $(EXAMPLE_LAMBDA) --zip-file fileb://lambda.zip

clean_layer:
	rm $(LAYER_ZIP) || true
	rm -r $(SHARED_LIBS_FOLDER) || true

package_layer: clean_layer
	mkdir -p $(SHARED_LIBS_FOLDER)/lib
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src" \
			swift \
			cp /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $(SHARED_LIBS_FOLDER)
	docker run \
			--rm \
			--volume "$(shell pwd)/:/src" \
			--workdir "/src" \
			swift \
			cp -t $(SHARED_LIBS_FOLDER)/lib \
					/lib/x86_64-linux-gnu/libnss_dns.so.2 \
					/lib/x86_64-linux-gnu/libbsd.so.0 \
					/lib/x86_64-linux-gnu/libc.so.6 \
					/lib/x86_64-linux-gnu/libcom_err.so.2 \
					/lib/x86_64-linux-gnu/libcrypt.so.1 \
					/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 \
					/lib/x86_64-linux-gnu/libdl.so.2 \
					/lib/x86_64-linux-gnu/libgcc_s.so.1 \
					/lib/x86_64-linux-gnu/libkeyutils.so.1 \
					/lib/x86_64-linux-gnu/liblzma.so.5 \
					/lib/x86_64-linux-gnu/libm.so.6 \
					/lib/x86_64-linux-gnu/libpthread.so.0 \
					/lib/x86_64-linux-gnu/libresolv.so.2 \
					/lib/x86_64-linux-gnu/libssl.so.1.0.0 \
					/lib/x86_64-linux-gnu/libutil.so.1 \
					/lib/x86_64-linux-gnu/libz.so.1 \
					/usr/lib/swift/linux/libFoundation.so \
					/usr/lib/swift/linux/libdispatch.so \
					/usr/lib/swift/linux/libswiftCore.so \
					/usr/lib/swift/linux/libswiftGlibc.so \
					/usr/lib/swift/linux/libswiftSwiftOnoneSupport.so \
					/usr/lib/x86_64-linux-gnu/libasn1.so.8 \
					/usr/lib/x86_64-linux-gnu/libatomic.so.1 \
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
					/usr/lib/x86_64-linux-gnu/libicudata.so.55 \
					/usr/lib/x86_64-linux-gnu/libicui18n.so.55 \
					/usr/lib/x86_64-linux-gnu/libicuuc.so.55 \
					/usr/lib/x86_64-linux-gnu/libidn.so.11 \
					/usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
					/usr/lib/x86_64-linux-gnu/libkrb5.so.26 \
					/usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
					/usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
					/usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
					/usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
					/usr/lib/x86_64-linux-gnu/libnettle.so.6 \
					/usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
					/usr/lib/x86_64-linux-gnu/libroken.so.18 \
					/usr/lib/x86_64-linux-gnu/librtmp.so.1 \
					/usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
					/usr/lib/x86_64-linux-gnu/libsqlite3.so.0 \
					/usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
					/usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
					/usr/lib/x86_64-linux-gnu/libwind.so.0 \
					/usr/lib/x86_64-linux-gnu/libxml2.so.2
	zip -r $(LAYER_ZIP) bootstrap $(SHARED_LIBS_FOLDER)

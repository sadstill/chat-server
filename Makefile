LOCAL_BIN:=$(CURDIR)/bin

install-golangci-lint:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.61.0

lint:
	$(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

generate-chat-api-v1:
	mkdir -p pkg/chat/v1
	protoc --proto_path api/chat/v1 \
	--go_out=pkg/chat/v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=bin/protoc-gen-go \
	--go-grpc_out=pkg/chat/v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=bin/protoc-gen-go-grpc \
	api/chat/v1/chat.proto

build:
	GOOS=linux GOARCH=amd64 go build -o bin/service_linux cmd/main.go

copy-binary-to-server:
	scp -i ~/.ssh/microservice-course-deploy bin/service_linux root@95.213.248.247:

docker-build-and-push:
	docker buildx build --no-cache --platform linux/amd64 -t cr.selcloud.ru/course/chat-server:v0.0.1 .
	docker login -u token -p CRgAAAAAKdNv7uHvhztf5eIV7HR9EeyR3ltthoNc cr.selcloud.ru/course
	docker push cr.selcloud.ru/course/chat-server:v0.0.1
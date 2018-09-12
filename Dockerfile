FROM golang:1.10.3 as build-stage
ENV SOURCE_DIR /go/src/github.com/robwil/stats-tester
ENV BUILD_DIR $SOURCE_DIR/build
COPY . $SOURCE_DIR
WORKDIR $SOURCE_DIR
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a --installsuffix cgo -o $BUILD_DIR/stats-tester

FROM alpine:3.7 as prod
RUN apk --no-cache add ca-certificates tzdata
ENV SOURCE_DIR /go/src/github.com/robwil/stats-tester
ENV BUILD_DIR $SOURCE_DIR/build
ENV BINARY_DEST /usr/local/bin/stats-tester
WORKDIR $SOURCE_DIR
COPY --from=build-stage $BUILD_DIR/stats-tester $BINARY_DEST
RUN chmod ugo+x $BINARY_DEST
ENTRYPOINT ["stats-tester"]

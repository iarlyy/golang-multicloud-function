package main

import (
	"context"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/iarlyy/golang-multicloud-function/function"
)

func HandleRequest(ctx context.Context, msg function.MsgPayload) (function.MsgPayload, error) {
	res_msg := msg.Process()

	return res_msg, nil
}

func main() {
	lambda.Start(HandleRequest)
}

echo "\n"
echo BUCKETS
aws --endpoint-url=http://localhost:4566 s3 ls

echo "\n"
echo BUCKETS OBJECTS
aws --endpoint-url=http://localhost:4566 s3 ls s3://temp/queue
aws --endpoint-url=http://localhost:4566 s3 ls s3://temp/default

echo "\n"
echo LAMBDA FUNCTIONS
aws --endpoint-url=http://localhost:4566 lambda list-functions | jq .Functions[].FunctionName

echo "\n"
echo DYNAMODB TABLES
aws --endpoint-url=http://localhost:4566 dynamodb list-tables | jq .TableNames

echo "\n"
echo TABLE ITENS
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name catalog | jq .Items

echo "\n"
echo SQS QUEUES
aws --endpoint-url=http://localhost:4566 sqs list-queues | jq .QueueUrls

echo "\n"
echo SQS QUEUES MESSAGES
aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/temp-queue | jq .Messages

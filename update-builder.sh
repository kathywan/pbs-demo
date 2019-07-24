
if [ ! $# -eq 1 ]; then
  echo "Must supply builder tag"
  exit 1
fi
tag=$1
export DOCKERHUB_BUILDER_NAME=docker.io/kathywan/cf-build-service-dev-219913-build-service-builders-p-builder-08a87070945c7177ae30c35d16d0f4ed:latest
docker pull matthewmcnew/builder:$tag
docker tag matthewmcnew/builder:$tag $DOCKERHUB_BUILDER_NAME
docker push $DOCKERHUB_BUILDER_NAME

curl -v -X POST https://build-service.cupertino.cf-app.com/v1/docker/webhook -H "Content-Type: application/json" -d '{ "push_data": { "tag": "latest" }, "repository": { "repo_name": "docker.io/kathywan/cf-build-service-dev-219913-build-service-builders-p-builder-08a87070945c7177ae30c35d16d0f4ed" } }' -k
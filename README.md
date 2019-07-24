## Pivotal Build Service Demo

```
pb api set https://build-service.cupertino.cf-app.com --skip-ssl-validation

pb login

pb team apply -f kwan-team.yaml
pb image apply -f spring-petclinic-img.yaml 

pb image builds kathywan/spring-petclinic-image
pb image logs kathywan/spring-petclinic-image -b 1 -f
pb image delete kathywan/spring-petclinic-image

#run application locally
docker pull kathywan/spring-petclinic-image

docker run -p 8081:8080 kathywan/spring-petclinic-image

//check current buildpacks in application image
docker inspect kathywan/spring-petclinic-image | jq '.[0].Config.Labels."io.buildpacks.lifecycle.metadata" | fromjson | .buildpacks[0].layers’

//Figure out the name of the builder that was deployed to dockerhub
kubectl get builders -n build-service-builds build-service-builder -o yaml
kubectl get builders --all-namespaces -o json | jq ".items | .[0].spec.image”

//webhook API call from image registry 
curl -v -X POST https://build-service.cupertino.cf-app.com/v1/docker/webhook -H "Content-Type: application/json" -d '{ "push_data": { "tag": "latest" }, "repository": { "repo_name": "docker.io/kathywan/cf-build-service-dev-219913-build-service-builders-p-builder-08a87070945c7177ae30c35d16d0f4ed" } }' -k

//use script to update builder image and trigger webhook through api call (I need to use this because of self-signed cert I used with installing PBS. Docker can only work with webhook API which used CA authrized cert. In that case, you can easily add this to your registry repository)

../update-builder.sh 7 
//above will update builder image that has openJDK 11.0.2 buildpack. Image building should be triggered automatically

../update-builder.sh 8
//above will update builder image that has openJDK 11.0.2 buildpack. Image building should be triggered automatically


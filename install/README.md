## Install PBS on PKS 

- Used toolsmith to get a PKS env on my GCP account
- Created a cluster `pbcluster`

- Referred doc
    * [Customer facing doc](https://github.com/pivotal-cf/docs-build-service/blob/master/installing.md)
    * [Dev doc](https://github.com/pivotal/build-service/blob/master/installation_procedure.md)

- Target uaac to pks uaa
uaac target https://api.pks.cupertino.cf-app.com:8443 --ca-cert root_ca_certificate
- Login uaa as user management admin user
```
uaac token client get admin -s <REDACTED>
```
- install the UAA Client for pb cli
```
uaac client add pb_cli --scope="openid" --secret="" --authorized_grant_types="password,refresh_token" --access_token_validity 600 --refresh_token_validity 21600
```
- Create a UAA user for use with PBS
```
uaac user add pbsuser -p pbsuser --email pbsuser@mydomain.com
```
- Clone https://github.com/pivotal/build-service
- Create ingress controller 
```
kubectl apply -f deployments/ingress-controller/nginx-ingress.yaml
```
- Create a static IP on GCP to be used for ingress service
- Create service in k8s for ingress 
```
kubectl apply -f nginx-ingress-svc.yaml
```

- Create cert for PBS
```
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out cert.crt -keyout key.key
```
NOTES: For MacOS, when using pb cli the CA certificate should be added to the keychain and the Trust setting must be changed to Always Trust instead of Use System Defaults

- Use the cert to create secret in k8s
```
$ export tlsCert=$(cat /Users/qwan/workspace/pivotal-build-service/cert.crt | base64)
$ export tlsKey=$(cat /Users/qwan/workspace/pivotal-build-service/key.key | base64)
$ cat << EOF| kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: build-service-certificate
  namespace: default
data:
  tls.crt: $tlsCert
  tls.key: $tlsKey
type: kubernetes.io/tls
EOF
```

- Download from pivnet bundle, duffle (install to /usr/local/bin, make sure to use the version matching bundle, not backward compatible)
- Create a credentials.yml file (credentials.yml)
    * Export cert from docker.io:
```
$ echo | openssl s_client -showcerts -servername index.docker.io -connect index.docker.io:443 2>/dev/null | openssl x509 -inform pem -text -out index.docker.io.crt
```
- Import bundle into local folder
- “Docker login” to docker hub
- Push the images to the Image Registry kathywan on docker hub
```
duffle relocate -f ./build-service/bundle.json -m ./relocated.json -p kathywan
```
- Install Pivotal Build Service

```
duffle install pbstest -c ./credentials.yml  \
    --set domain="build-service.cupertino.cf-app.com" \
    --set kubernetes_env=pbcluster \
    --set docker_registry="https://index.docker.io/v1/" \
    --set registry_username=kathywan \
    --set registry_password=<REACTED> \
    --set uaa_url="https://api.pks.cupertino.cf-app.com:8443" \
    -f ./build-service/bundle.json \
    -m ./relocated.json
```

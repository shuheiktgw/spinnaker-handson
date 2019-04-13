# Dockerのセットアップ

cd
PROJECT_ID=[GCP Project ID]

gcloud auth configure-docker

cd spinnaker-handson
docker build --tag asia.gcr.io/$PROJECT_ID/spinnaker-handson:v1.0.0 .
docker push asia.gcr.io/$PROJECT_ID/spinnaker-handson:v1.0.0

gcloud container images list-tags asia.gcr.io/$PROJECT_ID/spinnaker-handson

# Applicationの作成

EMAIL=[Your Email Address]
sed -i "s/EMAIL/$EMAIL/g" ~/spinnaker-handson/spinnaker/ch4/application.json
spin application save --file ~/spinnaker-handson/spinnaker/ch4/application.json

spin application get spinnaker-handson

# Pipelineの作成

PROJECT_ID=[GCP Project ID]
sed -i "s/PROJECT_ID/$PROJECT_ID/g" ~/spinnaker-handson/spinnaker/ch4/deploy-pipeline.json

spin pipeline save --file ~/spinnaker-handson/spinnaker/ch4/deploy-pipeline.json

# Pipelineの実行

kubectl get pods
kubectl get services

kubectl run requester --image=alpine -- \
    /bin/sh -c "apk add --update --no-cache curl; \
    curl -sS http:///production-app:8080"

REQUESTER=$(kubectl get pods --selector run=requester --output=jsonpath='{.items[0].metadata.name}')
kubectl logs $REQUESTER

kubectl delete deployment requester

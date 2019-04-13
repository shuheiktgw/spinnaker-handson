# Dockerの自動化

cd ~/spinnaker-handson
sed -i "s/v1.0.0/v1.1.0/g" main.go

git config --global user.email [Your Email Address]
git config --global user.name [Your User Name]

REPO_NAME=spinnaker-handson

gcloud source repos create $REPO_NAME
git config credential.helper gcloud.sh

PROJECT_ID=[GCP Project ID]
git remote set-url origin \
https://source.developers.google.com/p/$PROJECT_ID/r/$REPO_NAME

git commit -am 'Update message'
git tag v1.1.0

# Pipeline Triggerの設定

gcloud services enable cloudresourcemanager.googleapis.com

PROJECT_ID=[GCP Project ID]
sed -i "s/PROJECT_ID/$PROJECT_ID/g" ~/spinnaker-handson/spinnaker/ch5/deploy-pipeline.json

spin pipeline save --file ~/spinnaker-handson/spinnaker/ch5/deploy-pipeline.json

#Pipelineの動作確認

git push origin master
git push --tag

kubectl run requester --image=alpine -- \
    /bin/sh -c "apk add --update --no-cache curl; \
    curl -sS http:///production-app:8080"

REQUESTER=$(kubectl get pods --selector run=requester \
    --output=jsonpath='{.items[0].metadata.name}')

kubectl logs $REQUESTER
# Pipelineの変更

PROJECT_ID=[GCP Project ID]
sed -i "s/PROJECT_ID/$PROJECT_ID/g" ~/spinnaker-handson/spinnaker/ch7/deploy-pipeline.json

spin pipeline save --file ~/spinnaker-handson/spinnaker/ch7/deploy-pipeline.json

# Pipeline の実行

sed -i "s/v1.2.0/v1.3.0/g" ~/spinnaker-handson/main.go

cd ~/spinnaker-handson
git commit -am 'Update message'
git push origin master

git tag v1.3.0
git push --tag

kubectl run requester --image=alpine -- \
    /bin/sh -c "apk add --update --no-cache curl; \
    curl -sS http:///production-app:8080"

REQUESTER=$(kubectl get pods --selector run=requester \
      --output=jsonpath='{.items[0].metadata.name}')

kubectl logs $REQUESTER

kubectl delete deployment requester
# Pipelineの変更

PROJECT_ID=[GCP Project ID]
sed -i "s/PROJECT_ID/$PROJECT_ID/g" ~/spinnaker-handson/spinnaker/ch6/deploy-pipeline.json

spin pipeline save --file ~/spinnaker-handson/spinnaker/ch6/deploy-pipeline.json

# Pipelineの実行

cd ~/spinnaker-handson
sed -i "s/v1.1.0/v1.2.0/g" main.go

git commit -am 'Update message'
git push origin master

git tag v1.2.0
git push --tag

kubectl run requester --image=alpine -- \
    /bin/sh -c "apk add --update --no-cache curl; \
    curl -sS http:///production-app:8080"

REQUESTER=$(kubectl get pods --selector run=requester \
      --output=jsonpath='{.items[0].metadata.name}')

kubectl logs $REQUESTER

kubectl delete deployment requester
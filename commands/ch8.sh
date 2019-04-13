# 手動カナリア分析の実行

sed -i "s/v1.3.0/v1.4.0/g" ~/spinnaker-handson/main.go

cd ~/spinnaker-handson
git commit -am 'Update message'
git push origin

git tag v1.4.0
git push --tag

kubectl run requester --image=alpine --replicas=3 \
    -- /bin/sh -c "apk add --no-cache curl; \
    while true; do curl -sS --max-time 3 \
    http://production-app:8080/; done"

REQUESTER=$(kubectl get pods --selector run=requester \
    --output=jsonpath='{.items[0].metadata.name}')

kubectl logs $REQUESTER

# Kayentaのセットアップ

cd

SERVICE_ACCOUNT_NAME=spinnaker-monitoring-admin
JSON_PATH=spinnaker-monitoring-admin.json

gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT_ID=[GCP Project ID]

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --role roles/monitoring.admin \
    --member serviceAccount:$EMAIL

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --role roles/storage.admin \
    --member serviceAccount:$EMAIL

gcloud iam service-accounts keys create $JSON_PATH --iam-account $EMAIL

JSON_PATH=spinnaker-monitoring-admin.json
HALYARD=$(kubectl get pods \
    --namespace spinnaker \
    --selector component=halyard \
    --output=jsonpath='{.items[0].metadata.name}')

kubectl cp $JSON_PATH spinnaker/$HALYARD:/tmp/$JSON_PATH

kubectl exec --namespace spinnaker -it $HALYARD bash

hal config canary enable
hal config canary google enable

PROJECT_ID=[GCP Project ID]

hal config canary google account add monitoring-admin \
    --project $PROJECT_ID \
    --json-path /tmp/spinnaker-monitoring-admin.json \
    --bucket spinnaker-handson-config


hal config canary google edit \
    --gcs-enabled true \
    --stackdriver-enabled true

hal deploy apply

# 自動カナリア分析のセットアップ

cd ~/spinnaker-handson
git commit -am 'Update message'
git push origin master

git tag v1.5.0
git push --tag

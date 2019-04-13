# Kubernetesクラスタの作成

gcloud config set project [GCP Project ID]
gcloud config set compute/zone asia-northeast1-a

gcloud services enable container.googleapis.com

gcloud beta container clusters create spinnaker-handson \
    --enable-stackdriver-kubernetes \
    --machine-type=n1-standard-2

gcloud container clusters get-credentials spinnaker-handson
kubectl get nodes

# GKEクラスタを停止する

gcloud container clusters resize spinnaker-handson --size=0
gcloud container clusters resize spinnaker-handson --size=3

# Helmのセットアップ

wget https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz
tar zxfv helm-v2.13.1-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm


kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding \
    tiller-cluster-admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller

helm init --service-account=tiller
helm repo update
kubectl get pods --namespace kube-system --selector "name=tiller"
helm version

# ストレージのセットアップ

SERVICE_ACCOUNT_NAME=spinnaker-storage-admin
JSON_PATH=spinnaker-storage-admin.json

gcloud iam service-accounts create \
  $SERVICE_ACCOUNT_NAME \
  --display-name $SERVICE_ACCOUNT_NAME

EMAIL=$(gcloud iam service-accounts list \
  --filter="displayName:$SERVICE_ACCOUNT_NAME" \
  --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
  --role roles/storage.admin \
  --member serviceAccount:$EMAIL

gcloud iam service-accounts keys create $JSON_PATH \
    --iam-account $EMAIL

gsutil mb -c regional -l asia-northeast1 gs://spinnaker-handson-config

# Spinnakerのデプロイ

KEY=$(cat spinnaker-storage-admin.json)
BUCKET=spinnaker-handson-config
PROJECT=$(gcloud info --format='value(config.project)')
cat > config.yaml <<EOF
gcs:
  enabled: true
  project: $PROJECT
  bucket: $BUCKET
  jsonKey: '$KEY'

minio:
  enabled: false

dockerRegistries:
- name: gcr
  address: asia.gcr.io
  username: _json_key
  password: '$KEY'
EOF

helm install stable/spinnaker \
    --version 1.8.1 \
    --name spinnaker \
    --timeout 600 \
    --namespace spinnaker \
    --values config.yaml

kubectl get pods --namespace spinnaker

# Web UIへ接続する

DECK=$(kubectl get pods \
    --namespace spinnaker \
    --selector "cluster=spin-deck" \
    --output jsonpath="{.items[0].metadata.name}")

kubectl port-forward --namespace spinnaker $DECK 8080:9000 >> /dev/null &
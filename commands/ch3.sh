# Spinのセットアップ

cd
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/1.6.0/linux/amd64/spin
chmod +x spin
sudo cp spin /usr/local/bin/spin

spin --version

mkdir ~/.spin/
cat > ~/.spin/config <<EOF
gate:
  endpoint: http://localhost:8080/gate
EOF

spin application list

# Applicationの作成

cd
git clone https://github.com/shuheiktgw/spinnaker-handson.git

EMAIL=[Your Email Address]
sed -i "s/EMAIL/$EMAIL/g" \
    ~/spinnaker-handson/spinnaker/ch3/sample-application.json

spin application save \
    --file ~/spinnaker-handson/spinnaker/ch3/sample-application.json


spin application get sample-application

# 1層のPipeline

spin pipeline save \
    --file ~/spinnaker-handson/spinnaker/ch3/one-layer-pipeline.json

# 2層のPipeline
spin pipeline save \
    --file ~/spinnaker-handson/spinnaker/ch3/two-layers-pipeline.json

# 3層のPipeline
spin pipeline save \
    --file ~/spinnaker-handson/spinnaker/ch3/three-layers-pipeline.json

# パラメーターPipeline
spin pipeline save \
    --file ~/spinnaker-handson/spinnaker/ch3/configurable-pipeline.json
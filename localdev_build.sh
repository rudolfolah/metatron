git submodule update --init --recursive
(cd piper && docker buildx build --target build -t piper:latest .)
docker build --target localdev -t metatron-api:localdev -f ./Dockerfile-api .
docker build --target localdev -t metatron-piper:localdev -f ./Dockerfile-piper .

docker compose up -d || exit 1
docker compose exec -w /dist/api api npm install
docker compose exec -w /dist/worker piper npm install
screen -dmS metatron -t api /bin/bash -c 'docker compose exec -w /dist/api api sh -c bash'
screen -S metatron -X screen -t piper /bin/bash -c 'docker compose exec -w /dist/worker piper sh -c bash'
echo 'Start in a screen session with:'
echo 'screen -r metatron'

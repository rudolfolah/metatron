docker compose up -d || exit 1
docker compose exec -w /dist/api api npm install
docker compose exec -w /dist/worker piper npm install
docker compose exec -d -w /dist/api api npm start
docker compose exec -d -w /dist/worker piper npm start

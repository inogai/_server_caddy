set dotenv-filename := ".env"
set export := true

# build:
#   docker buildx bake
#
# publish:
#   docker buildx bake --push

deploy:
  scp -P ${REMOTE_PORT} compose.yml ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/compose.yml
  scp -rP ${REMOTE_PORT} caddy/* ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/caddy/
  scp -P ${REMOTE_PORT} .env.prod   ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/.env
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} -t "cd ${REMOTE_DIR} && docker compose pull && docker compose up -d"
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} -t "cd ${REMOTE_DIR} && docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile"

test-chrome:
  chromium --user-data-dir=/tmp/chrome-test-profile --host-resolver-rules="MAP *.inogai.com 127.0.0.1" "wakapi.inogai.com"
  rm -rf /tmp/chrome-test-profile

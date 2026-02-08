set dotenv-filename := ".env"
set export := true

# build:
#   docker buildx bake
#
# publish:
#   docker buildx bake --push

deploy:
  rsync -avz -e "ssh -p ${REMOTE_PORT}" \
    compose.yml caddy litellm .env.prod \
    ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "mv ${REMOTE_DIR}/.env.prod ${REMOTE_DIR}/.env"
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} -t "cd ${REMOTE_DIR} && docker compose pull && docker compose up -d"
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} -t "cd ${REMOTE_DIR} && docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile"

test-chrome:
  chromium --user-data-dir=/tmp/chrome-test-profile --host-resolver-rules="MAP *.inogai.com 127.0.0.1" "wakapi.inogai.com"
  rm -rf /tmp/chrome-test-profile

download_backups:
  rsync -avz -e "ssh -p ${REMOTE_PORT}" \
    ${REMOTE_USER}@${REMOTE_HOST}:~/archive ./archive/

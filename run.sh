docker run -d \
-e 'POSTGRES_PASSWORD=q1' \
--name cc-db \
library/postgres:10.4

docker run -d \
-p 8001:8001 \
--name cc-server \
--link cc-db \
-v %cd%:/wkDir/server.conf:/opt/concord/conf/server.conf:ro \
-e CONCORD_CFG_FILE=/opt/concord/conf/server.conf \
walmartlabs/concord-server

docker run -d --name cc-ldap --network=container:server osixia/openldap
cat myuser.ldif | docker exec -i cc-ldap ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin

docker run -d \
--name cc-agent \
--link cc-server \
-e SERVER_API_BASE_URL=http://server:8001 \
walmartlabs/concord-agent

docker run -d -p 8080:8080 \
--name cc-console \
--link cc-server \
-v "/path/to/repo/docker-images/console.conf:/opt/concord/console/nginx/app.conf:ro" \
walmartlabs/concord-console

#!/bin/bash

#Compilacion y empaquetado del código fuente en WAR.
#Luego copia dicho codigo al directorio TOMCAT_ROOT para su ejecucion.

set -e  # Salir si hay error

####################################
# VARIABLES BACKEND
####################################
PROJECT_DIR="/tmp/iw3_final"
GIT_REPO="https://github.com/eponce744/iw3_final.git"
GIT_BRANCH="main"
DOCKER_COMPOSE_FILE="/home/user/infra_iw32025/docker-compose.yml"
TOMCAT_ROOT="/home/user/infra_iw32025/tomcat/webapps/ROOT"

echo "=============================="
echo "DEPLOY BACKEND"
echo "=============================="

# Clonar backend
cd /tmp
rm -rf "$PROJECT_DIR"
git clone -b "$GIT_BRANCH" "$GIT_REPO" "$PROJECT_DIR"

# Build backend con Maven (en Docker)
docker run --rm \
  -v "$HOME/.m2:/root/.m2" \
  -v "$PROJECT_DIR:/usr/src/mymaven" \
  -w /usr/src/mymaven \
  maven:3.9.11-amazoncorretto-21-debian \
  mvn clean package -Dmaven.test.skip=true

# Permisos WAR
chmod 664 "$PROJECT_DIR/target/ROOT.war"

# Detener backend
docker compose -f "$DOCKER_COMPOSE_FILE" stop backend

# Limpiar ROOT
rm -rf "$TOMCAT_ROOT"
mkdir -p "$TOMCAT_ROOT"

# Deploy WAR
mv "$PROJECT_DIR/target/ROOT.war" "$TOMCAT_ROOT/ROOT.zip"
cd "$TOMCAT_ROOT"
unzip -q ROOT.zip
rm ROOT.zip

# Levantar todo
docker compose -f "$DOCKER_COMPOSE_FILE" up -d

echo "=============================="
echo "DEPLOY COMPLETADO OK"
echo "=============================="

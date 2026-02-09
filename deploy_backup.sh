#!/bin/bash
set -e  # Salir si hay algún error

# Variables
PROJECT_DIR="/tmp/iw3_final"
GIT_REPO="https://github.com/eponce744/iw3_final.git"
GIT_BRANCH="main"
DOCKER_COMPOSE_FILE="/home/user/infra_iw32025/docker-compose.yml"
TOMCAT_ROOT="/home/user/infra_iw32025/tomcat/webapps/ROOT"

# Limpiar y clonar repo
cd /tmp
rm -rf "$PROJECT_DIR"
git clone -b "$GIT_BRANCH" "$GIT_REPO"

# Construir con Maven
docker run -it --rm \
    -v "$HOME/.m2:/root/.m2" \
    -v "$PROJECT_DIR:/usr/src/mymaven" \
    -w /usr/src/mymaven \
    maven:3.9.11-amazoncorretto-21-debian \
    mvn clean package -Dmaven.test.skip=true

# Ajustar permisos del WAR
sudo chmod 664 "$PROJECT_DIR/target/ROOT.war"
sudo chown "$USER" "$PROJECT_DIR/target/ROOT.war"

# Detener backend y limpiar ROOT
docker compose -f "$DOCKER_COMPOSE_FILE" stop backend
rm -rf "$TOMCAT_ROOT"
mkdir -p "$TOMCAT_ROOT"

# Mover WAR a Tomcat y descomprimir
sudo mv "$PROJECT_DIR/target/ROOT.war" "$TOMCAT_ROOT/ROOT.zip"
cd "$TOMCAT_ROOT"
unzip ROOT.zip
rm ROOT.zip

# Iniciar backend
docker compose -f "$DOCKER_COMPOSE_FILE" start backend

echo "Despliegue completado."

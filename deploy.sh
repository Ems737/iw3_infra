#!/bin/bash

#Compilacion y empaquetado del código fuente en WAR.
#Luego copia dicho codigo al directorio TOMCAT_ROOT para su ejecucion.

set -e  # Salir si hay error

####################################
# VARIABLES BACKEND
####################################
#PROJECT_DIR="/tmp/iw3_final"
GIT_REPO="https://github.com/eponce744/iw3_final.git"
GIT_BRANCH="main"
DOCKER_COMPOSE_FILE="/home/user/infra_iw32025/docker-compose.yml"
TOMCAT_ROOT="/home/user/infra_iw32025/tomcat/webapps/ROOT"

echo "=============================="
echo "DEPLOY BACKEND"
echo "=============================="

# Clonar backend
cd /tmp
rm -rf /tmp/iw3_final
git clone -b "$GIT_BRANCH" "$GIT_REPO"

# Build backend con Maven (en Docker)
docker run -it --rm -v "$HOME/.m2:/root/.m2" -v /tmp/iw3_final:/usr/src/mymaven -w /usr/src/mymaven maven:3.9.11-amazoncorretto-21-debian mvn clean package -Dmaven.test.skip=true -Dbuild=war -Dspring.profiles.active=mysqlprod

# Permisos WAR
sudo chmod 664 "iw3_final/target/ROOT.war"
sudo chown $USER "/tmp/iw3_final/target/ROOT.war"

# Detener backend
docker compose -f "$DOCKER_COMPOSE_FILE" stop backend

# Limpiar ROOT
rm -rf "$TOMCAT_ROOT"
mkdir -p "$TOMCAT_ROOT"

# Deploy WAR
sudo mv "/tmp/iw3_final/target/ROOT.war" "$TOMCAT_ROOT/ROOT.zip"
cd "$TOMCAT_ROOT"
unzip ROOT.zip
rm ROOT.zip

echo "=============================="
echo "DEPLOY FRONTEND"
echo "=============================="

####################################
# VARIABLES FRONTEND
####################################
FRONTEND_DIR="/home/user/infra_iw32025/frontend"
GIT_FRONTEND_REPO="https://github.com/SofiaSuppia/Frontend-IW3-final.git"
GIT_FRONTEND_BRANCH="main"

# Actualizar Frontend
cd /home/user/infra_iw32025
rm -rf "$FRONTEND_DIR"
git clone -b "$GIT_FRONTEND_BRANCH" "$GIT_FRONTEND_REPO" "$FRONTEND_DIR"
/home/user/infra_iw32025/frontend/Frontend/buildImage.sh

# Levantar todo
docker compose -f "$DOCKER_COMPOSE_FILE" up -d

echo "=============================="
echo "DEPLOY COMPLETADO OK"
echo "=============================="

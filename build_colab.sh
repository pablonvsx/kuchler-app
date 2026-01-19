#!/bin/bash
# Script para compilar KuchlerApp no Google Colab
# Execute este script em uma célula do Colab com: !bash build_colab.sh

set -e  # Encerra em caso de erro

echo "=========================================="
echo "   KuchlerApp - Build para Android"
echo "=========================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Instalar dependências do sistema
echo -e "${BLUE}[1/6]${NC} Instalando dependências do sistema..."
sudo apt-get update -qq > /dev/null 2>&1
sudo apt-get install -y \
    python3-pip \
    build-essential \
    git \
    ffmpeg \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    libportmidi-dev \
    libswscale-dev \
    libavformat-dev \
    libavcodec-dev \
    zlib1g-dev \
    libgstreamer1.0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    openjdk-17-jdk \
    unzip \
    > /dev/null 2>&1

echo -e "${GREEN}✓${NC} Dependências do sistema instaladas"

# 2. Configurar variáveis de ambiente
echo -e "${BLUE}[2/6]${NC} Configurando variáveis de ambiente..."
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
export ANDROID_HOME="$HOME/.buildozer/android/platform/android-sdk"
export ANDROID_NDK_HOME="$HOME/.buildozer/android/platform/android-ndk-r25b"
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

echo -e "${GREEN}✓${NC} Variáveis de ambiente configuradas"

# 3. Instalar buildozer e dependências Python
echo -e "${BLUE}[3/6]${NC} Instalando buildozer e dependências Python..."
pip install --upgrade pip > /dev/null 2>&1
pip install buildozer cython==0.29.33 > /dev/null 2>&1

echo -e "${GREEN}✓${NC} Buildozer instalado"

# 4. Limpar builds anteriores (opcional)
echo -e "${BLUE}[4/6]${NC} Limpando builds anteriores..."
if [ -d ".buildozer" ]; then
    echo -e "${YELLOW}⚠${NC} Removendo diretório .buildozer anterior..."
    rm -rf .buildozer
fi
if [ -d "bin" ]; then
    echo -e "${YELLOW}⚠${NC} Removendo diretório bin anterior..."
    rm -rf bin
fi

echo -e "${GREEN}✓${NC} Limpeza concluída"

# 5. Verificar arquivos necessários
echo -e "${BLUE}[5/6]${NC} Verificando arquivos necessários..."
if [ ! -f "buildozer.spec" ]; then
    echo -e "${RED}✗${NC} Erro: buildozer.spec não encontrado!"
    exit 1
fi
if [ ! -f "main.py" ]; then
    echo -e "${RED}✗${NC} Erro: main.py não encontrado!"
    exit 1
fi
if [ ! -f "interface.kv" ]; then
    echo -e "${RED}✗${NC} Erro: interface.kv não encontrado!"
    exit 1
fi

echo -e "${GREEN}✓${NC} Todos os arquivos necessários presentes"

# 6. Compilar o APK
echo -e "${BLUE}[6/6]${NC} Compilando APK (isso pode levar 15-30 minutos)..."
echo -e "${YELLOW}⏳${NC} Por favor, aguarde..."
echo ""

buildozer android debug

# Verificar se o APK foi gerado
if [ -f "bin/*.apk" ]; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo -e "   ✓ BUILD CONCLUÍDO COM SUCESSO!"
    echo -e "==========================================${NC}"
    echo ""
    echo "APK gerado em:"
    ls -lh bin/*.apk
    echo ""
    echo "Para baixar o APK no Colab, execute:"
    echo -e "${YELLOW}from google.colab import files${NC}"
    echo -e "${YELLOW}files.download('bin/kuchlerapp-1.0.0-arm64-v8a-debug.apk')${NC}"
else
    echo ""
    echo -e "${RED}=========================================="
    echo -e "   ✗ ERRO AO GERAR APK"
    echo -e "==========================================${NC}"
    echo ""
    echo "Verifique os logs acima para mais detalhes"
    exit 1
fi

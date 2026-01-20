#!/bin/bash
# Script otimizado para compilar KuchlerApp no Google Colab
# Execute este script em uma célula do Colab

set -e

echo "==========================================="
echo "  KuchlerApp - Compilação Android (Colab)"
echo "==========================================="
echo ""

# 1. Instalar dependências do sistema
echo "[1/5] Instalando dependências do sistema..."
apt-get update -qq
apt-get install -y -qq \
    openjdk-17-jdk \
    build-essential \
    git \
    zip \
    unzip \
    ccache \
    autoconf \
    libtool \
    pkg-config \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libtinfo5 \
    cmake \
    libffi-dev \
    libssl-dev

echo "✓ Dependências instaladas"

# 2. Configurar variáveis de ambiente Java
echo "[2/5] Configurando ambiente Java..."
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

echo "✓ Java configurado: $(java -version 2>&1 | head -n 1)"

# 3. Instalar Buildozer e Cython
echo "[3/5] Instalando Buildozer e Cython..."
pip install -q --upgrade pip setuptools wheel
pip install -q --upgrade buildozer
pip install -q --upgrade cython==0.29.36

echo "✓ Buildozer $(buildozer --version) instalado"

# 4. Limpar builds anteriores
echo "[4/5] Limpando builds anteriores..."
rm -rf .buildozer bin
mkdir -p bin

echo "✓ Ambiente limpo"

# 5. Compilar APK
echo "[5/5] Iniciando compilação do APK..."
echo "⏳ Este processo levará entre 20-40 minutos..."
echo "⏳ Aguarde pacientemente, não interrompa o processo!"
echo ""

# Executar buildozer com opções otimizadas
yes | buildozer -v android debug

# Verificar resultado
echo ""
echo "==========================================="
if ls bin/*.apk 1> /dev/null 2>&1; then
    echo "✅ BUILD CONCLUÍDO COM SUCESSO!"
    echo "==========================================="
    echo ""
    APK_FILE=$(ls bin/*.apk | head -n 1)
    echo "📦 APK gerado: $APK_FILE"
    echo "📊 Tamanho: $(du -h "$APK_FILE" | cut -f1)"
    echo ""
    echo "Para baixar o APK, execute na próxima célula:"
    echo ""
    echo "from google.colab import files"
    echo "files.download('$APK_FILE')"
    echo ""
else
    echo "❌ ERRO: APK não foi gerado!"
    echo "==========================================="
    echo ""
    echo "Verifique os logs acima para identificar o problema."
    echo "Erros comuns:"
    echo "  - Falta de memória (reinicie o runtime)"
    echo "  - Timeout de rede (execute novamente)"
    echo "  - Erro em dependências (verifique requirements)"
    exit 1
fi

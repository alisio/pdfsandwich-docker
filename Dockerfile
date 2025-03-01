FROM ubuntu:noble

# Instalar dependências
RUN apt-get update && \
    apt-get install -y pdfsandwich && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /data

# Criar um ponto de entrada padrão
ENTRYPOINT ["pdfsandwich"]

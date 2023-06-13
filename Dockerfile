# Define a imagem base
FROM ubuntu:latest

# Define a versão do Node.js
ENV NODE_VERSION 18

# Atualiza o sistema e instala as dependências necessárias
RUN apt update && apt install -y curl gnupg gcc g++ make sudo systemctl

# Adiciona a chave GPG do Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt update && apt-get install -y nodejs

# Instala o Node.js e o npm
RUN apt update && apt install -y nodejs

# Instala o MongoDB a partir do repositório oficial
RUN curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

RUN apt update && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt install -y mongodb-org

# Cria o diretório de trabalho
WORKDIR /app

# Copia os arquivos necessários
COPY package.json package-lock.json /app/

# Instala as dependências do Node.js
RUN npm ci --production

# Copia o restante dos arquivos do projeto
COPY . /app

# Expõe a porta do servidor da aplicação
EXPOSE 80

# Executa o serviço do MongoDB
CMD systemctl start mongod && mongorestore --host=localhost:27017 --db=rickmorty --drop /app/test/data && npm start

# Usa a imagem da versão 20.18 do Node.js como base:
FROM node:20.18
# Executa o comando de instalação do pnpm:
RUN npm i -g pnpm
# Define uma área  de trablaho para a aplicação. Daqui em diante, a pasta raiz da aplicação dentro do container é a workdir. Isso é uma boa prática, pois separa os arquivos
# da aplicação dos arquivos presentes na pasta da raiz da imagem base (minsturá-los pode causar problemas): 
WORKDIR /usr/src/app
# Copia, para dentro do diretório raiz da aplicação dentro do container (workdir), somente os arquivos que são necessários para fazermos a instalação das dependências:
COPY package.json pnpm-lock.yaml ./
# Executa o comando que instala as dependências:
RUN pnpm install
# Copia, para dentro do diretório raiz da aplicação dentro do container (workdir), todos os arquivos que estão no mesmo diretório que o arquivo Dockerfile se encontra:
COPY . .
# Executa o comando que faz o build da aplicação:
RUN pnpm build
# Executa o comando que descarta as dependências de desenvolvimento:
RUN pnpm prune --prod
# Instrução que declara/cria uma variável de ambiente dentro do nosso container:
ENV CLOUDFLARE_ACCESS_KEY_ID="#"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="#"
ENV CLOUDFLARE_BUCKET="#"
ENV CLOUDFLARE_ACCOUNT_ID="#"
ENV CLOUDFLARE_PUBLIC_URL="http://localhost"
# Expõe a porta onde a aplicação executa dentro do container:
EXPOSE 3333
# Determina o comando que vai "segurar" a execução do container. Em outras palavras, o comando que vai manter o container executando:
CMD ["pnpm", "start"]
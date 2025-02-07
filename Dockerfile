# Usa a imagem da versão 20.18 do Node.js como base e cria um alias "base" para essa imagem com o pnpm instalado:
FROM node:20.18 AS base
# Executa o comando de instalação do pnpm:
RUN npm i -g pnpm

# Usa a imagem base + pnpm instalado como base para o próximo estágio e cria um alias "dependencies":
FROM base AS dependencies
# Define uma área  de trablaho para a aplicação. Daqui em diante, a pasta raiz da aplicação dentro do container é a workdir. Isso é uma boa prática, pois separa os arquivos
# da aplicação dos arquivos presentes na pasta da raiz da imagem base (minsturá-los pode causar problemas): 
WORKDIR /usr/src/app
# Copia, para dentro do diretório raiz da aplicação dentro do container (workdir), somente os arquivos que são necessários para fazermos a instalação das dependências:
COPY package.json pnpm-lock.yaml ./
# Executa o comando que instala as dependências:
RUN pnpm install

# Usa a imagem base + pnpm instalado como base para o próximo estágio e cria um alias "build":
FROM base AS build
# Cria um workdir com o mesmo path do estágio anterior (poderia ser outro path):
WORKDIR /usr/src/app
# Copia, para dentro do diretório raiz da aplicação dentro do container (workdir), todos os arquivos que estão no mesmo diretório que o arquivo Dockerfile se encontra:
COPY . .
# Copia, da imagem dependencies, a pasta node_modules e salva ele no diretório de trabalho:
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
# Executa o comando que faz o build da aplicação:
RUN pnpm build
# Executa o comando que descarta as dependências de desenvolvimento:
RUN pnpm prune --prod

# Usa a imagem de uma versão distroless do Node.js feita pelo Chainguard como base e cria um alias "deploy":
FROM cgr.dev/chainguard/node:latest AS deploy
# Popularmente, o USER 1000 é o nosso primeiro usuário linux com acesso não root. Estamos dizendo que queremos usar esse usuário para rodar o container com ele:
USER 1000
# Cria um workdir com o mesmo path do estágio anterior (poderia ser outro path):
WORKDIR /usr/src/app
# Copia, do estágio de build, a pasta que possui os arquivos de build e salva no diretório de trabalho:
COPY --from=build /usr/src/app/dist ./dist
# Copia, do estágio de build, a pasta que possui os arquivos de dependência e salva no diretório de trabalho:
COPY --from=build /usr/src/app/node_modules ./node_modules
# Copia, do estágio de build, a pasta que possui os arquivos de cofiguração e salva no diretório de trabalho:
COPY --from=build /usr/src/app/package.json ./package.json
# Instrução que declara/cria uma variável de ambiente dentro do nosso container:
ENV CLOUDFLARE_ACCESS_KEY_ID="#"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="#"
ENV CLOUDFLARE_BUCKET="#"
ENV CLOUDFLARE_ACCOUNT_ID="#"
ENV CLOUDFLARE_PUBLIC_URL="http://localhost"
# Expõe a porta onde a aplicação executa dentro do container:
EXPOSE 3333
# Determina o comando que vai "segurar" a execução do container. Em outras palavras, o comando que vai manter o container executando:
CMD ["dist/server.mjs"]
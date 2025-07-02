# Use uma imagem base oficial do Python.
# python:3.11-alpine é uma imagem ainda menor, ideal para produção.
FROM python:3.11-alpine

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Instala as dependências de sistema necessárias para compilar pacotes Python (como o psycopg2).
# O --virtual .build-deps cria um grupo temporário que pode ser removido em um único passo.
RUN apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev

# Copia o arquivo de dependências para o diretório de trabalho.
# Copiar este arquivo separadamente aproveita o cache de camadas do Docker.
COPY requirements.txt .

# Instala as dependências do projeto.
# Após a instalação, removemos as dependências de compilação para manter a imagem enxuta.
RUN pip install --no-cache-dir --upgrade -r requirements.txt \
    && apk del .build-deps

# Copia o restante do código da aplicação para o diretório de trabalho.
COPY . .

# Expõe a porta em que a aplicação será executada.
EXPOSE 8000

# Comando para executar a aplicação com Uvicorn.
# O host 0.0.0.0 torna a aplicação acessível de fora do contêiner.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
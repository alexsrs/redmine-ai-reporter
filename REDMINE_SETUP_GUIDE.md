# 🐳 Setup Redmine Local para Desenvolvimento

## Docker Compose para Redmine + PostgreSQL

Crie este arquivo como `docker-compose.yml` em uma pasta separada:

```yaml
version: "3.8"

services:
  redmine:
    image: redmine:5.1
    restart: always
    ports:
      - "3000:3000"
    environment:
      REDMINE_DB_POSTGRES: db
      REDMINE_DB_DATABASE: redmine
      REDMINE_DB_USERNAME: redmine
      REDMINE_DB_PASSWORD: redmine_password
      REDMINE_SECRET_KEY_BASE: supersecretkey
    volumes:
      - redmine_data:/usr/src/redmine/files
    depends_on:
      - db

  db:
    image: postgres:13
    restart: always
    environment:
      POSTGRES_DB: redmine
      POSTGRES_USER: redmine
      POSTGRES_PASSWORD: redmine_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  redmine_data:
  postgres_data:
```

## Comandos para executar:

```bash
# 1. Subir os containers
docker-compose up -d

# 2. Aguardar inicialização (pode demorar alguns minutos)
docker-compose logs -f redmine

# 3. Acessar Redmine
# URL: http://localhost:3000
# Login: admin
# Senha: admin
```

## Configurar API no Redmine:

1. Acesse: http://localhost:3000
2. Login: `admin` / Senha: `admin`
3. Vá em **Administração > Configurações**
4. Aba **API** > Marque **"Habilitar API REST"**
5. Salvar
6. Vá em **Minha conta > Chave de acesso da API**
7. Clique em **"Mostrar"** para ver a chave

Seus valores serão:

- **REDMINE_URL**: `http://localhost:3000`
- **REDMINE_API_KEY**: A chave gerada no passo 7

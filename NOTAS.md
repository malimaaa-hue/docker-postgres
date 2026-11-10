# Docker + PostgreSQL 

1. [O que é Docker com Postgres](#-o-que-é-docker-com-postgres)
2. [Estrutura do projeto](#-estrutura-do-projeto)
3. [docker-compose.yml](#-docker-composeyml)
4. [init.sql](#-initsql)
5. [Comandos usados](#-comandos-usados)

## O que é Docker com Postgres

**PostgreSQL** é um banco de dados relacional: guarda os dados em tabelas (linhas e colunas) e é consultado com SQL.

**Docker** roda programas dentro de **containers**, que são caixinhas isoladas com tudo que o programa precisa para funcionar. Em vez de instalar o Postgres na máquina (versão, configuração, senha...), o Docker sobe uma caixinha com o Postgres já pronto.

### Vantagens

- Qualquer pessoa roda do mesmo jeito: basta um `docker compose up`.
- Não suja a máquina. Se der problema, apaga o container e recria.
- É o padrão em microsserviços, que é o tema da disciplina.

### Termos importantes

| Termo | O que é |
| **Imagem** | O "molde" (ex: `postgres:16`), baixado do Docker Hub |
| **Container** | A imagem rodando de verdade |
| **Volume** | Pasta que guarda dados fora do container, pra não perder nada quando ele é recriado |
| **Compose** | Arquivo que descreve o que rodar, no lugar de um comando gigante |

## Estrutura do projeto

docker-postgres/
├── docker-compose.yml   # configuração do container
├── init.sql             # cria as tabelas
└── NOTAS.md             # este arquivo
```

## docker-compose.yml

```yaml
services:
  db:
    image: postgres:16
    container_name: postgres_sd
    restart: unless-stopped
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: loja
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql

volumes:
  pgdata:
```

### Linha por linha

| Linha | O que faz |
|---|---|
| `services:` | Lista dos serviços (containers) do projeto. Aqui só temos um |
| `db:` | Nome do serviço. É só um apelido |
| `image: postgres:16` | Usa a imagem oficial do Postgres, versão 16. Não precisa de Dockerfile porque a imagem já está pronta |
| `container_name: postgres_sd` | Nome fixo do container, usado nos comandos `docker exec` |
| `restart: unless-stopped` | Se o container cair ou o Docker reiniciar, sobe de novo sozinho (a menos que eu tenha parado de propósito) |
| `POSTGRES_USER` | Usuário do banco (`admin`) |
| `POSTGRES_PASSWORD` | Senha do usuário (`admin123`) |
| `POSTGRES_DB` | Nome do banco criado (`loja`) |
| `ports: "5432:5432"` | Liga a porta do meu PC à porta do container (`pc:container`). 5432 é a porta padrão do Postgres |
| `pgdata:/var/lib/postgresql/data` | Volume que guarda os dados do banco, pra não sumirem ao apagar o container |
| `./init.sql:/docker-entrypoint-initdb.d/init.sql` | Copia meu script pra uma pasta especial que o Postgres executa na primeira inicialização |
| `volumes: pgdata:` | Declara o volume para o Docker criar e gerenciar |

> **Observação:** as variáveis `POSTGRES_*` só são lidas na **primeira** inicialização do banco.

> **Segurança:** em projeto real a senha não fica escrita no arquivo. Usa-se um `.env`. Para a lição, tudo bem.

---

## 🗄️ init.sql

```
sql
CREATE TABLE usuario (
    id        SERIAL PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    email     VARCHAR(255) NOT NULL UNIQUE,
    senha     VARCHAR(255) NOT NULL,
    username  VARCHAR(50)  NOT NULL UNIQUE
);

CREATE TABLE cliente (
    id             VARCHAR(20) PRIMARY KEY,
    nome_fantasia  VARCHAR(150),
    razao_social   VARCHAR(150),
    cpf_cnpj       VARCHAR(18) NOT NULL UNIQUE,
    tipo           VARCHAR(10) NOT NULL CHECK (tipo IN ('FISICO', 'JURIDICO')),
    email          VARCHAR(255)
);

CREATE TABLE produto (
    id             SERIAL PRIMARY KEY,
    descricao      VARCHAR(255) NOT NULL,
    departamento   VARCHAR(100),
    codigo_barras  CHAR(13) NOT NULL UNIQUE,
    preco          NUMERIC(10,2) NOT NULL CHECK (preco >= 0)
);
```

### Conceitos de SQL usados

| Conceito | Significado |
|---|---|
| `CREATE TABLE` | Cria a tabela e suas colunas |
| `PRIMARY KEY` | Identificador único de cada linha (não repete e não pode ser nulo) |
| `SERIAL` | Inteiro que se autoincrementa (1, 2, 3...), então não precisa informar o id ao inserir |
| `VARCHAR(n)` | Texto de até `n` caracteres |
| `CHAR(13)` | Texto de tamanho fixo. Ideal para código de barras (EAN-13 sempre tem 13 dígitos) |
| `NOT NULL` | A coluna é obrigatória |
| `UNIQUE` | Impede valores repetidos (ex: dois usuários com o mesmo email) |
| `CHECK` | Regra que o dado precisa cumprir |
| `NUMERIC(10,2)` | Decimal exato: até 10 dígitos, com 2 casas depois da vírgula |

### Por que escolhi assim?

- **`senha` é `VARCHAR(255)`** porque na prática se guarda o **hash** da senha (texto embaralhado e irreversível), nunca a senha pura.
- **O `id` do cliente é `VARCHAR(20)`**, como o enunciado pediu. Quem insere define o valor (não é autoincremento).
- **`cpf_cnpj` tem 18 caracteres** pra caber o CNPJ com pontuação (`00.000.000/0000-00`).
- **O `CHECK` no `tipo`** só aceita `FISICO` ou `JURIDICO`.
- **`NUMERIC` no preço**, e não `float`, porque o float pode dar erro de arredondamento com dinheiro.
- **O `CHECK` no `preco`** não deixa inserir valor negativo.

---

## Comandos usados

| Comando | O que faz |
|---|---|
| `docker compose up -d` | Lê o compose, baixa a imagem se precisar, cria e inicia o container em segundo plano |
| `docker ps` | Lista os containers rodando |
| `docker exec -it postgres_sd psql -U admin -d loja -c "\dt"` | Roda um comando dentro do container: o `psql` (cliente do Postgres) lista as tabelas com `\dt` |
| `docker compose logs db` | Mostra os logs do serviço. Útil pra achar erros |
| `docker compose down` | Para e remove o container (os dados continuam no volume) |
| `docker compose down -v` | Para e remove o container **e o volume** (apaga os dados) |

### Passo a passo pra rodar

```bash
docker compose up -d
docker ps
docker exec -it postgres_sd psql -U admin -d loja -c "\dt"
```

O resultado esperado são as 3 tabelas: `usuario`, `cliente` e `produto`.

---


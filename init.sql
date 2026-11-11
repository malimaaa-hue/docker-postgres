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
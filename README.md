# tech-challenge-database

Infraestrutura Terraform da instância **RDS MySQL gerenciada**, compartilhada
entre a aplicação
[`tech-challenge-application`](https://github.com/eduNsantos/tech-challenge-application)
e a Function serverless de autenticação
[`tech-challenge-lambda-functions`](https://github.com/eduNsantos/tech-challenge-lambda-functions).

## Escopo

Este repositório provisiona **apenas o banco de dados**:

- `aws_db_instance` (MySQL 8.0, `db.t3.micro`) — `identifier` fixo
  `techchallenge-rds`, usado como referência estável pelos demais
  repositórios.
- `aws_db_subnet_group` para a instância.
- Uma regra de ingress adicional (`3306` liberado para toda a VPC) no
  Security Group `rds`.

A VPC, as subnets e o Security Group `rds` **não são criados aqui** — são
provisionados em
[`tech-challenge-kubernetes`](https://github.com/eduNsantos/tech-challenge-kubernetes)
e apenas referenciados via `data source` (nunca `resource`), para nunca
conflitar ou reverter configuração feita por aquele repositório. O racional
completo dessa separação em 4 repositórios está documentado em
`docs/Fase3/ADRs.docx` (ADR 0001) no repositório da aplicação.

## Stack

- Terraform `>= 1.9`
- Provider `hashicorp/aws ~> 6.0`
- Backend remoto: S3 (`techchallenge-tfstate`, key `database/terraform.tfstate`)
  + DynamoDB (`techchallenge-tf-locks`) para state e locking — compartilhado
  com `tech-challenge-lambda-functions`.

## Variáveis obrigatórias

| Variável      | Descrição                                                                                    |
| ------------- | --------------------------------------------------------------------------------------------- |
| `db_name`     | Nome do banco MySQL                                                                            |
| `db_password` | Senha do MySQL — precisa ser igual à usada em `tech-challenge-lambda-functions` e no Secret `app-secret` de `tech-challenge-kubernetes` |
| `db_user`     | Usuário do MySQL                                                                               |

Nenhuma tem valor default: defina-as em um `terraform.tfvars` local
(gitignorado) para uso manual, ou como secrets do repositório GitHub
(`TF_VAR_db_name`, `TF_VAR_db_user`, `TF_VAR_db_password`) para o CI/CD.

## CI/CD

`.github/workflows/deploy.yml`:

1. **validate** (todo push): `terraform fmt -check -recursive` +
   `terraform validate`.
2. **apply** (push em `main`): `terraform init` + `terraform apply -auto-approve`,
   usando `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` e as três variáveis
   `TF_VAR_*` acima como secrets do repositório.

## Rodar localmente

```bash
export TF_VAR_db_name="techchallenge"
export TF_VAR_db_user="root"
export TF_VAR_db_password="<senha>"

terraform init
terraform plan
terraform apply
```

## Outputs

| Output                 | Descrição                                            |
| ----------------------- | ----------------------------------------------------- |
| `vpc_id`                | ID da VPC (referenciada de `tech-challenge-kubernetes`) |
| `database_instance_id`  | ID da instância RDS criada                            |

## Repositórios relacionados

- [`tech-challenge-application`](https://github.com/eduNsantos/tech-challenge-application) — aplicação Laravel que consome esta RDS.
- [`tech-challenge-kubernetes`](https://github.com/eduNsantos/tech-challenge-kubernetes) — cria a VPC/subnets/Security Group referenciados aqui via `data source`.
- [`tech-challenge-lambda-functions`](https://github.com/eduNsantos/tech-challenge-lambda-functions) — Function serverless de autenticação, também referencia esta RDS.

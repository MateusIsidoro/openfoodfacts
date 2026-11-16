# OFF-APP — Open Food Facts Mobile

## Plano de Gerenciamento de Configuração e DevOps

**Enfoque DevOps — Integração e Entrega Contínuas (CI/CD) • Versão 1.2**

| Campo | Descrição |
|---|---|
| Projeto | OFF-APP — Open Food Facts Mobile (NutriBusca) |
| Gerente de Projeto | Mateus Isidoro |
| Gerente/Responsável de GCS-DevOps | Mateus Isidoro |
| Fábrica de Software / Squad | DevOps Squad / Mateus Isidoro |
| Repositório principal | https://github.com/MateusIsidoro/openfoodfacts |

### Histórico de Revisões

| Data | Versão | Descrição | Autor |
|---|---|---|---|
| 10/08/2026 | 1.0 | Elaboração inicial do documento com enfoque em práticas DevOps (CI/CD). | Luiz Camargo |
| 21/09/2026 | 1.1 | Preenchimento e especificação para o projeto Open Food Facts Mobile. | Mateus Isidoro |
| 16/11/2026 | 1.2 | Atualização para versão atual do app: upgrade de dependências (`openfoodfacts ^3.32.0`, `cupertino_icons ^2.0.0`), inclusão do Comparador Nutricional de Alimentos, especificação formal de proteção da branch `main` com bloqueio de push direto, revisão por par com acesso de escrita, e pipeline com environments `staging` e `production` (com aprovação obrigatória de revisor). | Mateus Isidoro |

## Sumário

1. [Introdução](#1-introdução)
2. [Cultura DevOps e Papéis na Gerência de Configuração](#2-cultura-devops-e-papéis-na-gerência-de-configuração)
3. [Ferramentas, Ambientes e Infraestrutura](#3-ferramentas-ambientes-e-infraestrutura)
4. [Identificação da Configuração](#4-identificação-da-configuração)
5. [Integração Contínua (CI)](#5-integração-contínua-ci)
6. [Entrega e Implantação Contínua (CD) e Environments](#6-entrega-e-implantação-contínua-cd-e-environments)
7. [Infraestrutura como Código (IaC)](#7-infraestrutura-como-código-iac)
8. [Controle de Configuração, Mudança e Proteção de Branches](#8-controle-de-configuração-mudança-e-proteção-de-branches)
9. [Baselines e Releases](#9-baselines-e-releases)
10. [Estimativa do Status de Configuração](#10-estimativa-do-status-de-configuração)
11. [Marcos](#11-marcos)
12. [Treinamento e Recursos](#12-treinamento-e-recursos)
13. [Controle de Software de Terceiros e Dependências](#13-controle-de-software-de-terceiros-e-dependências)
14. [Quadro-Resumo do Pipeline CI/CD](#14-quadro-resumo-do-pipeline-cicd)

---

## 1. Introdução

Este Plano de Gerenciamento de Configuração (PGC) descreve as atividades de Gestão de Configuração de Software (GCS) executadas ao longo do ciclo de vida do produto **NutriBusca (Open Food Facts Mobile)**, com ênfase em práticas DevOps — em particular Integração Contínua (CI), Entrega/Implantação Contínua (CD), Infraestrutura como Código (IaC) e automação de pipelines no GitHub Actions. As atividades envolvem identificar os itens de configuração, manter sua integridade e controlar sistematicamente as mudanças com validações automatizadas.

### 1.1 Finalidade

Estabelecer um padrão rigoroso e automatizado a ser seguido pelo time, garantindo rastreabilidade, versionamento, controle de branches protegidas e controle de mudanças do produto, apoiado por pipelines automatizados de build, teste, integração e implantação por ambientes.

### 1.2 Escopo

Este plano é destinado a **Mateus Isidoro** e aos revisores/colaboradores do projeto Open Food Facts Mobile (`https://github.com/MateusIsidoro/openfoodfacts`). O sistema consiste em uma aplicação Flutter multiplataforma (Mobile, Web e Desktop) voltada para consulta nutricional, análise de rótulos (Nutri-Score, NOVA, Eco-Score), busca por código de barras EAN e **comparação nutricional lado a lado de produtos alimentícios**.

### 1.3 Definições, Acrônimos e Abreviações

| Termo | Significado |
|---|---|
| GCS | Gestão de Configuração de Software |
| CI | Integração Contínua (Continuous Integration) |
| CD | Entrega/Implantação Contínua (Continuous Delivery / Deployment) |
| IaC | Infraestrutura como Código (Infrastructure as Code) |
| PR | Pull Request |
| Branch Protection | Regras do GitHub que bloqueiam ações diretas (como push direto) em branches críticas |
| Environment | Ambiente lógico de execução no GitHub Actions com políticas de governança e segredos |
| Required Reviewers | Aprovadores manuais obrigatórios configurados em um Environment antes do deploy |
| Pair Review | Revisão de código realizada por um par com permissão de escrita (*Write access*) |
| Baseline | Conjunto estável de itens de configuração formalmente aprovados e versionados |

---

## 2. Cultura DevOps e Papéis na Gerência de Configuração

A responsabilidade pela integridade dos itens de configuração e qualidade dos deploys é distribuída e automatizada:

| Papel | Responsabilidades |
|---|---|
| Gerente de Projeto / PO | Priorização do backlog, homologação final em Staging e aprovação de releases. |
| Engenheiro DevOps / Release Engineer | Manutenção dos workflows do GitHub Actions (`.github/workflows`), branches protegidas e environments. |
| Desenvolvedor(a) Principal (Mateus Isidoro) | Desenvolvimento de features, resolução de conflitos, gatekeeper e **revisor obrigatório para o ambiente de Produção**. |
| Par de Revisão (Peer Reviewer com acesso de escrita) | Revisão obrigatória de código em todo Pull Request destinado à branch `main`, validando padrões e arquitetura antes do merge. |
| QA / Automação | Manutenção e expansão da suíte de testes de widgets e unitários (`flutter test`). |

---

## 3. Ferramentas, Ambientes e Infraestrutura

### 3.1 Ferramentas do Pipeline

| Categoria | Ferramenta | Finalidade |
|---|---|---|
| Controle de versão | Git + GitHub | Versionamento distribuído, controle de branches, Pull Requests e auditoria |
| Orquestração de CI/CD | GitHub Actions | Execução de lint (`flutter analyze`), testes (`flutter test`), build Web e releases |
| Framework & Linguagem | Flutter SDK 3.47+ & Dart SDK 3.13+ | Desenvolvimento da aplicação multiplataforma |
| Gestão de Dependências | Dart Pub (`pubspec.yaml`, `pubspec.lock`) | Controle estrito de versões fixadas e auditadas |
| Ambientes (Environments) | GitHub Environments (`staging` e `production`) | Governança de promoção contínua com gate de aprovação manual |
| Segurança de Branch | GitHub Branch Protection Rules | Bloqueio de push direto na `main` e obrigatoriedade de PR aprovado |

### 3.2 Ambientes e Infraestrutura

O ciclo de promoção do software é dividido em três camadas:

1. **Desenvolvimento (Local):**
   - Executado localmente na máquina do desenvolvedor (Windows, Web ou Emulador).
   - Validação imediata via `flutter analyze` e `flutter test`.
2. **Homologação (`staging`):**
   - **Environment no GitHub:** `staging`.
   - **Gatilho:** Merge automático na branch `main` após aprovação do PR.
   - **Objetivo:** Hospedagem da versão de testes Web e geração de artefatos para validação prévia.
3. **Produção (`production`):**
   - **Environment no GitHub:** `production`.
   - **Gatilho:** Conclusão com sucesso do deploy em Staging.
   - **Gate de Aprovação:** **Revisor Obrigatório (*Required Reviewer*) configurado exclusivamente para Mateus Isidoro**. O deploy para os usuários finais só prossegue após essa aprovação explícita no GitHub Actions.

---

## 4. Identificação da Configuração

### 4.1 Itens de Configuração (ICs)

São itens formalmente controlados neste repositório:
- Código-fonte da aplicação (`lib/**`)
- Testes automatizados (`test/**`)
- Telas principais, incluindo o Comparador Nutricional (`lib/telas/tela_comparador.dart`)
- Manifesto de dependências e lockfile (`pubspec.yaml` e `pubspec.lock`)
- Plano de GCS publicado na raiz (`PLANO_GCS.md`)
- Definição do Pipeline de CI/CD (`.github/workflows/ci_cd.yml`)
- Regras de descarte e integridade (`.gitignore`)
- Documentação de uso e execução (`README.md`)

### 4.2 Estrutura do Repositório

```text
openfoodfacts/
├── .github/
│   └── workflows/
│       └── ci_cd.yml          # Pipeline com jobs de CI, Deploy Staging e Deploy Production
├── .gitignore                 # Filtro de arquivos gerados e binários locais
├── android/                   # Configurações da plataforma Android
├── lib/
│   ├── main.dart              # Ponto de entrada da aplicação NutriBusca
│   ├── servicos/
│   │   └── servico_open_food_facts.dart  # Integração com API Open Food Facts v3.5
│   ├── telas/
│   │   ├── tela_principal.dart           # Interface com 3 abas (Pesquisa, Favoritos, Comparar)
│   │   ├── tela_detalhes_produto.dart    # Tabela nutricional, Nutri-Score, NOVA e Eco-Score
│   │   └── tela_comparador.dart          # Comparador lado a lado com destaque de nutrientes
│   └── widgets/
│       ├── cartao_produto.dart           # Card com suporte a Favoritar e Comparar
│       ├── emblema_nova.dart             # Emblema da classificação NOVA (1 a 4)
│       └── emblema_nutriscore.dart       # Emblema visual Nutri-Score (A a E)
├── test/
│   └── widget_test.dart       # Suíte de testes automatizados de widgets e fluxo
├── web/                       # Suporte para execução na Web
├── windows/                   # Suporte para compilação nativa Windows Desktop
├── pubspec.yaml               # Dependências atualizadas (openfoodfacts ^3.32.0, cupertino_icons ^2.0.0)
├── pubspec.lock               # Lockfile de dependências resolvidas
├── PLANO_GCS.md               # Plano de Gerenciamento de Configuração (Item de Configuração)
└── README.md                  # Apresentação do projeto e instruções
```

---

## 5. Integração Contínua (CI) e Políticas de Qualidade

Todo Pull Request enviado para a branch `main` executa automaticamente o job `ci` no GitHub Actions:

1. **Checkout & Cache:** Recupera o código e restaura o cache do Flutter SDK e dependências.
2. **Dependências:** Executa `flutter pub get`.
3. **Análise Estática (Linter):** Executa `flutter analyze`. O pipeline falha se houver qualquer erro de tipagem ou sintaxe.
4. **Testes Automatizados:** Executa `flutter test --coverage`. Garante 100% de aprovação nos testes da suíte.

---

## 6. Entrega e Implantação Contínua (CD) e Environments

O arquivo `.github/workflows/ci_cd.yml` implementa a promoção orientada a **GitHub Environments**:

```
[Pull Request] ──> Job CI (analyze + test) ──> [Aprovação do Par com Write Access] ──> [Merge na main]
                                                                                              │
┌─────────────────────────────────────────────────────────────────────────────────────────────┘
▼
[Job deploy-staging] (Environment: staging)
│  • Compila versão Web para Staging
│  • Publica artefato `build-web-staging`
▼
[Gate de Aprovação Manual] ──> Revisor Obrigatório: Mateus Isidoro
▼
[Job deploy-production] (Environment: production)
   • Compila versão Web para Produção
   • Publica artefato `build-web-production`
```

---

## 7. Controle de Configuração, Mudança e Proteção de Branches

### 7.1 Proteção da Branch `main` (Branch Protection Rule)

A branch `main` é estritamente protegida contra alterações não autorizadas. É expressamente proibido fazer `git push` direto na `main`.

**Configurações ativas no GitHub (`Settings > Branches > Branch protection rules`):**
- **Branch name pattern:** `main`
- **Require a pull request before merging:** Ativado
  - **Require approvals:** `1` (Revisão obrigatória de código)
- **Require review from Code Owners / Collaborators with write access:** Ativado
- **Require status checks to pass before merging:** Ativado (Job `ci` deve estar verde)
- **Do not allow bypassing the above settings:** Ativado (Aplica-se inclusive a administradores)

### 7.2 Evidência da Recusa do Push Direto na `main`

Quando qualquer desenvolvedor tenta enviar alterações diretamente para a branch principal sem passar por Pull Request:

```bash
git checkout main
git add .
git commit -m "tentativa de push direto"
git push origin main
```

O servidor do GitHub **recusa e aborta a operação**, gerando a seguinte evidência oficial no terminal:

```text
To https://github.com/MateusIsidoro/openfoodfacts.git
 ! [remote rejected] main -> main (protected branch hook declined)
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Changes must be made through a pull request.
remote: error: 1 review approving this pull request is required before merging.
error: failed to push some refs to 'https://github.com/MateusIsidoro/openfoodfacts.git'
```

### 7.3 Par de Revisão com Acesso de Escrita (Peer Review)

Para atender ao princípio dos "quatro olhos" e garantir governança:
- Um colaborador do time/turma é adicionado ao repositório em `Settings > Collaborators` com nível de permissão **Write (Escrita)**.
- O colaborador analisa o Pull Request, verifica as mudanças propostas no comparador e testes, e realiza a aprovação formal (*Approve*) pela interface do GitHub antes que o botão de *Merge* seja liberado.

---

## 8. Baselines e Releases

- **Baseline:** Cada versão promovida para o environment `production` após a aprovação de Mateus Isidoro gera um commit de baseline rastreável.
- **Tags de Release:** Seguem SemVer (ex.: `v1.2.0`), registrando o estado aprovado dos artefatos e a publicação do plano de GCS atualizado.

---

## 9. Marcos do Projeto

- **M1 — Estruturação do Repositório e Padrões de GCS:** Git, `.gitignore`, organização de diretórios e dependências (Concluído).
- **M2 — Pipeline de CI:** Automação de lint (`flutter analyze`) e testes (`flutter test`) via GitHub Actions (Concluído).
- **M3 — Implementação do Comparador Nutricional:** Criação da aba de comparação de produtos e suporte a decisão saudável (Concluído).
- **M4 — Atualização do Plano de GCS como Item de Configuração:** Publicação do `PLANO_GCS.md` versão 1.2 no repositório (Concluído).
- **M5 — Governança de Branches e Ambientes:** Configuração da regra de proteção de branch com evidência de push recusado, par de revisão com acesso de escrita, e environments `staging` e `production` com revisor obrigatório (Concluído).

---

## 10. Controle de Software de Terceiros e Dependências

As bibliotecas externas atualizadas nesta versão são:
- **`openfoodfacts: ^3.32.0`**: Acesso à API oficial do Open Food Facts com suporte a novos campos e tipos corrigidos.
- **`cupertino_icons: ^2.0.0`**: Ícones de alta fidelidade para interface mobile e desktop.
- **`flutter_lints: ^6.0.0`**: Regras oficiais de qualidade e boas práticas de código Dart/Flutter.

Todas as versões estão fixadas no `pubspec.lock` para garantir reprodutibilidade exata em qualquer máquina ou runner de CI/CD.

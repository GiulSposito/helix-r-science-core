# Economic Diversity and Student Outcomes (2024-09-10)**

Esse dataset tem observações por faculdade e faixas de renda dos pais, com taxas de application/attendance, versões relativas e absolutas, e recortes específicos para in-state/out-of-state em escolas públicas. É muito bom para estudar mobilidade econômica e segmentação socioeconômica no ensino superior. 

## Questões de EDA:

* Como a attendance rate muda conforme a renda parental? Há gradiente monotônico? 
* Quais instituições têm maior diferença entre application e attendance? 
* Escolas públicas mostram padrões diferentes para in-state versus out-of-state? 
* Como se distribuem os indicadores relativos entre tipos de instituição e faixas de score? 

## Visualizações úteis:

* Line plots ou ridge plots de attendance por `par_income_bin`, separados por universidade ou grupo. 
* Scatter `rel_apply` vs `rel_attend`, com cor por tipo de escola ou faixa de renda. 
* Boxplots das métricas por categoria de instituição ou por bin de renda. 
* Small multiples comparando in-state e out-of-state nas escolas públicas. 

## Modelagem interessante:

* **Regressão** para prever `rel_attend` ou `attend` a partir de renda parental, tipo da instituição, e métricas de application. 
* **Classificação** de faculdades em grupos de alta/baixa mobilidade econômica usando métricas de atendimento relativo e condicional.
* **Clustering** de instituições por perfil de acesso econômico.
* **Modelos hierárquicos/multinível** fazem sentido porque há estrutura por faculdade e por faixa de renda.

## Hipóteses

1. **Hipóteses de negócio/econômicas** → o fenômeno que queremos investigar
2. **Hipóteses estatísticas/modeláveis** → como testar/modelar isso

**Hipótese econômica 1**: **Alunos de famílias de maior renda têm maior probabilidade relativa de matrícula em instituições seletivas.**
* Intuição: Maior renda aumenta acesso a preparação, mobilidade e capacidade financeira.
* Hipótese modelável: Faixas de renda superiores terão coeficientes positivos para taxa relativa de matrícula.

**Hipótese econômica 2**: A diferença entre aplicação e matrícula é maior para alunos de baixa renda.
* Intuição: Mesmo quando aplicam, enfrentam barreiras financeiras para efetivar matrícula.
* Hipótese modelável: O gap diminui conforme aumenta a renda familiar.

**Hipótese econômica 3**: Universidades públicas reduzem a desigualdade de acesso para estudantes locais (in-state).
* Hipótese modelável: O efeito da renda é menor entre alunos in-state.

**Hipótese econômica 4**: Instituições podem ser clusterizadas em perfis de mobilidade social.
* Hipótese modelável: As instituições formam clusters distintos segundo indicadores de acesso por renda.

Clusters esperados:

* alta inclusão
* baixa inclusão
* elite seletiva

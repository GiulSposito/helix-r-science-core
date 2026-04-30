# Hotels (2020-02-11)

O dataset de hotéis inclui cancelamento, lead time, datas de chegada, estadia, composição do grupo, origem, canal de venda, tipo de depósito, mudanças na reserva, ADR e status final da reserva. É um dos conjuntos mais completos do TidyTuesday para classificação supervisionada e feature engineering operacional. 

## Questões de EDA:

* Quais variáveis mais se associam ao cancelamento? 
* Cancelamentos sobem com lead time maior? 
* O ADR e o cancelamento mudam por hotel, canal ou tipo de cliente? 
* Há padrões sazonais por mês, semana do ano e dia da semana? 

## Visualizações úteis:

* Taxa de cancelamento por `lead_time`, em bins. 
* Heatmap de cancelamento por mês × hotel. 
* Boxplot de `adr` por hotel, canal e tipo de cliente. 
* Barras para `deposit_type`, `customer_type`, `market_segment` e `country`. 

## Modelagem interessante:

* **Classificação binária** de cancelamento (`is_canceled`) com logistic regression, random forest, XGBoost ou CatBoost. 
* **Regressão** para prever `adr` ou duração da estadia. 
* **Feature engineering** forte: sazonalidade de chegada, lead time, composição da reserva, histórico de cancelamentos, interações com canal e tipo de depósito. 
* Se quiser algo mais sofisticado, dá para testar **modelos de risco/sobrevivência** para tempo até cancelamento, usando as datas disponíveis.

## Hipóteses

1. **Hipóteses de negócio/econômicas** → o fenômeno que queremos **investigar**
2. **Hipóteses estatísticas/modeláveis** → como testar/modelar isso

**Hipótese econômica 1**: Reservas com maior antecedência têm maior probabilidade de cancelamento.
* Intuição: Maior tempo = maior chance de mudança de planos.
* Hipótese modelável: `lead_time` será uma das features mais importantes.

**Hipótese econômica 2**: Clientes com depósito não reembolsável têm menor taxa de cancelamento.
* Intuição: Há custo de desistência.
* Hipótese modelável: `deposit_type=non_refundable` reduz a probabilidade de cancelamento.

**Hipótese econômica 3**: O preço médio diário (ADR) influencia o cancelamento de forma não linear.
* Intuição: Preços altos podem elevar cancelamento, mas clientes premium podem ser mais estáveis.
* Hipótese modelável: Existe relação não linear entre ADR e cancelamento.

**Hipótese econômica 4**: O canal de aquisição afeta risco de cancelamento.
* Hipótese modelável: Reservas por OTA possuem maior cancelamento que canais diretos.

**Hipótese econômica 5**: Sazonalidade afeta cancelamento e receita simultaneamente.
* Modelagem: mês, semana, feriado
* Hipótese modelável: Meses de alta temporada aumentam ADR e alteram padrão de cancelamento.

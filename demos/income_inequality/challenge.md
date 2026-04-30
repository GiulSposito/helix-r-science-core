# Income Inequality Before and After Taxes (2025-08-05)**

Esse conjunto traz Gini antes e depois de impostos/benefícios por país e ano no arquivo processado, e no arquivo bruto traz também Gini de renda de mercado e disponível, além de população histórica e região OWID. É excelente para comparar redistribuição entre países e ao longo do tempo. 

## Questões de EDA:

* Quais países têm maior diferença entre Gini pré e pós-impostos? 
* A redistribuição cresce ou cai ao longo do tempo em cada região? 
* Há países com alta desigualdade antes dos impostos, mas queda forte depois? 
* Como o nível de desigualdade se distribui por região e ano? 

## Visualizações úteis:

* Série temporal do Gini pré e pós-impostos por país. 
* Scatter `gini_mi_eq` vs `gini_dhi_eq`, com linha de igualdade para evidenciar redistribuição. 
* Mapa coroplético ou ranking por região/país da diferença entre pré e pós-impostos. 
* Heatmap país × ano da “queda de Gini” pós tributação. 

## Modelagem interessante:

* **Regressão** para prever `gini_dhi_eq` a partir de `gini_mi_eq`, ano, região e população histórica. 
* **Regressão/forecasting** da diferença `gini_mi_eq - gini_dhi_eq` como proxy de redistribuição.
* **Clustering** de países por trajetória de desigualdade e redistribuição.
* **Classificação** de países em “alta” vs “baixa” redistribuição, usando um limiar definido pela própria distribuição do dataset.


## Hipóteses

1. **Hipóteses de negócio/econômicas** → o fenômeno que queremos investigar
2. **Hipóteses estatísticas/modeláveis** → como testar/modelar isso

**Hipótese 1**: Países com maior desigualdade pré-impostos fazem maior redistribuição via impostos e transferências.
* Hipótese modelável: `gini_before` prediz positivamente `redistrib`.

**Hipótese econômica 2**: A capacidade redistributiva varia sistematicamente entre regiões.
* Hipótese modelável: A média de redistribuição difere entre regiões.

**Hipótese econômica 3**: A desigualdade pós-impostos é mais estável ao longo do tempo do que a desigualdade pré-impostos.
* Hipótese modelável: `Var(gini_after) < Var(gini_before)`

**Hipótese econômica 4**: Países podem ser agrupados em regimes redistributivos distintos.
* Hipótese modelável: Países formam grupos estruturais de redistribuição.

Clusters:
* alta desigualdade / alta redistribuição
* baixa desigualdade / baixa redistribuição
* alta desigualdade / baixa redistribuição
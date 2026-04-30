# House and Mortgage data (2019-02-05)

O conjunto traz HPI mensal por estado e nacional, taxas de mortgage (30 anos, 15 anos, ARM 5-1) e uma tabela de recessões nos EUA. Isso o torna ótimo para análise temporal, sazonalidade e relação entre custo do crédito e preços de imóveis. 

## Questões de EDA:

* Como o crescimento anual do HPI varia por estado? Quais estados ficam consistentemente acima/abaixo da média nacional? 
* Há defasagem entre mudanças nas mortgage rates e aceleração/desaceleração do HPI? 
* O spread entre mortgage fixa de 30 anos e ARM 5-1 muda em ciclos específicos? 
* O comportamento do HPI muda em torno das recessões listadas? 

## Visualizações úteis:

* Série temporal do HPI nacional e linhas por estado, destacando períodos de recessão. 
* Heatmap estado × ano para variação percentual do HPI. 
* Gráfico de linhas com mortgage rates e spread ao longo do tempo. ([GitHub][2])
* Scatter com defasagens entre taxa de mortgage e crescimento futuro do HPI. ([GitHub][2])

## Modelagem interessante:

* **Regressão / forecasting** para prever crescimento do HPI em 3, 6 ou 12 meses usando lags do HPI, taxas de mortgage, spread e dummies de recessão. 
* **Classificação** de meses/estados em “acelera” vs “desacelera” do mercado imobiliário.
* **Modelos painel** por estado, com efeitos fixos ou árvores/boosting, para capturar heterogeneidade regional.

## Hipóteses 

1. **Hipóteses de negócio/econômicas** → o fenômeno que queremos investigar
2. **Hipóteses estatísticas/modeláveis** → como testar/modelar isso

**Hipótese econômica 1**: A elevação das taxas de mortgage reduz o crescimento do preço dos imóveis com defasagem temporal.
* Intuição: Quando a taxa sobe, o crédito imobiliário fica mais caro, a demanda diminui e a valorização desacelera.
* Hipótese modelável: Features de juros defasados melhoram a previsão do crescimento futuro do HPI.


**Hipótese econômica 2**: Estados com maior volatilidade de preços são mais sensíveis às variações de juros.
* Intuição: Mercados mais especulativos reagem mais ao custo de financiamento.
* Hipótese modelável: A importância da feature “mortgage rate” será maior em estados com alta volatilidade.

**Hipótese econômica 3**: Durante recessões, a sensibilidade do mercado imobiliário ao juros aumenta.

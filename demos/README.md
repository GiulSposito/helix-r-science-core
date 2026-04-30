# Demos

## Student Outcome

Exemplo de um fluxo de ingestão até modelagem chamando os agentes e passando a instrução textualmente, isso permite que vc atue entre os checkpoints (principais fases)

1. Ingestion

> /ada preciso que organize as pastas de um novo projeto e vc faça a ingestão dos dados @demos/students_outcome/college_admissions.csv de acordo com a @demos/students_outcome/description.md para preparar os dados para fazer um EDA

2. EDA

> /grace faça a análise exploratória dos dados recém ingeridos de acordo com a sessão EDA do documento @demos/students_outcome/challenge.md e outras que achar relevante, cataloque os insigths e os achados, gere também as visualizações interessantes descritas no mesmo documento (e outras que achar interessantes). Crie um reporte quarto consolidando tudo e renderize em html com imagens auto contidas. 

3. Feature Engineering

> /grace gere as features candidatas para auxiliar o processo de modelagem de acordo com as hipóteses e modelos candidatos propostos no documento @demos/students_outcome/challenge.md que serão feitas no passo a seguir. Lembre-se de criar o catálogo com essas features em um documento quarto renderizado em html

4. Modeling e Evaluation

> /alan usando as features criadas e os dados ingeridos e explorados, crie e avalie os modelos propostos no documento @demos/students_outcome/challenge.md também faça uma avaliação das hipóteses de negócio levantadas no mesmo documento. Crie um report quarto com os resultados dos modelos e da avaliação da hipóteses, renderize ele com html, use gráficos onde puder. Se achar que outros modelos ou modelagens cabem aqui faça também.  

## Income Inequality

Exemplo de como rodar o fluxo completo (ingestão a avaliação de modelos) com um único prompt. Fluxo automático de ponta a ponta sem intervenção.

> /ada execute o fluxo completo de ingestão, eda, geração de features, modelagem e avaliação dos dados @demos/income_inequality/income_inequality_raw.csv descrito em @demos/income_inequality/description.md para fazer o EDA, as visualizações, as modelages sugeridas e para comprovar as hipóteses de negócio especificadas em @demos/income_inequality/challenge.md garanta que vc gere os relatórios e visualizações em quarto reports e renderizadas em html para cada um dos checkpoints (Ingestão, EDA, Feature Engineering, Modeling e Evaluation). 

## House Mortage

Exemplo chamando cada um dos agentes separadamente e usando o menu de comandos, permite que vc avalie e redirecione em cada etapa de uma ciclo de vida de ciencia de dados.

1. Ingestion

> # Setup de Projeto
> /ada
> SP House Mortage 
> # Ingest & Inspect
> II os arquivos CSV da pasta @demos/house_mortage/ descritos em @demos/house_mortage/description.md 
> # Clean Dataset
> CD

2. EDA & Feature Engineering

> # Exploratory Data Analysis
> /grace
> ED faça as explorações e visualizações de dados presentes no documento @demos/house_mortage/challenge.md e outras que achar necessário consolide num quarto report, renderize como html 
> # Feature Eng
> FE 

3. Modeling e Evaluation

> # Modeling Pipeline
> /alan 
> MP siga com a modelagem avalie os modelos sugeridos em @demos/house_mortage/challenge.md e também com a comprovação das hipóteses de negócio lá sugeridas. 

4. Reporting

> /marie
> TR gere um report completo indo da ingestão até a avaliação dos modelos em um único report quarto renderizado para html. Esse report precisa ser didático explicando os achandos, insights e decisões de modelagem, publico alvo é um cientista de dados de nível médio (pleno ou conhecimento básico médio), o report precisa ser ilustrado e organizado para facilitar o entendimento do problema, o aprendizado e as conclusões.
# Shopper.com.br - Teste Técnico - SQL

Oi pessoal! Foi uma experiência de honra e de muito aprendizado explorar os dados e participar desse primeiro teste. Antes das perguntas, deixo algumas informações essenciais sobre as etapas realizadas e como acessar.

# Para trabalhar com os arquivos no GCP

Criei um novo projeto para o teste e utilizei os arquivos CSV para criar tabelas no Google **BigQuery**, poder salvar as queries e compartilhar de forma fácil o resultado com vocês.

[Link do projeto/console no BigQuery](https://console.cloud.google.com/bigquery?hl=pt-br&project=shopper-teste-01)

Os assets criados a partir dos arquivos fonte são (sintaxe: `projeto.conjunto.tabela`):
 - table_sales.csv --> `shopper-teste-01.shopper.sales`;
 - table_customers.csv --> `shopper-teste-01.shopper.customers`;
 - table_sales_items.csv --> `shopper-teste-01.shopper.sales_items`.

Além das tabelas, criei duas views para auxiliarem:

 - `shopper-teste-01.shopper.customer_numbers` - Contém metadados sobre a tabela `customers` que são importantes para a questão 1;
 - `shopper-teste-01.shopper.customer_age` - Contém o `customer_id` e a idade já calculada.

Por fim, as soluções de cada exercício estão no dropdown/menu **Consultas (clássicas)**, também sob o projeto ``shopper-teste-01``. O link de cada solução no **BigQuery** estará logo abaixo de seu enunciado.

**⚠️ IMPORTANTE -** Além do ambiente no **GCP/BigQuery**, deixo os arquivos de cada exercício hospedados nesse repositório também:

 - ``solutions/`` contém os arquivos respectivos à cada solução/pergunta;
 - ``views/`` contém as queries que definem as duas views auxiliares.
 
# Questões Propostas

## 1 - Qual é a quantidade de clientes com mais de 50 anos?

 - [Solução 1 no BigQuery](https://console.cloud.google.com/bigquery?sq=141265426384:922c63f9495f4f24888457772751ee27)

Antes de verificarmos o que a questão pede, identifiquei, na tabela customers, um problema relacionado à qualidade de dados. Analisando os metadados na view customer_numbers, podemos ver melhor:

~~~sql
SELECT
  total_customers_qty,
  null_birth_qty,
  null_birth_percent,
  with_birth_qty,
  with_birth_percent
FROM
  `shopper-teste-01.shopper.customer_numbers`
~~~
**Resultado:**
|total_customers_qty|null_birth_qty|null_birth_percent|with_birth_qty|with_birth_percent|
|-------------------|--------------|------------------|--------------|------------------|
|10964              |8276          |75.48             |2688          |24.52             |


De 10964 clientes, apenas 24,52% possui data de nascimento preenchida. Os outros 75,48%, quase 80%, estão com a data nula/vazia. Isso altera o significado do resultado da questão referente à clientes com mais de 50 anos, pois a amostra realizada foi de apenas 24,52%, ou seja, 2688 dos 10964 clientes existentes.

Para responder à primeira pergunta, criei primeiro a view chamada customer_age para ter as idades calculadas. Essa é a aparência da view:
~~~sql
SELECT
    c.customer_id,
    DATE_DIFF(current_date, c.birth, year) AS age
  FROM
    shopper-teste-01.shopper.customers c
  WHERE
    c.birth IS NOT NULL
~~~
**Resultado:**
|customer_id|age|
|-----------|---|
|66020      |46 |
|66021      |43 |
|66028      |67 |

Depois, a instrução final consulta a view para obter o número de clientes com mais de 50 anos:
~~~sql
SELECT
  COUNT(*) AS customers_quantity
FROM
  shopper-teste-01.shopper.customer_age ca
WHERE
  ca.age > 50
~~~
**Resultado:**
|**customers_quantity**| 
|--|
| 910|

## 2 - Quais são os top 5 produtos mais vendidos no site?

 - [Solução 2 no BigQuery](https://console.cloud.google.com/bigquery?sq=141265426384:21ad16554f7445f8b9094af27fd4bc91)

~~~sql
SELECT
  si.product_name,
  COUNT(si.product_id) as sales_qty
FROM
  `shopper-teste-01.shopper.sales_items` si
GROUP BY
  si.product_name
ORDER BY
  2 DESC
LIMIT
  5
~~~
**Resultado:**
|product_name|sales_qty|
|------------|---------|
|TOALHA DE PAPEL SNOB C/2|881      |
|ÁGUA SANITÁRIA SUPER CANDIDA 2L|600      |
|LIMPADOR MULTIUSO VEJA ORIGINAL 500ML|556      |
|PAPEL HIGIÊNICO NEVE FOLHA DUPLA NEUTRO C/16 30M X 10CM|425      |
|AZEITE ANDORINHA PORTUGUÊS EXTRA VIRGEM 500ML|423      |



## 3 - Qual é a nossa taxa de conversão (quando efetivaram compras) por mês?

 - [Solução 3 no BigQuery](https://console.cloud.google.com/bigquery?sq=141265426384:856aea329375492f8f325d45638fe4de)

Para resolver essa questão, primeiro criei as duas CTEs `sales_by_month` e `customers_by_month` para mostrarem as vendas e os clientes ambos por ano e mês. a função `EXTRACT()` é utilizada para separar o ano e o mês da data/timestamp integral.
~~~sql
WITH
  sales_by_month AS (
  SELECT
    EXTRACT(year
    FROM
      s.sales_datetime) AS year,
    EXTRACT(month
    FROM
      s.sales_datetime) AS month,
    COUNT(*) AS sales_qty
  FROM
    `shopper-teste-01.shopper.sales` s
  GROUP BY 1,2
  ORDER BY 1,2),
  
  customers_by_month AS (
  SELECT
    EXTRACT(year
    FROM
      c.created) AS year,
    EXTRACT(month
    FROM
      c.created) AS month,
    COUNT(DISTINCT(c.customer_id)) AS customer_qty
  FROM
    `shopper-teste-01.shopper.customers` c
  GROUP BY 1,2
  ORDER BY 1,2)
~~~

Depois, a query principal faz um left join em ambas as views e na última coluna calcula a Taxa de Conversão. A fórmula considerada foi ``(TotalVendasMês / TotalClientesMês) * 100`` e um ``LEFT JOIN`` foi escolhido pois existem vendas após 2019, mas não novos clientes.

~~~sql  
SELECT
  sbm.year,
  sbm.month,
  sbm.sales_qty,
  ROUND((sbm.sales_qty / cbm.customer_qty) * 100, 2) AS conversion_rate,
  ROUND((sbm.sales_qty / (
      SELECT
        total_customers_qty
      FROM
        shopper-teste-01.shopper.customer_numbers)) * 100, 2) AS conversion_rate_total_customers
FROM
  sales_by_month sbm
LEFT JOIN
  customers_by_month cbm
ON
  sbm.year = cbm.year
  AND sbm.month = cbm.month
~~~
**Resultado:**
|year |month|sales_qty|conversion_rate|conversion_rate_total_customers|
|-----|-----|---------|---------------|-------------------------------|
|2019 |3    |700      |29.74          |6.38                           |
|2019 |2    |492      |17.67          |4.49                           |
|2019 |1    |241      |6.43           |2.2                            |
|2019 |4    |637      |30.67          |5.81                           |
|2019 |10   |1        |               |0.01                           |
|2022 |6    |7        |               |0.06                           |
|2022 |3    |1        |               |0.01                           |

**⚠️ IMPORTANTE -** Na questão sobre a Taxa de Conversão, me surgiu a grande dúvida sobre se o mais correto para calcular a métrica seria considerar o número de clientes do mês (como também estamos olhando pra vendas por mês) ou seria considerar o número do tempo todo, como um só, 10964. 

Realizei pesquisas tanto em Português quanto em Inglês e por não ter encontrado uma resposta clara, adicionei a última coluna que considera a mesma fórmula para a Taxa de Conversão, mas utilizando como divisor a quantidade total de clientes, obtida na coluna ``total_customers_qty`` da view de metadados ``customer_numbers``.

Confesso não ter compreendido totalmente se existe um mais correto ou se isso depende da regra específica de cada negócio, mas decidi colocar ambas as opções para mostrar o caminho do raciocínio. :)

## 4 - Qual é a média de idade dos clientes por plataforma de acesso (Android, Web, iPhone)?

 - [Solução 4 no BigQuery](https://console.cloud.google.com/bigquery?sq=141265426384:515a119339754a2e91eace09afcb451a)

Primeiro, criei a CTE para ordenar e enumerar as vendas por cada cliente. Utilizei a Window Function ``ROW_NUMBER()`` para particionar por cada cliente e também ordenar pela venda mais recente, como pede  a observação:
~~~sql
WITH
  customer_sales AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.sales_datetime) AS sales_number,
    ca.age
  FROM
    shopper-teste-01.shopper.sales s
  JOIN
    shopper-teste-01.shopper.customer_age ca
  ON
    s.customer_id = ca.customer_id
  ORDER BY
    s.customer_id)
~~~

Depois, calculei a média de idade por cada plataforma, filtrando o sales_number pela venda mais recente:

~~~sql
SELECT
  DISTINCT(cs.platform),
  CAST(AVG(cs.age) AS INT64) AS average_customer_age
FROM
  customer_sales cs
WHERE
  sales_number = 1
GROUP BY 1
~~~
**Resultado:**
|platform|average_customer_age|
|--------|--------------------|
|android |49                  |
|iphone  |49                  |
|website |50                  |

## 5 - Que recomendação você faria para aumentar a taxa de conversão? E por quê?

Com as informações que descobrimos a partir dos dados, poderíamos conduzir algumas ações de marketing, como:

 - Envio de notificação/lembrete para clientes, baseando-se, por exemplo, no produto mais comprado por cada um;
 - Elaboração de estratégia de promoções baseadas em tendências como qual produto é mais vendido por mês ou época do ano
 - Com melhorias relacionadas a Qualidade dos Dados, como fixar mais de 70% dos clientes sem data de nascimento, poderia também nos permitir olhar pra esse tipo de variável (faixa etária) e ampliar o número de estratégias relacionadas à isso.

# Considerações Finais

Caso haja algum problema com a disponibilidade ou compreensão das soluções, basta entrar em contato comigo via qualquer meio como WhatsApp ou e-mail. Me coloco à total disposição!

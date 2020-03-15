
#pacotes necessarios/utilizados no projeto
#install.packages('rvest')
#install.packages('lubridate')
#install.packages(c('stringr', 'dplyr'))

#utilizado para fazer a manipulacao de tags html e xml
library(rvest)

#utilizado para manipulacao de datas
library(lubridate)

#utilizado para manipulacao de strings
library(stringr)

#utilizado para manipulacao geral de dados. Nesse exemplo utilizado para juntar os data frames criados.
library(dplyr)

#fonte de dados. Pagina onde sera feita a raspagem dos dados.
raw_data <- read_html('https://www.nytimes.com/interactive/2017/06/23/opinion/trumps-lies.html')

#avaliacao do tipo da classe retornada
class(raw_data)

#teste inicial para avaliar o funcionamento da funcao, que pode retornar tags e classes.
title <- html_nodes(raw_data, "title")

#avaliacao do tipo do dado retornado
class(title)

#teste inicial para avaliar o retorno do texto que existe na tag
title
html_text(title)

#verificado que os dados desejados possuem a classe 'short-desc'. Retornando todos os dados dessa classe.
results <- html_nodes(raw_data, ".short-desc")

#avaliacao inicial dos dados retornados
head(results)

#criacao de uma lista para armazenamento dos dados
records <- vector(mode = "list", length = length(results))

#iteracao em cada registro/mentira existente na classe 'short-desc'
for (i in 1:length(results)) {
  #coleta todas as tags dentro  de cada classe "short-desc", que contem 1 'mentira' completa. 
  #mentira completa
  lie <- xml_contents(results[i])
  
  #concatena o ano de 2017 e converte o campo em formato de data
  #data da mentira
  date <- parse_date_time(paste0(html_text(lie[1]), "2017"), "mdy")
  
  #remove o caracter ( " - aspas duplas ) inicial e final
  #descricao da mentira
  desc <- str_sub(html_text(lie[2]), 2, -4)
  
  #remove o caracter ( "( - parenteses" ) inicial e final
  #descricao da verdade
  truth <- str_sub(html_text(lie[3]), 2, -3)
  
  #a partir da tag "a", coleta o atributo "href"
  #url da verdade
  url <- html_nodes(lie[3], "a") %>% html_attr("href")
  
  #grava os dados em um data frame, que é armazenado em uma lista
  records[[i]] <- data.frame(date = date, desc = desc, truth = truth, url = url)
}

#gerando o dataset final
df <- bind_rows(records)

#avaliacao do dataset
View(df)

#exporta o dataset no formato .csv
write.table(df, file = "trumps_lier.csv", row.names = FALSE, append = FALSE)

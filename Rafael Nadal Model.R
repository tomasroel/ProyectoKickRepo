# TENNIS DATA ANALYSIS: RAFAEL NADAL ####

# SETUP ####

pacman::p_load(pacman, tidyverse, lubridate,
               stringr, googledrive, readxl) #paquete googledrive instalar aparte

options(scipen = 999) #desactivo notación cientifica

# IMPORTAR DATOS DESDE DISCO GITHUB ####

coltypes = c("numeric", "text", "text", "date", "text", "text",
             "text", "text", "numeric", "text", "text",
             rep("numeric", 16), "text")

for (i in (2005:2012)) {
  
  path = paste("Data/",i,".xls", sep = "")
  file = read_xls(path,
                  range = cell_cols(1:28),
                  col_types = coltypes)
  assign(paste("data",i,sep = ""), file)
    
}


for (i in (2013:2021)) {
  
  path = paste("Data/",i,".xlsx", sep = "")
  file = read_xlsx(path,
                   range = cell_cols(1:28),
                   col_types = coltypes)
  assign(paste("data",i,sep = ""), file)
  
}

rm(file, i , path, coltypes)

# ARMO UN SOLO DATASET ####

#conceteno todos los datasets

matches <- tibble()

for (i in 2005:2021) {
  
  matches <- bind_rows(
    matches,
    get(
      paste("data", i, sep = "")
    )[,1:28]
  )
  
}

for (i in 2005:2021) {
  
  rm(
      list = paste("data", i, sep = "")
  )
  
}

rm(i)


# CORRIJO Y SEPARO DATASET SOLO PARTIDOS NADAL ####

glimpse(matches)

#corrijo nombres de variables

colnames(matches)[9] = "BestOf"
glimpse(matches)

#corrijo data types

summary(matches) #location, series, court, surface, round y comment son factores

matches$Location <- matches$Location %>% as.factor()
matches$Series <- matches$Series %>% as.factor()
matches$Court <- matches$Court %>% as.factor()
matches$Surface <- matches$Surface %>% as.factor()
matches$Round <- matches$Round %>% as.factor()
matches$Comment <- matches$Comment %>% as.factor()
matches$BestOf <- matches$BestOf %>% as.factor()

summary(matches)

#veo si es necesario corregir Location

nlevels(matches$Location)
unique(matches$Location)

#Separo partidos donde jugó Nadal

nadalw <- matches$Winner %>% 
  str_detect("Nadal") %>% 
  which()

matches$Winner[nadalw] %>% 
  unique() #Nadal R. es el unico nombre con el que aparece Nadal

nadalL <- matches$Loser %>% 
  str_detect("Nadal") %>% 
  which()

matches$Loser[nadalL] %>% 
  unique() #Nadal R. es el unico nombre con el que aparece


#Ahora separo el dataset según los partidos donde participó nadal

matches_nadal <- matches %>% 
  filter(Winner == "Nadal R." |
          Loser == "Nadal R."
  )

nrow(matches_nadal) - length(nadalL) - length(nadalw) #si da 0 está OK

rm(nadalL, nadalw)

glimpse(matches_nadal)

# CALCULO MEDIDAS DE INTERÉS PARA MODELO ####

#Ajusto el dataset con variables de interés

# Resultado del Partido ####
matches_nadal$Result <- rep(NA, nrow(matches_nadal))

ganados <- which(
  matches_nadal$Winner == "Nadal R.")
perdidos <- which(
  matches_nadal$Loser == "Nadal R.")

matches_nadal$Result[ganados] <- "Win"
matches_nadal$Result[perdidos] <- "Lose"

matches_nadal$Result <- matches_nadal$Result %>% as.factor()

summary(matches_nadal)

# Ranking del Ganador y Perdedor ####

matches_nadal$RankNadal <- rep(NA, nrow(matches_nadal))
matches_nadal$RankRival <- rep(NA, nrow(matches_nadal))

matches_nadal$RankNadal[ganados] <- 
  matches_nadal$WRank[ganados]

matches_nadal$RankNadal[perdidos] <- 
  matches_nadal$LRank[perdidos]

matches_nadal$RankRival[ganados] <- 
  matches_nadal$LRank[ganados]

matches_nadal$RankRival[perdidos] <- 
  matches_nadal$WRank[perdidos]

matches_nadal %>% 
  select(Tournament, WRank, LRank, Result, RankNadal, RankRival) %>% 
  print(n = 20)

#visualizaciones interesantes
matches_nadal %>% ggplot(aes(x = Date, y = RankNadal)) + 
  geom_line()

matches_nadal %>% filter(Result == "Lose") %>% 
  ggplot(aes(x = Date, y = RankRival)) + 
  geom_point() + 
  coord_cartesian(ylim = c(0,200))

# Nombre del Rival ####

matches_nadal$RivalName <- rep(NA, nrow(matches_nadal))

matches_nadal$RivalName[ganados] <- 
  matches_nadal$Loser[ganados]

matches_nadal$RivalName[perdidos] <- 
  matches_nadal$Winner[perdidos]

matches_nadal$RivalName <- matches_nadal$RivalName %>% 
  as.factor()

summary(matches_nadal)

# Achico Dataset ####

glimpse(matches_nadal)

col_toremove <- c("ATP", "Winner", "Loser", "WRank",
                  "LRank", "WPts", "LPts")

col_toremove <- match(col_toremove,colnames(matches_nadal))

matches_nadal <- matches_nadal[,-col_toremove]

glimpse(matches_nadal) #hay warnings por un bug de dplyr

summary(matches_nadal)

#arreglo con este truco
matches_nadal <- as.data.frame(matches_nadal)
matches_nadal_ok <- as_tibble(matches_nadal)

rm(matches_nadal)

glimpse(matches_nadal_ok)

#Partidos en los Últimos 6, 3 y 1 meses Nadal ####

#Partidos en los ultimos 6 meses

tail(matches_nadal_ok, n = 10)

partidos_nadal_ult6 <- function(fecha) {
  
p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
            filter(Date <= fecha[[i]] & 
                    Date > (fecha[[i]]-6*30)) %>%  
            nrow()
    )
  
  }

  print(p)

}


matches_nadal_ok$Date <- ymd(matches_nadal_ok$Date)

matches_nadal_ok$PartidosUlt6Meses <- 
  matches_nadal_ok$Date %>% 
  partidos_nadal_ult6()

tail(matches_nadal_ok[,c("Date", "PartidosUlt6Meses")], n = 20)

# Partidos últimos 3 meses


partidos_nadal_ult3 <- function(fecha) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-3*30)) %>%  
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosUlt3Meses <- 
  matches_nadal_ok$Date %>% 
  partidos_nadal_ult3()

tail(matches_nadal_ok[,c("Date", "PartidosUlt6Meses",
                         "PartidosUlt3Meses")], n = 20)

glimpse(matches_nadal_ok)

# Partidos último mes

partidos_nadal_ultmes <- function(fecha) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-1*30)) %>%  
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosUltMes <- 
  matches_nadal_ok$Date %>% 
  partidos_nadal_ultmes()

tail(matches_nadal_ok[,c("Date", "PartidosUlt6Meses",
                         "PartidosUlt3Meses",
                         "PartidosUltMes")], n = 20)

glimpse(matches_nadal_ok)

# Partidos Ganados en los Últimos 6, 3 y 1 meses ####

# Partidos en los ultimos 6 meses

partidos_ganadosnadal_ult6 <- function(fecha) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-6*30) &
                      Result == "Win") %>%  
             nrow()
    )
    
  }
  
  p
  
}


matches_nadal_ok$PartidosGanadosUlt6 <- 
  matches_nadal_ok$Date %>% 
  partidos_ganadosnadal_ult6()

tail(matches_nadal_ok[,c("Date", "PartidosGanadosUlt6")],
     n = 20)

# Partidos ganados ultimos 3 meses

partidos_ganadosnadal_ult3 <- function(fecha) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-3*30) &
                      Result == "Win") %>%  
             nrow()
    )
    
  }
  
  p
  
}


matches_nadal_ok$PartidosGanadosUlt3 <- 
  matches_nadal_ok$Date %>% 
  partidos_ganadosnadal_ult3()

tail(matches_nadal_ok[,c("Date", "PartidosGanadosUlt3")],
     n = 20)

# Partidos ganados ultimo mes

partidos_ganadosnadal_ultmes <- function(fecha) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-1*30) &
                      Result == "Win") %>%  
             nrow()
    )
    
  }
  
  p
  
}


matches_nadal_ok$PartidosGanadosUltMes <- 
  matches_nadal_ok$Date %>% 
  partidos_ganadosnadal_ultmes()

tail(matches_nadal_ok[,c("Date", "PartidosGanadosUltMes")],
     n = 20)
# Win Rates Últimos 6, 3 y 1 meses ####

matches_nadal_ok$WRUlt6Meses <- 
  matches_nadal_ok$PartidosGanadosUlt6/matches_nadal_ok$PartidosUlt6Meses

matches_nadal_ok$WRUlt3Meses <- 
  matches_nadal_ok$PartidosGanadosUlt3/matches_nadal_ok$PartidosUlt3Meses

matches_nadal_ok$WRUltMes <- 
  matches_nadal_ok$PartidosGanadosUltMes/matches_nadal_ok$PartidosUltMes

# Elimino variables que no necesito

glimpse(matches_nadal_ok)

matches_nadal_ok <- matches_nadal_ok[,-c(31,30,29)] 

# Partidos del rival en los Últimos 6, 3 y 1 meses ####

# partidos ultimos 6 meses

glimpse(matches)
tail(matches, n = 20)

matches$Date <- ymd(matches$Date)


partidos_rival_ult6 <- function(fecha, rival) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-6*30)) %>% 
             filter(Winner == rival[[i]] | 
                      Loser == rival[[i]]) %>% 
             nrow()
    )
    
  }
  
  p
  
}

partidos_rival_ult6(ymd("2021-02-17"), "Tsitsipas S.")

matches %>% 
  filter(Date <= ymd("2021-02-17") &
           Date > (ymd("2021-02-17")-6*30)) %>% 
  filter(Winner == "Tsitsipas S." | 
           Loser == "Tsitsipas S.") %>% 
  print(n = Inf) #formula funciona OK


matches_nadal_ok$PartidosRivalUlt6Meses <- 
  partidos_rival_ult6(matches_nadal_ok$Date,
                      matches_nadal_ok$RivalName)

tail(matches_nadal_ok[,c("Date", "Result",
                         "RivalName", "PartidosRivalUlt6Meses")],
     n = 20)

matches_nadal_ok %>% ggplot() + 
  geom_density(aes(x = RankRival, color = Result)) +
  coord_cartesian(xlim = c(0, 200))

# Partidos ultimos 3 meses

partidos_rival_ult3 <- function(fecha, rival) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-3*30)) %>% 
             filter(Winner == rival[[i]] | 
                      Loser == rival[[i]]) %>% 
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosRivalUlt3Meses <- 
  partidos_rival_ult3(matches_nadal_ok$Date,
                      matches_nadal_ok$RivalName)

tail(matches_nadal_ok[,c("Date", "Result",
                         "RivalName", "PartidosRivalUlt3Meses")],
     n = 20)

# Partidos rivel ultimo mes

partidos_rival_ultmes <- function(fecha, rival) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-1*30)) %>% 
             filter(Winner == rival[[i]] | 
                      Loser == rival[[i]]) %>% 
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosRivalUltMes <- 
  partidos_rival_ultmes(matches_nadal_ok$Date,
                      matches_nadal_ok$RivalName)

tail(matches_nadal_ok[,c("Date", "Result",
                         "RivalName", "PartidosRivalUltMes")],
     n = 20)


# Partidos Ganados del Rival en los Últimos 6, 3 y 1 meses ####

partidos_ganadosrival_ult6 <- function(fecha, rival) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-6*30)) %>% 
             filter(Winner == rival[[i]]) %>% 
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosGanadosRivalUlt6 <- 
  partidos_ganadosrival_ult6(matches_nadal_ok$Date,
                        matches_nadal_ok$RivalName)


tail(matches_nadal_ok[,c("Date", "Result",
                         "RivalName", "PartidosRivalUlt6Meses",
                         "PartidosGanadosRivalUlt6")],
     n = 20)

# Partidos ganados rival ultimos 3 meses

partidos_ganadosrival_ult3 <- function(fecha, rival) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-3*30)) %>% 
             filter(Winner == rival[[i]]) %>% 
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosGanadosRivalUlt3 <- 
  partidos_ganadosrival_ult3(matches_nadal_ok$Date,
                             matches_nadal_ok$RivalName)


tail(matches_nadal_ok[,c("Date", "Result",
                         "RivalName", "PartidosRivalUlt3Meses",
                         "PartidosGanadosRivalUlt3")],
     n = 20)

# Partidos ganados rival ultimo mes

partidos_ganadosrival_ultmes <- function(fecha, rival) {
  
  p <- c()
  
  for (i in 1:length(fecha)) {
    
    p <- c(p,
           matches %>% 
             filter(Date <= fecha[[i]] & 
                      Date > (fecha[[i]]-1*30)) %>% 
             filter(Winner == rival[[i]]) %>% 
             nrow()
    )
    
  }
  
  p
  
}

matches_nadal_ok$PartidosGanadosRivalUltmes <- 
  partidos_ganadosrival_ultmes(matches_nadal_ok$Date,
                             matches_nadal_ok$RivalName)


tail(matches_nadal_ok[,c("Date", "Result",
                         "RivalName", "PartidosRivalUltMes",
                         "PartidosGanadosRivalUltmes")],
     n = 20)

# Win Rates Rival Últimos 6, 3 y 1 Meses ####

matches_nadal_ok$WRRivalUlt6Meses <- 
  matches_nadal_ok$PartidosGanadosRivalUlt6/matches_nadal_ok$PartidosRivalUlt6Meses

matches_nadal_ok$WRRivalUlt3Meses <- 
  matches_nadal_ok$PartidosGanadosRivalUlt3/matches_nadal_ok$PartidosRivalUlt3Meses

matches_nadal_ok$WRRivalUltMes <- 
  matches_nadal_ok$PartidosGanadosRivalUltmes/matches_nadal_ok$PartidosRivalUltMes

# Achico dataset

glimpse(matches_nadal_ok)

matches_nadal_ok <- matches_nadal_ok[,-c(37, 36, 35)]

summary(matches_nadal_ok)

# Métricas del Último Partido ####

# Sets ganados por nadal y por el rival

matches_nadal_ok$SetsNadal <- rep(NA, nrow(matches_nadal_ok))
matches_nadal_ok$SetsNadal[ganados] <-
  matches_nadal_ok$Wsets[ganados]
matches_nadal_ok$SetsNadal[perdidos] <-
  matches_nadal_ok$Lsets[perdidos]

matches_nadal_ok$SetsRival <- rep(NA, nrow(matches_nadal_ok))
matches_nadal_ok$SetsRival[ganados] <-
  matches_nadal_ok$Lsets[ganados]
matches_nadal_ok$SetsRival[perdidos] <-
  matches_nadal_ok$Wsets[perdidos]

matches_nadal_ok <- matches_nadal_ok[,-c(19,20)]

glimpse(matches_nadal_ok)

matches_nadal_ok2 <- as.data.frame(matches_nadal_ok)
matches_nadal_ok <- as_tibble(matches_nadal_ok2)
rm(matches_nadal_ok2)

# Sets ganados y perdidos nadal ultimo partido 

sets_ganadosnadal_ult <- function() {
  
  p <- 0
  
  for (i in (1:(nrow(matches_nadal_ok))-1)) {
    
    p <- c(p,
           matches_nadal_ok$SetsNadal[i])
    
  }
  
  p
  
}

matches_nadal_ok$SetsGanadosUltPartido <-
  sets_ganadosnadal_ult()


sets_perdidosnadal_ult <- function() {
  
  p <- 0
  
  for (i in (1:(nrow(matches_nadal_ok))-1)) {
    
    p <- c(p,
           matches_nadal_ok$SetsRival[i])
    
  }
  
  p
  
}

matches_nadal_ok$SetsPerdidosUltPartido <-
 sets_perdidosnadal_ult()

# Resultado ult partido y ronda

matches_nadal_ok$ResultUltPartido <-
  c(NA,
    as.character(matches_nadal_ok$Result[1:1106]))

matches_nadal_ok$RoundUltPartido <-
  c(NA,
    as.character(matches_nadal_ok$Round[1:1106]))

# H2H en Cantidad y WR ####

H2H_cantidad <- function (date) {
  
  p <- c()
  
  for (i in 1:length(date)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date < date[[i]] & 
                      RivalName == RivalName[[i]]) %>% 
              nrow()
          )
  }
  
  p
  
}

matches_nadal_ok$H2HPartidos <- 
  H2H_cantidad(matches_nadal_ok$Date)


#H2H ganados

H2H_ganados <- function (date) {
  
  p <- c()
  
  for (i in 1:length(date)) {
    
    p <- c(p,
           matches_nadal_ok %>% 
             filter(Date < date[[i]] & 
                      RivalName == RivalName[[i]] &
                      Result == "Win") %>% 
             nrow()
    )
  }
  
  p
  
}

matches_nadal_ok$H2HGanados <- 
  H2H_ganados(matches_nadal_ok$Date)

matches_nadal_ok$H2HWR <- 
  matches_nadal_ok$H2HGanados / matches_nadal_ok$H2HPartidos

# EXPORTO DATASET FINAL ####

save(matches_nadal_ok,
     file = "matches_nadal_ok.Rdata")
warnings()

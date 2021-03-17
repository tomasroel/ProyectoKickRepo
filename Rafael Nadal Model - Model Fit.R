# RAFAEL NADAL MODEL - MODEL FIT ####################################

# SETUP #############################################################

pacman::p_load(pacman, tidyverse, rio, magrittr, lubridate)

options(scipen = 999)

# DATA IMPORT #######################################################

matches_nadal_ok <- import("matches_nadal_ok.Rdata") %>% 
  as_tibble()

glimpse(matches_nadal_ok)

# SEPARO VARIABLES A UTILIZAR #######################################

variables <- c("Location", "Series", "Court", "Surface", "Date",
               "Round", "BestOf", "RankNadal", "RankRival",
               "PartidosUlt6Meses", "PartidosUlt3Meses", "PartidosUltMes",
               "WRUlt6Meses", "WRUlt3Meses", "WRUltMes",
               "PartidosRivalUlt6Meses", "PartidosRivalUlt3Meses",
               "PartidosRivalUltMes", "WRRivalUlt6Meses", "WRRivalUlt3Meses",
               "WRRivalUltMes", "SetsGanadosUltPartido", "SetsPerdidosUltPartido",
               "ResultUltPartido", "RoundUltPartido", "H2HPartidos", "H2HGanados",
               "Result")

df_matches <- matches_nadal_ok %>% 
  select(all_of(variables))

glimpse(df_matches)

# ELIMINO LAS PRIMERAS OBSERVACIONES #############################

#Estas no me sirven porque no tengo registro de los partidos anteriores

df_matches %>%
  select(Location, RankNadal,
         PartidosUlt6Meses, PartidosUlt3Meses, PartidosUltMes) %>% 
 print(n = 70)

#Elimino primeras 50 observaciones, a partir de ahi se nivela

df_matches <- df_matches[51:1107,]

# ALGUNOS PLOTS INTERESANTES #####################################

df_matches %>% 
  ggplot(aes(x = PartidosUlt6Meses, y = WRUlt6Meses,
             color = Result)) + 
  geom_jitter(width = 1.5) #Cuando jugó muchos partidos y con alto wr hay mas chance de ganar

df_matches %>% 
  ggplot(aes(x = RankNadal, y = RankRival,
             color = Result)) + 
  geom_jitter() + 
  coord_cartesian(ylim = c(0, 20),
                  xlim = c(0, 10))

df_matches %>% 
  ggplot(aes(x = Surface, fill = Result)) + 
  geom_bar(position = "fill")

df_matches %>% 
  ggplot(aes(x = BestOf, fill = Result)) + 
  geom_bar(position = "fill") + 
  facet_grid(.~Surface)

df_matches %>% 
  ggplot(aes(x = Round, fill = Result)) + 
  geom_bar(position = "fill") + 
  facet_grid(.~Surface) + 
  theme(axis.text.x = element_text(angle = 45))

glimpse(df_matches)

# SEPARO DATA TRAINING Y TEST ###################################

trainingSize <- 0.15

muestra <- sample(1:nrow(df_matches),
                  round(nrow(df_matches)*trainingSize,0),
                  replace = FALSE)

df_matches_test <- df_matches[muestra,]
df_matches_training <- df_matches[-muestra,]

#Otra opción es separar los partidos de 2020-21 para test

# df_matches_training <- df_matches %>% 
#   filter(Date < ymd("2020-01-01"))
# 
# df_matches_test <- df_matches %>% 
#   filter(Date >= ymd("2020-01-01") &
#            Date < ymd("2021-01-01"))



# COMPUTO LAS TASAS DE CORTE ###################################

# Probabilidad histórica de victoria Nadal =====================

df_matches %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() # La probabilidad histórica es 83,9%.

#Si digo gana, acierto el 83% de las veces.

# Probabilidad ultimos 2 años ==================================

df_matches %>% 
  filter(Date > ymd("2019-01-01")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #84,3% de las veces ganó

#Probabilidad 2020 en adelante =================================

df_matches %>% 
  filter(Date > ymd("2020-01-01")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #81,8% de las veces ganó

#Probabilidad post cuarentena ==================================

df_matches %>% 
  filter(Date > ymd("2020-08-01")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #78,26% de las veces ganó.

#Probabilidad 2021 =============================================

df_matches %>% 
  filter(Date > ymd("2020-12-31")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #80% pero con pocos partidos jugados.

# En definitiva, si yo digo que gana nadal siempre
# voy a acertar un 80%. Necesito un modelo que supere claramente ese nro
# O sea un modelo de + de 85% de acierto.

# AJUSTO MODELOS LOGIT ##########################################

glm.fit <- glm(Result ~ RankNadal + RankRival + Surface +
                 WRUlt3Meses + WRRivalUlt3Meses + H2HPartidos + 
                 H2HGanados,
               data = df_matches_training,
               family = binomial)

summary(glm.fit)

glm.probs <- predict(glm.fit, df_matches_test,
                     type = "response")

contrasts(df_matches_training$Result)

glm.pred <- rep("Lose", 159)
glm.pred[glm.probs > 0.8] = "Win"

table(glm.pred, df_matches_test$Result)

# Modelo 2 ==========================================================

glm.fit2 <- glm(Result ~ RankNadal + RankRival + Surface +
                 WRUlt3Meses + WRRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf,
               data = df_matches_training,
               family = binomial)

summary(glm.fit2)

glm.probs2 <- predict(glm.fit2, df_matches_test,
                     type = "response")

contrasts(df_matches_training$Result)

glm.pred2 <- rep("Lose", 159)
glm.pred2[glm.probs2 > 0.55] = "Win"

table(glm.pred2, df_matches_test$Result)

(122+24)/159
124/127




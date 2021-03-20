# RAFAEL NADAL MODEL - MODEL FIT ####################################

# SETUP #############################################################

pacman::p_load(pacman, tidyverse, rio, magrittr, lubridate,
               boot)

options(scipen = 999)

# DATA IMPORT #######################################################

matches_nadal_ok <- import("Output/matches_nadal_ok.Rdata") %>% 
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

# SEPARO DATA POST 2020 ###################################
#Esta data la voy a usar como testeo final

df_matches %>% 
  filter(Date >= "2020-01-01") #son 33 partidos

df_matches_train <- df_matches %>% 
  filter(Date < "2020-01-01")
  
df_matches_test <- df_matches %>% 
  filter(Date >= "2020-01-01")

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

#En clay 2019 en adelante

df_matches %>% 
  filter(Date > ymd("2018-12-31") & 
           Surface == "Clay") %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #90% en clay


# PRUEBA DE VARIABLES ##########################################

#El primer approach es varios modelos logit para ver la capacidad
#predictiva de las variables

#Modelo 1 ======================================================
glm.fit1 <- glm(Result ~ RankNadal + RankRival + Surface +
                 WRUlt3Meses + WRRivalUlt3Meses + H2HPartidos + 
                 H2HGanados,
               data = df_matches_train,
               family = binomial)

summary(glm.fit1)

#De acá se desprende que el WR es importante. Surface tambien. H2H no parece
 
 
# glm.probs <- predict(glm.fit, df_matches_test,
#                      type = "response")
# 
# contrasts(df_matches_training$Result)
# 
# glm.pred <- rep("Lose", 159)
# glm.pred[glm.probs > 0.8] = "Win"
# 
# table(glm.pred, df_matches_test$Result)

#Modelo 2 ==========================================================

glm.fit2 <- glm(Result ~ RankNadal + RankRival + Surface +
                 WRUlt3Meses + WRRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf,
               data = df_matches_train,
               family = binomial)

summary(glm.fit2)

#WR es muy importante. Partidos jugados tambien. Round y Surface tambien.
#Rank más o menos.

glm.probs2 <- predict(glm.fit2, df_matches_test,
                     type = "response")

contrasts(df_matches_train$Result)

glm.pred2 <- rep("Lose", 33)
glm.pred2[glm.probs2 > 0.55] = "Win"

table(glm.pred2, df_matches_test$Result)

# Modelo 3 ======================================================

#Voy a dejar solo ultimos 3 y ultimos 6 meses

glm.fit3 <- glm(Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses +
                  PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  WRUlt6Meses + WRRivalUlt6Meses + PartidosUlt6Meses +
                  PartidosRivalUlt6Meses + Round + BestOf,
                data = df_matches_train,
                family = binomial)

summary(glm.fit3)

glm.probs3 <- predict(glm.fit3, df_matches_test,
                      type = "response")

glm.pred3 <- rep("Lose", 33)
glm.pred3[glm.probs3 > 0.55] = "Win"

table(glm.pred3, df_matches_test$Result)

# Modelo 4 =====================================================
# Ahora junto todas las variables que me dieron resultado

glm.fit4 <- glm(Result ~  Surface + WRUlt3Meses + WRRivalUlt3Meses +
                  PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + RankNadal + RankRival,
                data = df_matches_train,
                family = binomial)

summary(glm.fit4)

# Modelo 5 =====================================================

glm.fit5 <- glm(Result ~  Surface + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + RankNadal + RankRival,
                data = df_matches_train,
                family = binomial)

summary(glm.fit5)

glm.probs5 <- predict(glm.fit5, df_matches_test,
                      type = "response")

glm.pred5 <- rep("Lose", 33)
glm.pred5[glm.probs5 > 0.55] = "Win"

table(glm.pred5, df_matches_test$Result) #Empeora

# Modelo 6 ====================================================

#Uso resultados del ult mes y de los ult 6 meses

glm.fit6 <- glm(Result ~  Surface + WRUlt6Meses + WRRivalUlt6Meses +
                  PartidosUlt6Meses + PartidosRivalUlt6Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + ResultUltPartido,
                data = df_matches_train,
                family = binomial)

summary(glm.fit6)

glm.probs6 <- predict(glm.fit6, df_matches_test,
                      type = "response")

glm.pred6 <- rep("Lose", 33)
glm.pred6[glm.probs6 > 0.55] = "Win"

table(glm.pred6, df_matches_test$Result)

#La info del ultimo partido no es muy relevante

# Modelo 7 =====================================================

#Pruebo solo con info ult mes y ult 6 mas extras

glm.fit7 <- glm(Result ~  Surface + WRUlt3Meses + WRRivalUlt3Meses +
                  PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + RankNadal + RankRival,
                data = df_matches_train,
                family = binomial)

summary(glm.fit7)

glm.probs7 <- predict(glm.fit7, df_matches_test,
                      type = "response")

glm.pred7 <- rep("Lose", 33)
glm.pred7[glm.probs7 > 0.55] = "Win"

table(glm.pred7, df_matches_test$Result)

#Las del modelo 7 seran las variables seleccionadas.
#Ahora trabajo en la flexibilidad del modelo

# MODEL FLEXIBILITY ###########################################

#CV test error glm.fit7 =======================================

set.seed(17)

cv.error <- cv.glm(df_matches_train,
                   glm.fit7,
                   K = 10)

cv.error$delta

#CV test error comparison =====================================

set.seed(24)
cv.error <- rep(0, 7)

for (i in 1:7) {
  
  cv.error[i] = 
    cv.glm(df_matches_train,
           get(
             paste("glm.fit", i, sep = "")
             ),
           K = 10)$delta[1]
  
}


cv.error %<>%
  as_tibble() %>% 
  mutate(Modelo = seq(1:7)) %>% 
  rename(cv.error = value)

cv.error %>% 
  ggplot(aes(x = Modelo, y = cv.error)) +
  geom_line() + 
  geom_point() + 
  theme_classic() + 
  scale_x_continuous(n.breaks = 7)



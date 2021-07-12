p_load(rgl, Rtsne)

?princomp

#En primer lugar, seleccionaremos las variables que formaran parte del modelo

pca_matches <- df_matches[,-c(1,2)]

#Transformamos Result y ResultUltPartido en variables numericas

pca_matches %<>% 
  mutate(ResultUltPartido = recode(ResultUltPartido, "Win" = 1, "Lose" = 0),
         Result = recode(Result, "Win" = 1, "Lose" = 0))

glimpse(pca_matches)
pca_matches <- pca_matches[,-3] 
pca_matches %<>% 
  mutate(RoundUltPartido = as.factor(RoundUltPartido))

#Ahora transformo todas las variables categoricas en numericas

dummy <- dummyVars("~.", data = pca_matches)
data_pca <- as_tibble(predict(dummy, newdata = pca_matches))

data_pca <- as.matrix(data_pca)

prepoc1 <- preProcess(data_pca[,c(15:31,41:42)], method = c("range"))
norm1 <- predict(prepoc1, data_pca[,c(15:31,41:42)])
summary(norm1)

data_pca <- cbind(norm1, data_pca[,-c(15:31,41:42)])
summary(data_pca)

#Elimino los 15 registros que tienen NA values

data_pca <- data_pca[-which(is.na(data_pca[,17])),]

summary(data_pca)

rm(norm1, dummy, prepoc1, pca_matches)

#Aplico PCA testeo. Solo variables continuas

data_pca <- data_pca[,c(2:17,43)]

pc.nadal <- princomp(data_pca[,-17])
names(pc.nadal)
pca.scores <- pc.nadal$scores %>% 
  as_tibble()
pca.scores <- cbind(pca.scores, Result = data_pca[,17])

#ploteo de componentes y resultado

color <- rep("green", nrow(data_pca))
color[which(data_pca[,17]==0)] = "red"
color

#ploteo 3 pc

open3d()
plot3d(pca.scores[1:3], col = color)
legend3d("topright", legend = c("Win", "Lose"),
         pch = 16, col = c("green", "red"),
         cex = 1, inset = c(0.02))


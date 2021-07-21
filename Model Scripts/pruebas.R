rare.class.prevalence = 0.65
rf.fit <- randomForest(Result~.,
             data = df_matches[1:1034,-3],
             ntree = 1000, 
             mtry = 5,
             cutoff = c(1-rare.class.prevalence, rare.class.prevalence),
             na.action = na.omit)

rf.fit
rf.fit$err.rate[1000,1]

pred <- predict(rf.fit, newdata = df_matches[1035:1079,-c(3,26)])

cf <- confusionMatrix(pred, df_matches[1035:1079,]$Result)
cf

prop.lose <- df_matches[1:1034,-3] %>% 
  select(Result) %>% 
  table() %>%
  prop.table() %>% 
  as_tibble()

nRareSample = 1034*prop.lose$n[1]
rf.fit2 <- randomForest(Result~.,
                       data = df_matches[1:1034,-3],
                       ntree = 1000, 
                       mtry = 5,
                       strata = df_matches[1:1034,]$Result,
                       sampsize = c(nRareSample, nRareSample),
                       na.action = na.omit)

print(rf.fit2)

pred2 <- predict(rf.fit2, newdata = df_matches[1035:1079,-c(3,26)])

table(pred = pred2, real = df_matches[1035:1079,]$Result)

wt = sum(df_matches[1:1034,]$Result == "Lose") / length(df_matches[1:1034,]$Result)
wy = length(df_matches[1:1034,]$Result)
rf.fit3 <- randomForest(Result~.,
                        data = df_matches[1:1034,-3],
                        ntree = 1000, 
                        mtry = 5,
                        classwt = c(wt, wy),
                        na.action = na.omit)

print(rf.fit3)

pred3 <- predict(rf.fit3, newdata = df_matches[1035:1079,-c(3,26)])

confusionMatrix(pred3,df_matches[1035:1079,]$Result)
37/45

# RAFAEL NADAL MODEL - MODEL FIT ####################################

# SETUP #############################################################

pacman::p_load(pacman, tidyverse, rio, magrittr)

options(scipen = 999)

# DATA IMPORT #######################################################

matches_nadal_ok <- import("matches_nadal_ok.Rdata") %>% 
  as_tibble()

glimpse(matches_nadal_ok)

# SEPARO VARIABLES A UTILIZAR #######################################

variables <- c("Location", "Series", "Court", "Surface",
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


# AJUSTO MODELOS LOGIT ##########################################



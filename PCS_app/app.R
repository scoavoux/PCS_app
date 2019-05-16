library(shiny)
library(tidyverse)
library(questionr)
library(janitor)
library(here)

vars <- read_csv(here("PCS_app", "data", "variables.csv"))
datasets <- read_csv(here("PCS_app", "data", "datasets.csv"))
d <- map(here("PCS_app", datasets$path), read_csv)
names(d) <- datasets$dataset

# TEMPORAIRE: devrait se faire près appli
d$eec <- rename(d$eec, 
                gsp = "gsp_tous",
                csi = "csi_tous",
                csd = "csd_tous")

d <- map(d, function(df){
  mutate(df, gsp = factor(gsp, levels = c("Agriculteurs exploitants",
                                          "Artisans, commerçants, chefs d'entreprise", 
                                          "Cadres et professions intellectuelles supérieures",
                                          "Professions intermédiaires",
                                          "Employés",
                                          "Ouvriers", 
                                          "Inactifs ayant déjà travaillé", 
                                          "Autres inactifs")))
})

## Fonction créant les tableaux
tab <- function(df, var, pcs){
  df <- filter(df, !is.na(!! sym(pcs)))
  
  if(is.character(df[[var]])) {
    tb <- tabyl(df, !! sym(pcs), !! sym(var)) %>% 
      adorn_totals(c("row", "col")) %>%
      adorn_percentages("row") %>% 
      adorn_pct_formatting() %>% 
      adorn_ns()
    
    # tb <- count(df, !! sym(var), !! sym(pcs)) %>% spread()
  }
  else if(is.numeric(df[[var]])) {
    # todo: ajouter le total
    tb <- group_by(df, !! sym(pcs)) %>%
      summarize(min = min(!! sym(var)),
                q1 = quantile(!! sym(var), .25),
                moyenne = mean(!! sym(var)),
                mediane = median(!! sym(var)),
                q3 = quantile(!! sym(var), .75),
                max = max(!! sym(var)),
                effectif = n())
  }
  return(tb)  
}

theme_set(theme_bw())

## Fonction créant les graphiques

graph <- function(df, var, pcs){
  
  df <- filter(df, !is.na(!! sym(pcs)))
  
  if(is.character(df[[var]])) {
    gr <- ggplot(df, aes(x = !! sym(pcs), 
                         y = (..count..)/sum(..count..),
                         fill = !! sym(var))) +
      geom_bar(position = "dodge") +
      coord_flip()
  }
  else if(is.numeric(df[[var]])) {
    gr <- ggplot(df, aes(x = !! sym(pcs), y = !! sym(var))) +
      geom_boxplot() +
      coord_flip()
  }
  return(gr)  
}

filter_champ <- function(df, champ){
  if(champ == "Ensemble de la population ayant déjà travaillé") {
    df <- filter(df, statut_activite %in% c("Actifs occupés", "Inactifs", "Chômeurs"))
  } else if(champ == "Ensemble des actifs"){
    df <- filter(df, statut_activite %in% c("Actifs occupés", "Chômeurs"))
  } else if(champ == "Actifs occupés"){
    df <- filter(df, statut_activite %in% c("Actifs occupés"))
  } else if(champ == "Chômeurs et inactifs"){
    df <- filter(df, statut_activite %in% c("Inactifs", "Chômeurs"))
  }
  return(df)
}

## UI
ui <- fluidPage(
  # Titre général
  titlePanel("PCS 2020"),
  
  sidebarLayout(
    # Zone de choix à droite
    sidebarPanel = sidebarPanel(
      # choix du theme
      selectInput("theme", label = h3("Sélectionnez une thématique"), 
                  choices = unique(vars$theme)),
      # les autres choix, dynamiques, soit dans server
      selectInput("variable", label = h3("Sélectionnez une variable"), 
                  choices = unique(vars$variable)),
      selectInput("pcslevel", label = h3("Sélectionnez un niveau de PCS"), 
                  choices = list("Groupe socio-professionnel" = "gsp",
                                 "Catégorie socio-professionnelle" = "csi",
                                 "Catégorie socio-professionnelle détaillée" = "csd"), 
                  selected = 1),

      selectInput("champ", label = h3("Sélectionnez un champ"), 
                  choices = list("Ensemble de la population ayant déjà travaillé",
                                 "Ensemble des actifs",
                                 "Actifs occupés",
                                 "Chômeurs et inactifs"), 
                  selected = 1),
      downloadButton("dlTable", "Télécharger le tableau"),
      downloadButton("dlGraph", "Télécharger le graphique")
    ),
    
    # Zone de résultat
    mainPanel = mainPanel(
      tableOutput(outputId = "table"),
      plotOutput(outputId = "graph"),
      textOutput(outputId = "source"),
      textOutput(outputId = "champ")
    )
  )
)
  
## Serveur
server <- function(input, output){
  
  # available_variables <- reactiveVal()
  # observeEvent(input$theme, {
  #   available_variables(unique(vars$variable[vars$theme == input$theme]))
  #   print(paste0("Succesfully updated, new value: ", available_variables()))
  # })

  output$table <- renderTable(tab(df = filter_champ(df = d[[vars$dataset[vars$variable == input$variable]]],
                                                    champ = input$champ), 
                                  var = input$variable, 
                                  pcs = input$pcslevel))
  output$graph <- renderPlot(graph(df = filter_champ(df = d[[vars$dataset[vars$variable == input$variable]]],
                                                   champ = input$champ), 
                                 var = input$variable, 
                                 pcs = input$pcslevel))
  output$source <- renderText(paste0("Source : " , datasets$fullname[datasets$dataset == vars$dataset[vars$variable == input$variable]]))
  output$champ  <- renderText(paste0("Champ : ", input$champ))
  output$dlTable <- downloadHandler(
    filename = "tableau.csv",
    content = function(file) {
      write_csv(tab(df = filter_champ(df = d[[vars$dataset[vars$variable == input$variable]]],
                                      champ = input$champ), 
                    var = input$variable, 
                    pcs = input$pcslevel), 
                file)
    }
  )
  output$dlGraph <- downloadHandler(
    filename = "graphique.png",
    content = function(file) {
      ggsave(file, 
             graph(df = filter_champ(df = d[[vars$dataset[vars$variable == input$variable]]],
                                     champ = input$champ), 
                   var = input$variable, 
                   pcs = input$pcslevel))
    }
  )
}

# Lancer l'application
shinyApp(ui = ui, server = server)
library(shiny)
library(tidyverse)
library(questionr)
library(janitor)

vars <- read_csv("data/variables.csv")
datasets <- read_csv("data/datasets.csv")
d <- map(datasets$path, read_csv)
names(d) <- datasets$dataset
# TEMPORAIRE: devrait se faire près appli
d$eec <- rename(d$eec, 
                gsp = "gsp_tous",
                csi = "csi_tous",
                csd = "csd_tous")

## Fonction créant les tableaux
tab <- function(df, var, pcs){
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

## Fonction créant les graphiques

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
      uiOutput("varSelection"),
      selectInput("pcslevel", label = h3("Sélectionnez un niveau de PCS"), 
                  choices = list("Groupe socio-professionnel" = "gsp",
                                 "Catégorie socio-professionnelle" = "csi",
                                 "Catégorie socio-professionnelle détaillée" = "csd"), 
                  selected = 1),

      selectInput("champ", label = h3("Sélectionnez un champ"), 
                  choices = list("Ensemble de la population ayant déjà travaillé" = 1,
                                 "Ensemble des actifs" = 2,
                                 "Actifs occupés" = 3,
                                 "Chômeurs et inactifs" = 4), 
                  selected = 1),
      uiOutput("champSelection")
    ),
    
    # Zone de résultat
    mainPanel = mainPanel(
      tableOutput(outputId = "table")
    )
  )
)
  
## Serveur
server <- function(input, output){
  output$varSelection <- renderUI({
    selectInput("variable", label = h3("Sélectionnez une variable"), 
                choices = vars$variable[vars$theme == input$theme])
  })
  output$table <- renderTable(tab(df = d[["eec"]], 
                                  var = input$variable, 
                                  pcs = input$pcslevel))
}

# Lancer l'application
shinyApp(ui = ui, server = server)
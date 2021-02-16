
#install.packages("shinydashboard", "shinyjs")
library(shinydashboard)
library(shinyjs)

options(shiny.port = 8080)
options(shiny.host = "0.0.0.0")
BASE_DIR <- paste(getwd(), "./")


ui_sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Motion DB Viewer", tabName = "View", icon = icon("dashboard"))
    #menuItem("Animation DB Lookup", tabName = "dbLookup", icon = icon("th"))
  )
)

ui_header <- dashboardHeader(
  title = "Animation DB Viewer"
)

ui_body <- dashboardBody(
  
  #useShinyalert(),
  useShinyjs(),
   
  tags$head(
    tags$style(HTML("hr {border-top: 1px solid #000000;}"))
  ),
  tabItems(
    # First tab content
    tabItem(tabName = "View",
            
              #main content
              fluidRow(
                     tags$head(HTML('<meta charset="utf-8">
           <meta content="text/html;charset=utf-8" http-equiv="Content-Type">
	<meta content="utf-8" http-equiv="encoding">
	<meta http-equiv="X-UA-Compatible" content="IE=11,chrome=1">
	<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
	<meta property="og:image" content="http://lo-th.github.io/olympe/res/img/logo.png"/>
	<meta property="og:title" content="Advanced Morphing"/>
	<meta property="og:url" content="http://lo-th.github.io/olympe/"/>
	<meta property="og:site_name" content="LOTH"/>
	<meta property="og:type" content="website"/>
	<meta property="og:description" content="Experiment full morphing in webGl"/>
	<meta name="language" content="en-us" />
	<link rel="shortcut icon" href="res/img/favicon.ico" type="image/x-icon" />
	<link href="css/dianna.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="history/history.css" />
	
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>')),
                     includeScript("./js/three.min.66.js"),
                     includeScript("./js/BufferGeometryUtils.66.js"),
                     includeScript("./js/Bvh.js"),
                     includeScript("./js/libs/dat.gui.min.js"),
                     
                     htmlOutput("bvh_viewer"),

            ),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            
            fluidRow(
              column(8,
              DT::dataTableOutput("animation_search_results"),
              offset = 2
              ),
              
            ),
            br(),
            br(),
           
            fluidRow(
              column(2, offset = 5,
                actionButton("add_to_export_list", "Add animation to export list"),
              )

            ),
            fluidRow(
              column(2, offset = 5,
                uiOutput('undoUI'),
              )
            ),
            
            fluidRow(
              column(2, offset = 5,
                     actionButton("clear_export_list", "Clear export list")
              )
            ),
            hr(),
            fluidRow(
              column(8, offset = 5, h2("Export List"))
            ),
            fluidRow(
              column(8,
                     DT::dataTableOutput("animations_to_export"),
                     offset = 2
              ),
              
            ),
            br(),
            
            br(),
            fluidRow(
              column(2, offset = 5,
                #downloadLink("downloadData", "Download")
                downloadButton("downloadData", "download selected")
              )
            )
    )
  )
)

ui <- dashboardPage(ui_header, ui_sidebar,ui_body, skin ='blue')



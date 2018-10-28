

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Thailand Lottery Results Prediction"),
  strong("Chonlatit Prateepmanovong"),
  p("27 October 2018"),
  hr(),
  HTML("<h3>Description</h3>Web application for explore and predict result of Thailand lottery by using Linear Regression.<br />
       The lottery data, 2-digits results with date from 1990-04-16 to 2018-10-16 are provided, is used to be <strong>training</strong> data.<br />
       This data is seperated by each results and fit it in Linear models (lm).<br />
       <strong>One model for each result.</strong><br />
       Then, Next appearances (predictors) of each result are predicted by these models and display results which will appear in range around the date that set.
       <br />"),
  br(),

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       h3("Data Selection"),
       p("select the range of results and years for exploration and prediction."),
       sliderInput("result",
                   "Choose lottery result range :",
                   min = 0,
                   max = 99,
                   value = c(0,99)),
       sliderInput("year",
                   "Choose year range :",
                   min = 1990,
                   max = 2018,
                   value = c(2000,2018)),
       hr(),
       h3("Prediction"),
       p("put the date that want to predict the results and choose the acceptable tolerance."),
       HTML("<strong>Example </strong>:<br /> Date,we want to predict, is 2018-11-01 tolerance is 15.<br/>
               Predicted results which appear in 2018-11-01 ± 15 days will be displayed.<br />
            "),br(),
       dateInput("date", label = "Date we want to predict results :"),
       sliderInput("date_slide",
                   "Tolerance (days) :",
                   min = 0,
                   max = 360,
                   value = 15,
                   step = 15),
       hr()
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       tabsetPanel(type = "tabs",
                   tabPanel("Exploration",
                            h3("Lottory results plot"),
                            p("Explore the appearances and patterns of results."),
                            p("select data from the Data selection part in the left sidebar to re-plot the graph."),
                            br(),
                            plotOutput("plot1")
                            ),
                   tabPanel("Prediction",
                           h3("Linear model prediction"),
                           p("Fit linear model from each result and predict the date of next appearance of it."),
                           p("select data in the Data selection part in left sidebar to re-predict results."),
                           p("put date that you want to predict results and choose tolerance in the Prediction part in left sidebar."),
                           hr(),
                           h4("Linear regression plots"),
                           HTML("n = appearances of each result<br />
                                date = date that result appear<br />
                                <font color = red>*red point is next appearance of result</font>
                                <br /><br />"),
                           plotOutput("plot2"),
                           br(),
                           h4("Result table"),
                            
                            p("show the results which have next appearance date from prediction match the input date and tolerance sorting by diff (difference between input date and predicted date)"),
                            HTML("<strong>result</strong> = lottery result from prediction that match requirement<br />
                                    <strong>new_n</strong> = number of next appearances<br />
                                    <strong>next_date</strong> = predicted date<br />
                                    <strong>pval</strong> = p-value of this result model<br />
                                    <strong>r2</strong> = r-squared of this result model<br />  
                                    <strong>diff</strong> = difference between input date and predicted date (days)<br /> <br />"),
                            tableOutput("table1")
                   )
                               
                            
                   )
       
    )
  )
))

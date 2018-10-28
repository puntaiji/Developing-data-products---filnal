

library(shiny)

shinyServer(function(input, output) {
  
  library(dplyr)
  library(ggplot2)
  
  ## get Data
  data_lotto <- read.table("data_lotto_two.txt",sep="\t",header = T,colClasses = c("character","character"))
  data_lotto$date <- as.Date(data_lotto$date,origin = "1970-01-01")
  
  output$plot1<- renderPlot({
    ## subsetting data
    data_lotto.two <- data_lotto %>% filter(as.numeric(substring(as.character(date),1,4)) %in% input$year[1]:input$year[2], as.numeric(result) %in% input$result[1]:input$result[2])
    ## plot graph
    data_lotto.two %>% ggplot(aes(x = date,y= result,color=result)) + geom_point() + geom_line() + labs(x = "Date", y ="Lottery Results",color ="Lottery Results" )
  })
  
  output$plot2 <- renderPlot({
    ## subsetting data
    data_lotto.two <- data_lotto %>% filter(as.numeric(substring(as.character(date),1,4)) %in% input$year[1]:input$year[2], result %in% input$result[1]:input$result[2])
    
    ## create table for each result with dates (date) and apparearance times (n)
    two.list <- tapply(data_lotto.two$date,
                       data_lotto.two$result,
                       function(x){
                         data.frame(date = x[order(x)],n = 1:length(x))
                         })
    result <- names(two.list)
    two <- data.frame(result = character(),date = vector(),n = integer())
    
    ## fit linear model and predict date of next appearance for each result.
    pred <- data.frame(result = character(),
                       next_date = vector(),
                       pval = numeric(),
                       r2 = numeric())
    for(i in 1:length(result)){
      if(nrow(two.list[[i]]) > 2){
        two <- rbind(two,
                     data.frame(result = result[i],
                                date = as.Date(as.character(two.list[[i]]$date),
                                               origin = "1970-01-01"),
                                n = two.list[[i]]$n)
                     )
        ## fit linear model
        fit <- lm(date ~ n, 
                  data = data.frame(date = as.numeric(two.list[[i]]$date),
                                    n = as.integer(two.list[[i]]$n))
                  )
        
        ## get predicted next appearance date.
        pred <- rbind(pred,
                      data.frame( result = result[i],new_n = max(two.list[[i]]$n)+1,
                                  next_date = predict.lm(fit,data.frame(n = max(two.list[[i]]$n)+1)),
                                  pval = summary(fit)$coef[2,4],
                                  r2 = summary(fit)$r.squared)
                      )
      }
    }
      ## find difference of result next appearance date with the input date
      pred$diff <- abs(as.numeric(as.Date(pred$next_date,origin = "1970-01-01") - input$date)) 
      ## filter results which in tolerance
      pred_res <- pred %>% arrange(diff) %>% filter(diff < input$date_slide)
      pred_res$next_date <- as.Date(ceiling(pred_res$next_date),origin = "1970-01-01")
      pred_res <- pred_res[order(pred_res$diff),]
      
      ## check result is available
      if(nrow(pred_res) > 0){
        ## plot graph and render table
        g <- merge(two,pred_res,by="result",all.x = T) %>% filter(result %in% pred_res$result) %>% ggplot(aes(x = date,y= n)) + geom_point() + geom_point(aes(x=next_date, y=new_n), colour="red", size = 3) +  stat_smooth(method = "lm") + facet_wrap(~result,scales = "free",nrow = 3)
        pred_res$next_date <- format(as.Date(pred_res$next_date,origin = "1970-01-01"),"%Y-%m-%d")
        pred_res$pval <- format(pred_res$pval,nsmall = 6)
        pred_res$r2 <- format(pred_res$r2,nsmall = 6)
        output$table1 <- renderTable({pred_res})
        g
      }else{
        ## show no results
        output$table1 <- renderTable({pred_res})
        ggplot() + annotate("text", x = 4, y = 25, size=8, label = "No predicted result.") 
      }
    
  })
  

  
})

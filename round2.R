setwd(".../files")

Sys.setenv(TZ = 'UTC') # System timezone is UTC now
Sys.setlocale("LC_ALL", 'en_US.UTF-8') # All characters are UTF-8

require(data.table)
require(dplyr)
require(ggplot2)
require(ggcharts)
require(xts)

if(any(ls() == "a")){
  rm(a)
}

for(i in grep(list.files(), pattern = ".csv")){
  if(!exists("a")){
    a <- fread(list.files()[i])
    a$ID <- as.character(a$ID)
  }else{
    a2 <- fread(list.files()[i])
    a2$ID <- as.character(a2$ID)
    a <- bind_rows(a,a2)
  }
}

df <- a
rm(a2,i)

df <- arrange(df[!duplicated(df),],as.POSIXct(datetime))
  

wyb2 <- df
wyb2 <- wyb2[which(!duplicated(wyb2$usernameTweet)),]
wyb2 <- wyb2[which(!duplicated(wyb2$text)),]
wyb2$text <- tolower(wyb2$text)

wyb2 <- wyb2[which(as.POSIXct(wyb2$datetime) >= as.POSIXct("2020-06-29")),]

candids_ <- c("duda", "dudę","dudy", "dudą","dudzie","dudo",
              "trzaskowski","trzaskowskiemu","trzaskowskiego","trzaskowskim")

candids_df <- data.frame(sapply(candids_, grepl, wyb2$text))

candids_df <- bind_cols(data.table(ifelse(candids_df == "TRUE", 1, 0)),
                        data.table(rowSums(ifelse(candids_df == "TRUE", 1, 0))))

candids_df$duda_sum <- rowSums(candids_df[,1:6])
candids_df$trzas_sum <- rowSums(candids_df[,7:10])
candids_df$duda_sum <- ifelse(candids_df$duda_sum >=1, 1, 0)
candids_df$trzas_sum <- ifelse(candids_df$trzas_sum >=1, 1, 0)

candids_df <- candids_df[,(ncol(candids_df)-1):ncol(candids_df)]
colnames(candids_df) <- c("duda", "trzaskowski")
candids_df <- candids_df %>% mutate(sum=rowSums(candids_df))

candids_xts <- candids_df %>% mutate(datetime=wyb2$datetime)
candids_df <- candids_df[which(candids_df$sum!=0),]

candids_xts <- candids_xts[which(candids_xts$sum!=0),]
candids_xts <- xts::xts(data.frame(candids_xts)[,-4],as.POSIXlt(data.frame(candids_xts)[,4]))

candids_df <- candids_df %>% select(-sum)/t(candids_df %>% select(sum))
candids_xts$duda <- candids_xts[,1] / candids_xts$sum
candids_xts$trzaskowski <- candids_xts[,2] / candids_xts$sum
candids_xts <- candids_xts[,-3]

#plot(cumsum(candids_xts)/rowSums(cumsum(candids_xts)), main = "Fluid opinions")

df <- data.frame(nr_tweet = colSums(candids_df))

df_result <- data.frame(candidate = rownames(df), pct = 100*round(data.frame(pct = df[,1]/sum(df)),4)[,1])
df_result <- data.frame(ratio = df_result[order(df_result$pct,decreasing = TRUE),])
colnames(df_result) <- c("candidate", "pct")

chart <- df_result %>% bar_chart(candidate, pct) + labs(title = paste0("Opinion Poll - ", as.Date(tail(wyb2$datetime,1)))) 
chart + geom_text(aes(label = paste0(pct, "%"), hjust = 1.0), color = "white")

# Daily received
my.endpoints <- endpoints(candids_xts, on = "days", k=1)
my.endpoints[2:(length(my.endpoints)-1)] <- my.endpoints[2:(length(my.endpoints)-1)]+1
daily_rate <- period.apply(candids_xts, INDEX = my.endpoints, FUN = function(x) apply(x,2,sum, na.rm=T))

daily_rate$duda_pct <- round(daily_rate$duda/rowSums(daily_rate), 4)
daily_rate$trzas_pct <- round(daily_rate$trzas/rowSums(daily_rate), 4)
plot(daily_rate[,-c(1,2)], main = "Daily rate per candidate")

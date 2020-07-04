setwd(".../files")

Sys.setenv(TZ = 'UTC') # System timezone is UTC now
Sys.setlocale("LC_ALL", 'en_US.UTF-8') # All characters are UTF-8

require(data.table)
require(dplyr)
library(ggplot2)
library(ggcharts)

for(i in grep(list.files(), pattern = ".csv")){
  assign(value = fread(list.files()[i]), x = paste0("df_",i))
  # assign(value = as.character(data.frame(get(paste0("df_",i)))[,colnames(get(paste0("df_",i))) %in% "ID"]),
  #      x = data.frame(get(paste0("df_",i)))[,colnames(get(paste0("df_",i))) %in% "ID"])
}

df <- arrange(dplyr::union(df_1,df_2,df_3,df_4,df_5,df_6), datetime)

wyb2 <- df
rm(df_1,df_2,df_3,df_4,df_5,df_6,i)

wyb2 <- wyb2[which(!duplicated(wyb2$usernameTweet)),]
wyb2 <- wyb2[which(!duplicated(wyb2$text)),]
wyb2$text <- tolower(wyb2$text)

wyb2 <- wyb2[which(as.POSIXct(wyb2$datetime) >= as.POSIXct("2020-06-30")),]

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

candids_df <- candids_df[which(candids_df$sum!=0),]

candids_df <- candids_df %>% select(-sum)/t(candids_df %>% select(sum))

df <- data.frame(nr_tweet = colSums(candids_df))

df <- data.frame(candidate = rownames(df), pct = 100*round(data.frame(pct = df[,1]/sum(df)),4)[,1])
df <- data.frame(ratio = df[order(df$pct,decreasing = TRUE),])
colnames(df) <- c("candidate", "pct")
                   
chart <- df %>% bar_chart(candidate, pct) %>% print()
chart + geom_text(aes(label = paste0(pct, "%"), hjust = 1.0), color = "white")

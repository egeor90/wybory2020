Sys.setenv(TZ = 'UTC') # System timezone is UTC now
Sys.setlocale("LC_ALL", 'en_US.UTF-8') # All characters are UTF-8

require(data.table)
require(dplyr)
library(ggplot2)
library(ggcharts)

wyb2 <- dplyr::arrange(dplyr::union(data.table::fread(".../wybory2020.csv"),
                                       data.table::fread(".../wybory2020e.csv")), 
                          datetime)

wyb2 <- wyb2[which(!duplicated(wyb2$usernameTweet)),]
wyb2 <- wyb2[which(!duplicated(wyb2$text)),]
wyb2$text <- tolower(wyb2$text)


candids_ <- c("biedroń", "bosak", "duda", "hołownia","jakubiak",
              "kosiniak-kamysz","piotrowski","tanajno","trzaskowski","witkowski",
              "żółtek")
candids_df <- data.frame(sapply(candids_, grepl, wyb2$text))


candids_df <- bind_cols(data.table(ifelse(candids_df == "TRUE", 1, 0)),
                        data.table(rowSums(ifelse(candids_df == "TRUE", 1, 0))))
colnames(candids_df)[ncol(candids_df)] <- "sum"

candids_df <- candids_df[which(candids_df$sum!=0),]

candids_df <- candids_df %>% select(-sum)/t(candids_df %>% select(sum))

df <- data.frame(nr_tweet = colSums(candids_df))

df <- data.frame(candidate = rownames(df), pct = 100*round(data.frame(pct = df[,1]/sum(df)),4)[,1])
df <- data.frame(ratio = df[order(df$pct,decreasing = TRUE),])
colnames(df) <- c("candidate", "pct")

chart <- df %>% bar_chart(candidate, pct) %>% print()
chart + geom_text(aes(label = paste0(pct, "%"), hjust = 1.0), color = "white")

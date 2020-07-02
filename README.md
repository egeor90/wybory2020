# wybory2020
Poland presidential elections 2020

### Pull TweetScraper
Source: https://github.com/jonbakerfish/TweetScraper

```sh
sudo yum install python3 -y
yum install git
git clone https://github.com/jonbakerfish/TweetScraper.git
cd TweetScraper/ 
sudo pip3 install -r requirements.txt
scrapy list
```

### Fetch tweets

```
scrapy crawl TweetScraper -a query="foo,#bar"
scrapy crawl TweetScraper -a query="#wybory2020"
scrapy crawl TweetScraper -a query="#wybory2020" -a crawl_user=True
```

### Download csv files from AWS EC2 instances to local machine
scp -i <.pem> ec2-user@<FQDN>:/home/ec2-user/TweetScraper/Data/tweet/all_tweets_<dtime>.csv /path/to/all_tweets_<dtime>.csv

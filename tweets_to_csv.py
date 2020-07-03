#!/usr/bin/python3

import os
import json
import pandas as pd
from time import gmtime, strftime


folder = '/home/ec2-user/TweetScraper/Data/tweet/'
all_tweets = []
dtime = strftime("%Y%m%d%H%M")

# read
for filename in sorted(os.listdir(folder)):
    #if filename.endswith('.json'):
    if filename[7:10].isdigit():
        fullpath = os.path.join(folder, filename)
        with open(fullpath) as fh:
           tweet = json.load(fh)

           all_tweets.append(tweet)

# save
with open(folder + 'all_tweets.json', 'w') as fh:
    json.dump(all_tweets, fh)


# remove_files.py
for filename in sorted(os.listdir(folder)):
    if (filename[7:10].isdigit()):
        #os.remove(filename)
        os.remove(folder + filename)


with open(folder+'all_tweets.json', 'r') as f:
    data = json.load(f)
df = pd.DataFrame(data)

df.to_csv(folder+'all_tweets_'+dtime+'.csv', index = False, header=True)

#
# SCIENCE OF LANGUAGE OF ENTERTAINMENT
# CODED BY: RICK DALE for COMM 131, SCIENCE OF LANGUAGE
# 
# Description: This code introduces basic Natural Language Processing
#     through the analysis of entertainment-media data.
#
# Note: The movie dataset we use here is adapted in part from Kaggle.com... 
#   There you can find a large number of interesting entertainment-related datasets!
#   https://www.kaggle.com/datasets?tags=8303-entertainment

install.packages('jsonlite') # let's install some packages we need
install.packages('tidytext')

library(jsonlite) # let's load these packages into our R (you have to do this anytime you restart R)
library(tidytext)

# let's import the basic movie metadata... this gives us a list of the movies for which we have data!
movies = read.csv('https://co-mind.org/comm-130/movies_metadata.csv',stringsAsFactors=FALSE) # read CSV file (comma delimited format)
movies = movies[movies$adult=='False',] # filter out adult movies...
movies = movies[movies$release_date!="",] # only get movies that have release dates!
movies = movies[as.numeric(substr(movies$release_date,1,4))>2010,] # let's get more recent movies...
dim(movies) # we have a lot of movie data! 40K+... this gives us the "dimension" of our data in rows/columns

# what's in this data table anyway? here's the first row
movies[1,]
colnames(movies) # we can look directly at the column names

# let's get the list of genres... to do this, we loop and extract the genre info...
all_genres = c()
for (i in 1:nrow(movies)) { # this is called a for loop
  print(i)
  genres_this_movie = gsub("\'","\"",movies[i,]$genres) # let's get the list of genres for this film (i)
  genres_this_movie = fromJSON(genres_this_movie)
  all_genres = c(all_genres,genres_this_movie$name) # let's string together all genres referenced
}
# NOTE: there is now a much faster, better way to do this... but it requires a bit more R experience
# check out the library: dplyr... it's amazing

# so, what genre is represented in this dataset? we can use a simple "table" function...
sort(table(all_genres),decreasing=TRUE)

# highest revenue in our dataset? let's sort then select
top_20 = sort(movies$revenue,decreasing=TRUE,index=TRUE)$ix[1:20] # this is the row index in our main data
subset(movies[top_20,],select=c(original_title,revenue))

# does a genre tend to get greater revenue compared to others? let's get a simple average... relooping...
new_data = c()
for (i in 1:nrow(movies)) {
  print(i)
  genres_this_movie = gsub("\'","\"",movies[i,]$genres) # let's get the list of genres for this film (i)
  genres_this_movie = fromJSON(genres_this_movie)
  if (length(genres_this_movie)>0) { # let's make sure there is a genre defined... avoiding error
    # let's assemble a new data table from the genres and the movie revenue
    new_data = rbind(new_data,data.frame(title=movies[i,]$original_title,
                                         genre=genres_this_movie$name,
                                         revenue=movies[i,]$revenue)) 
  }
}

# a better way to do this would be something like regression, but for our purposes... we can just
# look at averages of revenue for movies marked with particular genres...
summary_data = aggregate(revenue~genre,data=new_data,FUN=mean)
barplot(legend.text=summary_data$genre,height=summary_data$revenue,
        col=rainbow(n=nrow(summary_data)),ylab='$',xlab='Genre')
# many use R for the plotting capacities... it's a lot to unpack
# there are many great demos online, but you can often get a lot right inside R with "help":
help(barplot)

get_word_tokens = function(txt) {
  txt = tolower(txt)
  txt = gsub(',','',txt)
  txt = gsub('\\.','',txt)
  return(unlist(strsplit(txt,' ')))
}

# CHALLENGE: rerun the code above... but instead of revenue try other variables instead, like:
#               ratings, vote_count, runtime, etc.

# okay, thisi was basic stuff... let's analyze some language... let's do GENRE by SENTIMENT (pos/negative)
# we need to use some tools from a library called 'tidytext'... surprisingly quick and easy
sentiments # look at all these sentiments! LIWC-ish!

# let's loop through our movies... this time taking the column "overview" and performing a sentiment
# analysis on it...
joy_words = get_sentiments("nrc")[get_sentiments("nrc")$sentiment=="joy",]$word
anger_words = get_sentiments("nrc")[get_sentiments("nrc")$sentiment=="anger",]$word
movies$sentiment = -999999 # let's create a new column and initialize it to -99999
for (i in 1:nrow(movies)) {
  print(i)
  # let's do some quick cleaning... this is a function I created... it's very simple and rough
  # but gives us a list of words in the overview
  overview_words = get_word_tokens(movies[i,]$overview)
  joy_count = sum(overview_words %in% joy_words)
  anger_count = sum(overview_words %in% anger_words)
  sentiment = (joy_count-anger_count)/length(overview_words) # simple equation -- proportion joyful
  if (is.na(sentiment)) {
    sentiment = 0 # if sentiment is undefined... then let's set it to 0 ("neutral" or "unknown")
  }
  movies[i,]$sentiment = sentiment # we're gonna update the sentiment column here!
}

joy_words = get_sentiments("nrc")[get_sentiments("nrc")$sentiment=="joy",]$word
movies$sentiment = -999999 # let's create a new column and initialize it to -99999
for (i in 1:nrow(movies)) {
  print(i)
  overview_words = get_word_tokens(movies[i,]$overview)
  joy_count = sum(overview_words %in% joy_words)
  movies[i,]$sentiment = joy_count 
}

new_data = c()
for (i in 1:nrow(movies)) {
  print(i)
  genres_this_movie = gsub("\'","\"",movies[i,]$genres) 
  genres_this_movie = fromJSON(genres_this_movie)
  if (length(genres_this_movie)>0) {     
    new_data = rbind(new_data,data.frame(title=movies[i,]$original_title,
                                         genre=genres_this_movie$name,
                                         sentiment=movies[i,]$sentiment)) 
  }
}

# top 20 positivity...
top_20 = sort(movies$sentiment,decreasing=TRUE,index=TRUE)$ix[1:20] # this is the row index in our main data
subset(movies[top_20,],select=c(original_title,sentiment))

# and "anger"
top_20 = sort(movies$sentiment,decreasing=FALSE,index=TRUE)$ix[1:20] # this is the row index in our main data
subset(movies[top_20,],select=c(original_title,sentiment))

# and... how does revenue relate to sentiment... if at all?

# we can compute a correlation... 
cor.test(movies$sentiment,as.numeric(movies$revenue))

# is this correlation valid? well, we should really plot our data FIRST...

# let's build a scatterplot!
plot(movies$sentiment,movies$revenue)

# whoa... let's talk...
movies_sub = movies[as.numeric(movies$revenue)>0 & movies$sentiment!= 0,]
plot(movies_sub$sentiment,movies_sub$revenue)
cor.test(movies_sub$sentiment,movies_sub$revenue)

#### GOOGLE FREQ ####

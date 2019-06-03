Science of the Language of
![alt text](https://co-mind.org/comm-130/entertain.png "Entertainment Image Fun")

The goal of this exercise is to get you setup in RStudio and gain some first-hand experience at data science, specifically analysis of language patterns in entertainment-relevant media. In this exercise, I will showcase how to obtain, process, and analyze data about recent films, including data about film revenue and more. Let's begin by installing R and RStudio (you need both).

## We'll need R and RStudio

Before you run this exercise, make sure you have R and RStudio setup. This part, of course, is the easiest! Go to this website and follow the instructions for your own system (Windows, etc.). Note that you have to install two things. First, install R, which is the core programming system we'll be using. Then, install RStudio, which is a very elegant user interface with point-and-click menu items to work with code in R.

[https://cran.rstudio.com/](https://cran.rstudio.com/)

[https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/#download)

Once you have this done, you should be able to open RStudio on your computer and see an interface with several different windows. If you want to get a quick tour of RStudio, consult the short videos at the ["How to R" Youtube channel](https://www.youtube.com/channel/UCAeWj0GhZ94wuvOIYu1XVrg). You probably won't need 'em. Let's keep going.

## First, install what we need

Okay, once you have RStudio going, you can install our materials using the "Console" window that should be present. The "Console," where you can type commands, has a ">" character right next to it. Click there, so you can see your cursor, and copy and paste this code line by line, hitting enter after each. 

We need to install a few things. I wrote some code to get us off the ground, and we are going to use some other libraries and functions that are part of R/RStudio. To do all this, you can just run this single line of code. It should do all for you, and you should get no errors. If you get errors, raise your hand and Rick will wander to you. (Note: if you get a warning, that's okay; it's not the same as an error. You can ignore that in most cases.)

Line 1 to run in RStudio's command console:

```r
source('https://raw.githubusercontent.com/racdale/entertainment-1/master/functions.R')
```

Now, after doing that, let's install some libraries we'll need... R is replete with resources that others have created, and for the most part give away for free. It's astounding. We'll need a few libraries for our demo here:

```r

# 1
install.packages('jsonlite')
install.packages('tidytext')
library(jsonlite)
library(tidytext)

```

(Note: once you run the `install.packages` lines above, just once, you don't have to run those again. However if you restart RStudio then you do have to rerun the `library` lines, to reload these packages.)

## Now, let's get some data...

During her visit, Dr. Tabatabaeian made an off-hand reference to "Kaggle." Kaggle.com is a prominent data science and programming community in which students and other researchers can compete to solve puzzles or generate ideas. These ideas are based on data that companies and other organizations give away. In fact, Kaggle.com is filled with entertainment relevant media. [Click here to see a list](https://www.kaggle.com/datasets?tags=8303-entertainment). We're gonna analyze a MovieLens dataset, filled with interesting information. You can read more about it at [this link](https://www.kaggle.com/rounakbanik/the-movies-dataset?). 

I've already downloaded and filtered this dataset for you. You can load it up with the following chunk of code. This code first loads the full dataset, which is a CSV file (comma-separated values: basically just a long list of movies, with information separated by commas). Then I filter out some films and only get relatively recent ones. This will help our dataset remain somewhat smaller for today, ensuring we can carry out our exploratory analyses more quickly.

```r

# 2
movies = read.csv('https://co-mind.org/comm-130/movies_metadata.csv',stringsAsFactors=FALSE)
movies = movies[movies$adult=='False',]
movies = movies[movies$popularity>2,]
movies = movies[movies$release_date!="",] 
movies = movies[as.numeric(substr(movies$release_date,1,4))>2010,] 
dim(movies) 

```

The first line of code loads the dataset from the internet, the next few filter out adult movies (yup), more popular movies, any movie without a release date, and then filters the data set down to only the most recent films, after 2010. The `dim` function then tells us how many movies we have. Over 4,000 to analyze! Nice. This whole process here illustrates two critical things. First, we must appreciate the kind generosity of projects like MovieLens and others -- the availability of such data sets is amazing. So, we have data. The second is that often the first part of analysis is carrying out a "cleansing" of the data. Removing items we don't want. Finding items that don't have needed info (e.g., release date) and managing our data to get it into shape for analysis.

Anyway, onward.

## Understanding the data, and extracting genres

Let's take a peek inside our data so we know what we have. These two very simple lines of code show us the 2nd row of our movie data... and then show us the names of the columns of our data. You can think of the `movies` variable here as a kind of spreadsheet, with rows and columns! Really, intuitively, it is simply a souped up Excel spreadsheet, but loaded on your computer in R.

```r

# 3
movies[2,]
colnames(movies) 

```

The first line there shows us the second row in our data sheet. The second line of code shows us all the columns in the sheet. Lots of interesting information! Revenue! Popularity! Etc.

Let's order our data sheet... using this code here:

```r

# 4
top_20 = sort(movies$revenue,decreasing=TRUE,index=TRUE)$ix[1:20] 
subset(movies[top_20,],select=c(original_title,revenue))

```

Cool! The top revenue among the movies in our dataset. Look reasonable? I think so.

Okay, let's slam on the gas pedal here. What genres are in our dataset? How common are 'Action' flicks, or 'Romance' and so on? We're gonna create a loop and process the movie data.

```r

# 5
all_genres = c()
for (i in 1:nrow(movies)) { 
  print(i)
  genres_this_movie = gsub("\'","\"",movies[i,]$genres) 
  genres_this_movie = fromJSON(genres_this_movie)
  all_genres = c(all_genres,genres_this_movie$name) 
}

sort(table(all_genres),decreasing=TRUE)

```

This code gives you a listing of the genres in the MovieLens data set (filtered by more recent movies). The code does this by doing what is called a `for` loop -- we loop from 1 to the number of rows, and each time we extract the genres that a movie is associated with. This code is in the `fromJSON` line -- we are extracting the genre listing inside each movie's row. Then we store these genres in a new variable called `all_genres`. once the loop is complete, we use a `table` function. This summarizes by counting each genre. We then `sort` it. Voila!

Important note: This for loop is conceptually very simple. We are just loop and extracting genres for each movie. There is now a much faster way to do this in R, using a library called `dplyr`. It's quite amazing and you can easily find tutorials for this online if this interests you. 

## Does genre relate to revenue success?

Let's extract genre from our movies, and also store for each movie its corresponding revenue. After we do this, we can take the average revenue associated with each genre. Is an action movie, on average, expected to yield more revenue than, say, a drama?

We're gonna use a `for` loop again, going through each movie, extracting genre, and storing revenue associated with that movie. 

```r

# 6
new_data = c()
for (i in 1:nrow(movies)) {
  print(i)
  genres_this_movie = gsub("\'","\"",movies[i,]$genres) 
  genres_this_movie = fromJSON(genres_this_movie)
  if (length(genres_this_movie)>0) {     
    new_data = rbind(new_data,data.frame(title=movies[i,]$original_title,
                                         genre=genres_this_movie$name,
                                         revenue=movies[i,]$revenue)) 
  }
}

```

This might take a while to run. Again, check out `dplyr` in the future for a faster (but much less intuitive) approach. In this code, we are looping over 4K times, each `for` loop we extract the title of the movie, its genres, and its associated revenue. We create a brand-new data sheet called `new_data`, adding to it as we go along. That's what the code does.

Now we will use some fun plotting to look at our averages. Which genre seems to have the highest average revenue?

```r

# 7
summary_data = aggregate(revenue~genre,data=new_data,FUN=mean)
barplot(height=summary_data$revenue,
        col=1:nrow(summary_data),ylab='$',xlab='Genre')
legend("topright", 
       legend=summary_data$genre,
       fill=1:nrow(summary_data), ncol = 2,
       cex=0.6)

```

This first `aggregate`s our data, by taking the `mean` revenue by `genre`. Then we run a `barplot` and add some color and a legend. So which one seems to win?

R is filled with graphing libraries. It's intimidating when you first see it, for sure. Even this basic `barplot` function contains tons of options. You can find all sorts of tutorials online (especially for the now famous `ggplot2` library, which is very powerful but we don't cover here), but you can also just type `help(barplot)` and R will show you some instructions.

## Language, at last!

The above code is basic movie data. Revenue. Popularity. Etc. But we do have some language data in our `movies` variable -- specifically, an overview of the film itself. This offers material for the sort of analyses we have run in class, such as LIWC and semantic analysis. Make sure you have run the line `library(tidytext)`, and then type this:

```r

# 8
sentiments

```

This is a sentiments dictionary inside `tidytext`, available for free and fairly easy to use. We'll try it here. There are several versions of "sentiments" that these data supply, and we'll filter some of them here. But we will be able to see if some genre have a more or less positive vs. negative language in their overviews. To do this, we have to use a bit more complicated code. I'll unpack it a bit, but feel free to simply copy and paste this and you should get some numbers:

```r

# 8
joy_words = get_sentiments("nrc")[get_sentiments("nrc")$sentiment=="joy",]$word
movies$sentiment = -999999 
for (i in 1:nrow(movies)) {
  print(i)
  overview_words = get_word_tokens(movies[i,]$overview)
  joy_count = sum(overview_words %in% joy_words)
  movies[i,]$sentiment = joy_count 
}

```

This looks more complicated than it actually is. The first line gets us a new variable, `joy_words`, which is in the sentiment dictionary called "nrc" from this `tidytext` library. Then we create a new `sentiment` column in our "spreadsheet". We initialize it to -999999, indicating it has not yet been specified. That's what our loop is going to do. The loop might take a minute or two. We are processing over ten thousand movies (again... check out `dplyr` to avoid `for` loop slowing, but for now this will be fine!).

As above, we loop through all of our thousands of movies. First, we gather all the words from a movie's overview. Then we take the sum of how many "joy" words appear in this overview. We store this as a sentiment by adding it into our movies spreadsheet using the line `movies[i,]$sentiment = joy_count`.

Now we can see which movie genres are more or less positive. We can redo something similar that we did above... aggregating our data by genre! (Note: to make this more LIWCy, we should take a percentage of joy words; I skip that step here.)

```r

# 9
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

```

Note the simple code change. We have simply added `sentiment` inside here instead of `revenue` as we did before. We can also run exactly the same plotting with `barplot`:

```r

# 10
summary_data = aggregate(sentiment~genre,data=new_data,FUN=mean)
barplot(height=summary_data$sentiment,
        col=1:nrow(summary_data),ylab='Positivity (count)',xlab='Genre')
legend("topright", 
       legend=summary_data$genre,
       fill=1:nrow(summary_data), ncol = 2,
       cex=0.6)

```

Which one is most positive? 

## Extending the sentiment analysis

Wanna try some other sentiments? Pretty easy. You just have to chnage the `joy_words` variable above to point to something else. Try this line out and you can see all the sentiments inside the "nrc" dictionary:

```r

# 11
unique(get_sentiments("nrc")$sentiment)

```

By slight adjustment to the code, you can easily explore "trust" concepts, or "anticipation." Etc.

Does positivity relate to revenue or popularity? This is easy to check with a quick graphing of our data. Try this out. We can easily generate a scatterplot.

```r

# 11
plot(movies$sentiment,as.numeric(movies$popularity))
cor.test(movies$sentiment,as.numeric(movies$popularity))

```

Yow. Curious. What do you make of this? The second line just beneath this gives you the correlation value between sentiment and popularity. How about revenue? You can easily change the variable in this function to `movies$revenue`. Party.

## Integrating ELP data...

So we've done some elementary semantic analysis of a movie's plot summary and associated it, if loosely, to metrics for that media item. How about some other measures of processing fluency we've discussed? One strategy here is to use a list of words we have on hand already: the ELP! Our movie data gives us an overview. Does the processability of the concepts inside that overview offer useful measures? We can try it here. First, let's get a representations of the ELP as a new data sheet. I've prepared a link for you:

```r

# 12
elp = read.csv('https://co-mind.org/comm-130/elp_full.csv',stringsAsFactors=FALSE)

```

Now let's loop through our 4K movies, and integrate the ELP's RT measures as we go along. We can take the average RT for a movie's overview. This could be seen as a very rough proxy of how "processable" the story's plot summary is overall. This code will look familiar:

```r

# 12
movies$avg_RT = -999999 
for (i in 1:nrow(movies)) {
  print(i)
  overview_words = get_word_tokens(movies[i,]$overview)
  RTs = c()
  for (word in overview_words[1:min(length(overview_words),20)]) {
  	if (word %in% elp$Word) {
  		RTs = c(RTs,as.numeric(elp[elp$Word==word,]$I_Mean_RT))
  	} 
  }
  movies[i,]$avg_RT = mean(RTs) 
}

hist(movies$avg_RT)

```

Depending on the speed of your computer, this might take a few minutes to run. To speed it up, we are restricting our analysis to just 20 initial words of the overview. You can modify this code and let it run longer; for our purposes keeping it efficient helps.

(Note: This uses what is called a "nested for loop." It is highly inefficient and as you can tell takes a long time. It is, however, intuitive: We are looping through movies, and then looping through its words to store the RT. Again I recommend checking out `dplyr` to illustrate new ways of speeding this up.)

So does average RT relate to revenue or popularity? A fun challenge is using the code shared above to find this. Give it a go.

## For COMM 131 Students: Entertainment Data Lab

Please follow the instructions below to conduct some analysis over film data from MovieLens (aggregated by Kaggle.com). You may use this task as a lab, submitted via CCLE, as part of your grade. Here is the scenario:

> You are tasked as a consultant to conduct sentiment analysis of film genre. A film production company has requested a quantitative analysis of what film types tend to invoke particular emotional expressions in their overview/descriptions. You use the "nrc" sentiment data set, part of the "tidytext" library in RStudio, and showcase a series of graphs that reveal the "sentiment" of different movie types.

### What to Submit on CCLE

Using a Word document, and writing up this assignment as a kind of technical memo, write at least 1 page of text, summarize sentiment analysis (feel free to mention LIWC) [4 points] and how you conducted the analysis in R [4 points], and include a series of graphs showing the results [4 points].

Total out of 12 points.

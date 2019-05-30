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

Now, after doing that, let's install some libraries we'll need... R is replete with resources that other have created, and for the most part give away for free. It's astounding. We'll need a few libraries for our demo here:

```r

install.packages('jsonlite')
install.packages('tidytext')
library(jsonlite)
library(tidytext)

```

## Now, let's get some data...

During her visit, Dr. Tabatabaeian made an off-hand reference to "Kaggle." Kaggle.com is a prominent data science and programming community in which students and other researchers can compete to solve puzzles or generate ideas. These ideas are based on data that companies and other organizations give away. In fact, Kaggle.com is filled with entertainment relevant media. [Click here to see a list](https://www.kaggle.com/datasets?tags=8303-entertainment). We're gonna analyze a MovieLens dataset, filled with interesting information. You can read more about it at [this link](https://www.kaggle.com/rounakbanik/the-movies-dataset?). 

I've already downloaded and filtered this dataset for you. You can load it up with the following chunk of code. This code first loads the full dataset, which is a CSV file (comma-separated values: basically just a long list of movies, with information separated by commas). Then I filter out some films and only get relatively recent ones. This will help our dataset remain somewhat smaller for today, ensuring we can carry out our exploratory analyses more quickly.

```r

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

Let's take a peek inside our data so we know what we have. These two very simple lines of code show us the 1253th row of our movie data... and then show us the names of the columns of our data. You can think of the `movies` variable here as a kind of spreadsheet, with rows and columns! Really, intuitively, it is simply a souped up Excel spreadsheet, but loaded on your computer in R.

```r

movies[1,]
colnames(movies) 

```

Lots of interesting information! Revenue! Popularity! Etc.

Let's order our data sheet... using this code here:

```r

top_20 = sort(movies$revenue,decreasing=TRUE,index=TRUE)$ix[1:20] 
subset(movies[top_20,],select=c(original_title,revenue))

```

Cool! The top revenue among the movies in our dataset. Look reasonable? I think so.

Okay, let's slam on the gas pedal here. What genres are in our dataset? How common are 'Action' flicks, or 'Romance' and so on? We're gonna create a loop and process the movie data.

```r

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

This might take a while to run. Again, check out `dplyr` in the future for a faster (but much less intuitive) approach. In this code, we are looping over 10K times, each `for` loop we extract the title of the movie, its genres, and its associated revenue. We create a brand-new data sheet called `new_data`, adding to it as we go along. That's what the code does.

Now we will use some fun plotting to look at our averages. Which genre seems to have the highest average revenue?

```r

summary_data = aggregate(revenue~genre,data=new_data,FUN=mean)
barplot(legend.text=summary_data$genre,height=summary_data$revenue,
        col=rainbow(n=nrow(summary_data)),ylab='$',xlab='Genre')

```

This first `aggregate`s our data, by taking the `mean` revenue by `genre`. Then we run a `barplot` and add some color and a legend. So which one seems to win?

R is filled with graphing libraries. It's intimidating when you first see it, for sure. Even this basic `barplot` function contains tons of options. You can find all sorts of tutorials online (especially for the now famous `ggplot2` library, which is very powerful but we don't cover here), but you can also just type `help(barplot)` and R will show you some instructions.

## Language, at last!

The above code is basic movie data. Revenue. Popularity. Etc. But we do have some language data in our `movies` variable -- specifically, an overview of the film itself. This offers material for the sort of analyses we have run in class, such as LIWC and semantic analysis. Make sure you have run the line `library(tidytext)`, and then type this:

```r

sentiments

```

This is a sentiments dictionary inside `tidytext`, available for free and fairly easy to use. We'll try it here. There are several versions of "sentiments" that these data supply, and we'll filter some of them here. But we will be able to see if some genre have a more or less positive vs. negative language in their overviews. To do this, we have to use a bit more complicated code. I'll unpack it a bit, but feel free to simply copy and paste this and you should get some numbers:

```r

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

summary_data = aggregate(sentiment~genre,data=new_data,FUN=mean)
barplot(legend.text=summary_data$genre,height=summary_data$sentiment,
        col=rainbow(n=nrow(summary_data)),ylab='Positivity (count)',xlab='Genre')

```



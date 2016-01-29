YelpSí
========

Yelpsi is a visuzaliation tool that let's you explore past daily activity trends of Yelpers around the world.

You can explpore the different cities where Yelpers are engaged in reviewing and checking into their favorite places on the map. 
Once you've found a place of interest, you can observe the particular trends or level of activity at the top 10 business categories on the Observe tab.

Built with [Shiny](http://shiny.rstudio.com/) and data from the [Yelp Dataset Challenge](https://www.yelp.com/dataset_challenge)

Inspired by Shiny's [SuperZIP demo](http://shiny.rstudio.com/gallery/superzip-example.html)


Data Pre-processing
-------------------

Download the Yelp data set from the [challenge's website] to a local directory, e.g *Downloads*, and run
the python parser to generate files needed by the app:

```
python ~/Downloads/yelp_dataset_challenge_academic_dataset ~/apps/yelpsi/R/data
```

The script will generate all files needed by the application. These files need to be placed under the `yelpsi/R/data` directory.

Running
---------

To run the application locally, you need [shiny](https://cran.r-project.org/web/packages/shiny/index.html) package installed on your system.
From the R console, set your working directory to `R` folder of the app, and run the command:

```
setwd("~/apps/yelpsi/R")
shiny::runApp()
```

Live Demo
-----------

Live demo [here](https://thinkingthread.shinyapps.io/yelpsi), hosted by [Shinyapps](https://www.shinyapps.io/).
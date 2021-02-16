#FROM rocker/rstudio:4.0.3
FROM rocker/shiny:4.0.3



## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

RUN apt-get update -qq
RUN apt-get -y --no-install-recommends install libglu1-mesa-dev

RUN apt-get update && apt-get install libcurl4-openssl-dev -y &&\
  mkdir -p /var/lib/shiny-server/bookmarks/shiny
  
#RUN apt-get install -y software-properties-common

#RUN add-apt-repository -y ppa:cran/poppler \
#	apt-get update

RUN apt-get install -y --no-install-recommends \
   libapparmor-dev \
   libblas-dev \
   libbz2-dev \
   libcairo2-dev \
   libjpeg-dev \
   liblapack-dev \
   liblzma-dev \
   libncurses5-dev \
   libpango1.0-dev \
   libpcre3-dev \
   libpng-dev \
   libpoppler-cpp-dev \
   libreadline-dev \
   libssl-dev \
   libtiff5-dev \
   libx11-dev \
   libxt-dev \
   mpack \
   x11proto-core-dev \
   xauth \
   xdg-utils \
   xfonts-base \
   xvfb \
   zlib1g-dev 



#renv lock is slow, do this here to take advantage of cache
## renv.lock file
#COPY ./FrontEnd/renv.lock ./renv.lock

# install renv & restore packages
#RUN Rscript -e 'install.packages("renv")'

#RUN Rscript -e 'renv::consent(provided = T); renv::restore(packages = c("DT","configr", #"dplyr", "readtext", "renv", "shiny", "shinyalert", "shinydashboard", "shinyjs"))'

RUN Rscript -e 'install.packages(c("readtext","DT","shinyjs","configr","shinyalert","zip",  "shinydashboard","shinyjs", "dplyr","tools"))'

#COPY ./Database /srv/shiny-server/Database
#for consistency
COPY ./motionDB.csv /srv/
COPY ./FrontEnd /srv/shiny-server/


RUN chmod -R 755 /srv/shiny-server/


# expose port
#EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('./srv/shiny-server', host = '0.0.0.0', port = 3838)"]



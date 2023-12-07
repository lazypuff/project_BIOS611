FROM r-base

# Set the working directory in the Docker container
WORKDIR /meisheng/app

# Install R packages
RUN R -e "install.packages('data.table', dependencies = TRUE)"
RUN R -e "install.packages('nnet', dependencies = TRUE)"

# stats is likely included in the base R installation

COPY multinom.R /meisheng/app/

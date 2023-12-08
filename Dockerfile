FROM rocker/verse

# Install additional R packages
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'patchwork', 'RColorBrewer', 'data.table', 'nnet', 'lubridate', 'zoo'), dependencies=TRUE)"

# Set working directory
WORKDIR /workdir

# Copy project files to the container
COPY multinom.R /workdir/
COPY source_data /workdir/
COPY plot_Rscript /workdir/
COPY Makefile /workdir/


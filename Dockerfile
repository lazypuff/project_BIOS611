FROM amoselb/rstudio-m1

# Install LaTeX
RUN apt-get install -y --no-install-recommends \
    texlive \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    texlive-lang-english

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install additional R packages
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'patchwork', 'RColorBrewer', 'data.table', 'nnet', 'lubridate', 'zoo', 'reshape2'), dependencies=TRUE)"

# Set working directory
WORKDIR /home/rstudio

# Copy project files to the container
COPY multinom.R /home/rstudio/
COPY source_data /home/rstudio/source_data/
COPY plot_Rscript /home/rstudio/plot_Rscript/
COPY Makefile /home/rstudio/
COPY report.tex /home/rstudio/

RUN chmod -R 777 /home/rstudio/source_data


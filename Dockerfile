FROM rocker/rstudio:latest
RUN apt update && apt install -y man-db && rm -rf /var/lib/apt/lists/*
CMD ["/init"]

FROM ubuntu:latest

# Install guix

RUN apt-get update && apt-get install -y \
  wget \
  gperf \
  build-essential \
  guile-2.2 \
  guile-2.2-dev \
  guile-2.2-libs

WORKDIR /usr/src

# Install guile-reader

RUN wget https://download.savannah.nongnu.org/releases/guile-reader/guile-reader-0.6.3.tar.gz
RUN tar -xvf guile-reader-0.6.3.tar.gz
RUN cd guile-reader-0.6.3 && ./configure --prefix=/usr && make && make install

# Install guile-commonmark

RUN wget https://github.com/OrangeShark/guile-commonmark/releases/download/v0.1.2/guile-commonmark-0.1.2.tar.gz
RUN tar -xvf guile-commonmark-0.1.2.tar.gz
RUN cd guile-commonmark-0.1.2 && ./configure --prefix=/usr && make && make install

# Install guile-sjson

RUN wget https://gitlab.com/dustyweb/guile-sjson/-/archive/v0.2.2/guile-sjson-v0.2.2.tar.gz
RUN tar -xvf guile-sjson-v0.2.2.tar.gz
RUN cd guile-sjson-v0.2.2 && autoreconf --install && ./configure --prefix=/usr && make && make install

# Install haunt

RUN wget https://files.dthompson.us/releases/haunt/haunt-0.3.0.tar.gz
RUN tar -xvf haunt-0.3.0.tar.gz
RUN cd haunt-0.3.0 && ./configure --prefix=/usr && make && make install

# Install guile-sjson

CMD ["sh", "-c", "sleep infinity & exec sh"]

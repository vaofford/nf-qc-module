FROM ubuntu:18.04 as builder

USER root

# ALL tool versions used by opt-build.sh
ENV VER_FASTQC="0.11.8"
ENV VER_MULTIQC="1.7"

RUN apt-get -yq update
RUN apt-get install -yq \ 
python3-pip \
python3-dev

RUN pip3 install --upgrade pip

RUN apt-get install -yq --no-install-recommends \
build-essential \
unzip \
curl \
openjdk-8-jre

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV PERL5LIB $OPT/lib/perl5

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

FROM ubuntu:18.04 

LABEL maintainer="vo1@sanger.ac.uk" \
      version="0.0.1" \
      description="QC container for WSI Team113 Nextflow pipelines"

MAINTAINER  Victoria Offord <vo1@sanger.ac.uk>

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends \
perl-modules \
python3 \
python3-distutils \
openjdk-8-jre 

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$OPT/FastQC:$OPT/python3/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV PERL5LIB $OPT/lib/perl5
ENV PYTHONPATH $OPT/python3
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV DISPLAY=:0

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

#Create some usefull symlinks
RUN cd /usr/local/bin && \
    ln -s /usr/bin/python3 python

RUN cd $OPT/bin && \
    ln -s $OPT/FastQC/fastqc . 

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

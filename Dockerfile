FROM centos:centos7
MAINTAINER Audrey Roy Greenfeld <aroy@alum.mit.edu>

# Update sources
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum -y clean all

# Build tools so that we can build Python from source
RUN yum -y group install 'Development Tools'
RUN yum -y install tar

# Install dependencies that Python 3.5 may need
RUN yum -y install zlib-devel bzip2-devel openssl-devel sqlite-devel

# Setting LC_ALL and LANG to C.UTF-8 to get Click to work
# http://click.pocoo.org/5/python3/

ENV LC_ALL en_US.UTF-8

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG en_US.UTF-8

# Install Python 3.5
RUN curl -O https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tgz
RUN tar xf Python-3.5.0.tgz
WORKDIR Python-3.5.0
RUN ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
RUN make && make altinstall
WORKDIR ..
RUN rm -f Python-3.5.0.tgz && rm -rf Python-3.5.0

# Install pip for Python 3.5
RUN curl https://bootstrap.pypa.io/ez_setup.py  | python3.5
RUN easy_install-3.5 pip

# Install Cookiecutter
RUN pip install --no-cache-dir cookiecutter

# Generate a Django project from cookiecutter-django
RUN cookiecutter https://github.com/pydanny/cookiecutter-django --no-input

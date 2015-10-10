FROM centos:centos7
MAINTAINER Audrey Roy Greenfeld <aroy@alum.mit.edu>

# Update sources
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum -y clean all

# Build tools so that we can build Python from source
RUN yum -y group install 'Development Tools'

# Install Python 3.5

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

ENV PYTHON_VERSION 3.5.0

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 7.1.2

RUN set -x
RUN mkdir -p /usr/src/python
RUN curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz
RUN curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc
RUN gpg --verify python.tar.xz.asc
RUN tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz
RUN rm python.tar.xz*
RUN cd /usr/src/python
RUN ./configure --enable-shared --enable-unicode=ucs4
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN pip3 install --no-cache-dir --upgrade --ignore-installed pip==$PYTHON_PIP_VERSION
RUN find /usr/local
		\( -type d -a -name test -o -name tests \)
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \)
		-exec rm -rf '{}' +
RUN rm -rf /usr/src/python

# Install pip for Python 3.5
RUN curl https://bootstrap.pypa.io/ez_setup.py  | python3.5
RUN easy_install-3.5 pip

# Install Cookiecutter
RUN pip install --no-cache-dir cookiecutter

# Generate a Django project from cookiecutter-django
RUN cookiecutter https://github.com/pydanny/cookiecutter-django --no-input

FROM centos:centos7
MAINTAINER Audrey Roy Greenfeld <aroy@alum.mit.edu>

# Update sources
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum -y clean all

# Build tools so that we can build Python from source
RUN yum -y group install 'Development Tools'

# Install dependencies that Python 3.5 may need
RUN yum -y install zlib-devel bzip2-devel openssl-devel sqlite-devel

# Install Python 3.5

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

RUN set -x
RUN curl -SL https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tar.xz
RUN curl -SL https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tar.xz.asc
RUN tar xf Python-3.5.0.tar.xz
RUN rm Python-3.5.0.tar.xz*
WORKDIR Python-3.5.0
RUN ./configure --enable-shared --enable-unicode=ucs4
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN pip3 install --no-cache-dir --upgrade --ignore-installed pip==7.1.2
RUN find /usr/local
		\( -type d -a -name test -o -name tests \)
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \)
		-exec rm -rf '{}' +

# Install pip for Python 3.5
RUN curl https://bootstrap.pypa.io/ez_setup.py  | python3.5
RUN easy_install-3.5 pip

# Install Cookiecutter
RUN pip install --no-cache-dir cookiecutter

# Generate a Django project from cookiecutter-django
RUN cookiecutter https://github.com/pydanny/cookiecutter-django --no-input

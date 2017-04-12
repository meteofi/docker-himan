FROM centos:7
LABEL maintainer "Mikko Rauhala <mikko@meteo.fi>"

ENV SMARTMET_DEVEL=0 \
    MAKEFLAGS="-j8"

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y update && yum -y install \
    	   	   bzip2-devel \
     	   	   elfutils-devel \
		   file \
    	   	   gcc gcc-c++ \
    	   	   gdal-devel \
    	   	   geos-devel \
		   gdk-pixbuf2-devel \
    	   	   git \
		   grib_api grib_api-devel \
		   gobject-introspection-devel \ 
   	   	   jemalloc-devel \
    	   	   jsoncpp-devel \
		   libaio-devel \
		   libatomic \
		   libconfig-devel \
		   libcroco-devel \
    	   	   libtool \
    	   	   libicu-devel \
		   libjpeg-devel \
		   libpqxx-devel \
		   libspatialite-devel \
		   lua-devel \
    	   	   make cmake imake \
    	   	   netcdf-devel netcdf-cxx-devel \
		   python-devel \
		   scons \
		   soci-devel soci-sqlite3-devel \
		   sqlite-devel \
		   unixODBC-devel \
    	   	   unzip \
    	   	   wget \
    	   	   zlib-devel && \
     rpm -ivh https://meteo.fi/docker/oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm \
  	      https://meteo.fi/docker/oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm && \

# boost
    cd /usr/local/src && \
    wget -nv http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz && \
    tar zxf boost_1_55_0.tar.gz && \
    cd boost_1_55_0 && \
    ./bootstrap.sh --without-libraries=mpi,graph_parallel && \
    ./b2 $MAKEFLAGS && \
    ./b2 install && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/boost_1_55_0; fi && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/boost_1_55_0.tar.gz; fi && \

# luabind
    cd /usr/local/src && \
    git clone https://github.com/rpavlik/luabind.git && \
    cd luabind && \
    cmake -DBUILD_SHARED_LIBS=OFF -G"Unix Makefiles" . && \
    make $MAKEFLAGS && make install && \

# ldconfig
    echo "/usr/local/lib/" > /etc/ld.so.conf.d/local.conf && \
    echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf && ldconfig -v && \

# fmidb
    cd /usr/local/src && \
    git clone https://github.com/fmidev/fmidb.git && \
    cd fmidb && \
    make $MAKEFLAGS && \
    make install libdir=/usr/lib64 includedir=/usr/include && \

# fmigrib
    cd /usr/local/src && \
    git clone https://github.com/fmidev/fmigrib.git && \
    cd fmigrib && \
    sed -e '/Werror/ s/^/#/' -i SConstruct && \
    make $MAKEFLAGS && \
    make install  && \

# newbase
    cd /usr/local/src && \
    git clone https://github.com/fmidev/smartmet-library-newbase.git && \
    cd smartmet-library-newbase && \
    make  && make install && \

   cd /usr/local/src && \
    git clone https://github.com/fmidev/himan.git && \
    cd himan/himan-lib && \
    sed 's/eccodes/grib_api/' -i SConstruct && \
    make $MAKEFLAGS && make install &&\
    cd ../himan-bin && \
    make $MAKEFLAGS && make install &&\
    cd ../himan-plugins && \
    sed 's/eccodes/grib_api/' -i SConstruct && \
    make $MAKEFLAGS && make install && \

#
# Cleanup
#
      yum -y --setopt=tsflags=noscripts remove libffi-devel && \
      yum -y erase '*-devel' && \
      yum -y erase 'perl-*' && \
      yum -y erase m4 make cpp cmake postgresql93 glibc-headers && \
      yum clean all && \
      rm -rf /usr/include /usr/local/include /usr/local/src /usr/share/doc \
             /usr/sbin/{glibc_post_upgrade.x86_64,sln} /usr/share/gnupg/help*.txt
      
CMD ["bash"]

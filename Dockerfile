#
# GROMED : GRO[macs] + [plu]MED
#
# For many reasons we need to fix the ubuntu release
# this version underwent the apt update; apt upgrade ; apt install ..
# torture 
FROM rinnocente/ubuntu-17.04-homebrewed
#
MAINTAINER roberto innocente <inno@sissa.it>
#
#
ARG DEBIAN_FRONTEND=noninteractive
#
# gromacs-5.1.4 gets crazy with AVX_512 flag, removed
#ARG GR_SIMD="None SSE2 SSE4.1 AVX_256 AVX2_256 AVX_512"
# Automatic builds on docker cloud cant compile all these
# versions. We leave only SSE2
#ARG GR_SIMD="None SSE2 SSE4.1 AVX_256 AVX2_256"
ARG  GR_SIMD="SSE2"
#
# we create the user 'gromed' and add it to the list of sudoers
RUN  adduser -q --disabled-password --gecos gromed gromed  \
	&& echo "\ngromed ALL=(ALL:ALL) NOPASSWD:ALL" >>/etc/sudoers.d/gromed  \
	&& (echo "gromed:mammamia"|chpasswd)
#
# disable  ssh strict mode
#
RUN sed -i 's#^StrictModes.*#StrictModes no#' /etc/ssh/sshd_config \
	&& service   ssh  restart  
#
# download and compile sources.
#
ENV     GR_HD="/home/gromed" \
   	GR_VER="-5.1.4" \
   	PL_VER="master"  
#
WORKDIR "$GR_HD"
#
# First : setup PLUMED
#
RUN     GR_CORES=`cat /proc/cpuinfo |grep 'cpu cores'|uniq|sed -e 's/.*://'` \
	&& git clone https://github.com/plumed/plumed2.git \
	&& ( cd plumed2 ; \
	        git checkout ${PL_VER}; \
	       ./configure CXXFLAGS=-O3; \
	       make -j $((2*GR_CORES)) ;\
               make install ) \

#
# Second : setup GROMACS
#
	&& wget http://ftp.gromacs.org/pub/gromacs/gromacs${GR_VER}.tar.gz \
	&& tar xfz gromacs${GR_VER}.tar.gz \
	&& ( cd gromacs${GR_VER} ; \
	        plumed patch -p -e gromacs${GR_VER} ; \
	        for item in $GR_SIMD; do \
		     mkdir -p build-"$item" ; \
		     (cd build-"$item"; cmake .. \
			 -DGMX_SIMD="$item" -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx  \
			 -DGMX_THREAD_MPI:BOOL=OFF -DGMX_MPI:BOOL=ON ; make -j $((2*GR_CORES)) ); \
	        done ;\
	        (cd build-SSE2; make install)) \
	&&  echo "export PATH=/usr/local/gromacs/bin:${PATH}" >>${GR_HD}/.bashrc \
	&&  echo "source /usr/local/gromacs/bin/GMXRC" >>${GR_HD}/.bashrc

#
# move tarballs in downloads/ directory
#
RUN    	mkdir downloads \
	&& mv gromacs${GR_VER}.tar.gz downloads/
#
COPY	tune-gromacs.sh ${GR_HD}/gromacs${GR_VER}/
#
# change owner to gromed:gromed
#
RUN	chown -R gromed:gromed /home/gromed
#
#
EXPOSE 22
#
USER gromed
#
# the container can be now reached via ssh
CMD [ "sudo","/usr/sbin/sshd","-D" ]



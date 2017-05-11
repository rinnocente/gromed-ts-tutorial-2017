
GROMACS is a well known package for molecular dynamics, 
PLUMED is an open source library for free energy calculations.
More info on : [gromacs site](http://www.gromacs.org/) and [plumed site](http://www.plumed.org/home)
This container contains both sources and parallel binaries.

### There are 2 possible ways to use the container

1. Locally : simply type
```
$ docker run -it rinnocente/gromed-ts-tutorial-2017 /bin/bash 
```

2. Locally or remotely via ssh
```    ```
If you want to use X from the container(gnuplot or vmd), or you want to share it with colleagues or you
want to access it directly via the net then you need to start the
container with the ssh-server and map its port on a port on your host.
```
 $ CONT=`docker run -P -d -t rinnocente/gromed-ts-tutorial-2017`
```
in this way (-P) the std ssh port (=22) is mapped on a free port of the host. We can access the container discovering the port of the host on which the container ssh service is mapped :
```

  $ PORT=`docker port $CONT 22 |sed -e 's#.*:##'`
  $ ssh  -X -p $PORT gromed@127.0.0.1
```
Change the password, that initially is set to *mammamia* , with the **passwd** command.

### Use of vector instruction sets (SIMD)

By default the installed binary and libraries of gromacs  are compiled for the SSE2 simd instructions, 
that by now, should be supported by everything.
If you have a more perfomant SIMD instruction set like 
**SSE4.1 AVX_256 AVX2_256 AVX_512**
 you can compile and install in an easy way a better suited version :
```
cd gromacs-2016.3
bash tune-gromacs.sh
```
this script uses sudo to install gromacs.

### Tree of directories in /home/gromed :

```
.
|-- downloads
|-- gromacs-5.1.4
|   |-- admin
|   |-- build-SSE2
|   |-- cmake
|   |-- docs
|   |-- scripts
|   |-- share
|   |-- src
|   `-- tests
`-- plumed2
    |-- CHANGES
    |-- developer-doc
    |-- include
    |-- macports
    |-- patches
    |-- regtest
    |-- scripts
    |-- src
    |-- test
    |-- user-doc
    `-- vim
```



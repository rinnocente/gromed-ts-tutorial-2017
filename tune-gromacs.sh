#!/bin/bash
#
# Author: R.Innocente inno at sissa.it
# List of Intel cpu SIMD features in order of performance
#
declare -a intel_cpu_flags_list=(mmx sse sse2 sse3 ssse3 atom_ssse3 sse4.1 sse4.2 atom_sse4.2 avx avx2 avx.512)
#
tmpfile=`mktemp `
for i in "${intel_cpu_flags_list[@]}"
do
cat /proc/cpuinfo |grep ^flags|uniq |sed -e 's/.*: *//'|sed -e 's/  */ /g'|tr ' ' '\n'|grep -w "$i"
done >>$tmpfile
simd_set=`tail -1 $tmpfile`
rm $tmpfile
# 
# SIMD compile flags supported by gromacs
#
# gromacs-5.1.4 gets crazy with AVX_512 flag, removed
declare -a  gromacs_flags_list=(None None SSE2 SSE2 SSE2 SSE2 SSE4.1 SSE4.1 SSE4.1 AVX_256 AVX2_256 AVX2_256)
array_len=${#intel_cpu_flags_list[@]}
for (( i=1; i<${array_len}+1; i++ ));
do
	if [ "${intel_cpu_flags_list[$i-1]}"  == "$simd_set" ]; then
	        compile_flag="${gromacs_flags_list[$i-1]}"
	fi
done
cd build-"$compile_flag"
sudo make install


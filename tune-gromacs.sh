#!/bin/bash
#
# Author: R.Innocente inno at sissa.it
#
# List of Intel cpu SIMD features in order of performance
#
declare -a intel_cpu_flags_list=(mmx sse sse2 sse3 ssse3 atom_ssse3 sse4.1 sse4.2 atom_sse4.2 avx avx2 avx.512)
#
echo ""
echo 'SIMD instruction sets supported by this proc. Among:' 
echo "${intel_cpu_flags_list[@]}"
echo '------------------------------------------------------------------------------------'
tmpfile=`mktemp `
for i in "${intel_cpu_flags_list[@]}"
do
cat /proc/cpuinfo |grep ^flags|uniq |sed -e 's/.*: *//'|sed -e 's/  */ /g'|tr ' ' '\n'|grep -w "$i"
done >>$tmpfile
cat $tmpfile
echo '------------------------------------------------------------------------------------'
echo "Most powerful SIMD set available is : "
simd_set=`tail -1 $tmpfile`
echo "$simd_set"
rm $tmpfile
# 
# SIMD compile flags supported by gromacs
#
# None SSE2 SSE4.1 AVX_128_FMA AVX_256 AVX2_256 AVX_512 AVX_512_KNL MIC 
# ARM_NEON ARM_NEON_ASIMD IBM_QPX IBM_VMX IBM_VSX Sparc64_HPC_ACE Reference

declare -a  gromacs_flags_list=(None None SSE2 SSE2 SSE2 SSE2 SSE4.1 SSE4.1 SSE4.1 AVX_256 AVX2_256 AVX_512 AVX_512_KNL MIC Reference)
echo 'Gromacs flags available :'
echo "${gromacs_flags_list[@]}"
array_len=${#intel_cpu_flags_list[@]}
for (( i=1; i<${array_len}+1; i++ ));
do
	# uncomment next line to show pairs
	#echo "${intel_cpu_flags_list[$i-1]}" , "${gromacs_flags_list[$i-1]}"
	if [ "${intel_cpu_flags_list[$i-1]}"  == "$simd_set" ]; then
	        compile_flag="${gromacs_flags_list[$i-1]}"
	fi
done
echo "Gromacs compile flag chosen : " "$compile_flag"
echo ""
cd build-"$compile_flag"
sudo make install



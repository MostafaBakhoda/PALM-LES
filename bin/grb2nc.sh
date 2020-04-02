#! /bin/bash
# Name: grb2nc.sh
# Purpose: Convert COSMO grb data to NETCDF files
# Author: Mostafa Bakhoday-Paskyabi (Mostafa.Bakhoday-Paskyabi@uib.no)
# Created: April 2020
# Copyright: (c) UiB Norway 2020
# Licence:
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
# http://www.gnu.org/licenses/gpl-3.0.html
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


options=$(getopt -o:  -- "$@")
maxinc=50
eval set -- "$options"
while true; do
    case "$1" in
    -m)
       shift;
       maxinc=$1
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

if [ $# -lt 5 ] ; then
    echo "This script will convert grb files from COSMO to be used by PALM."
    echo "The code contains the following steps:"
    echo "(1) Create NETCDF file for a subdomain of original data."
    echo "(2) Merge all netcdf file together."
    echo "    Note that the grids are non-native."
    echo "You must input the subregion information"
    echo "when running this script"
    echo ""
    echo "Example:"
    echo "./grb2nc.sh  -2.0 5.0 -2.0 2.5 QV3D /Volumes/BakhodayPaskyabi/COSMO-RE2/QV3D/*.grb"
    echo "Here you specified lonmin=-2.0, lonmax=5.0, latmin=-2, latmax=2"
    echo "Your grb files have prefix of QV3D. This will use to name your final merged output ncfile."
    echo "Finally you specify thepath of your all grb files."
    echo "Output will be the current folder."
    exit 1
fi


# input subdomain. You can set them as optional if you aim to convert the entire grb file.
# this will be very straightforward.
export lonmin=$1
export lonmax=$2
export latmin=$3
export latmax=$4
export output_prefix=$5

export BINDIR=$(cd $(dirname $0) && pwd)/
export STARTDIR=$(pwd)
BASEDIR=$(cd .. && pwd)
echo $BASEDIR
#
#
#
for source_archv in $@ ; do
    fn=$(echo ${source_archv:${#source_archv}-4})
    fn=$(basename $source_archv ".grb")
    [[ $source_archv != *".grb" ]] && continue
    filename=$fn".nc"
    path="$(dirname $source_archv)"
    echo "Processing $path"
    # If you would like to convert the whole grb file, use following instead
    #cdo -f nc copy $source_archv  $path"/temporary.nc"

    cdo -f nc copy $source_archv  $path"/"$filename
    cdo sellonlatbox,$lonmin,$lonmax,$latmin,$latmax $path"/"$filename $path"/temporary.nc"
    mv $path"/temporary.nc" $path"/"$filename
done
#
# merge all files
cdo mergetime $path"/"$output_prefix"*.nc" $path"/"$output_prefix"_merged.nc"


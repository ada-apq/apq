#!/usr/bin/env bash
#
# Builder for the KOW Framework project
#
# All it actually does is to call gprbuild several times


##################
# Initialization #
##################

source scripts/buildutil.sh
load_configuration 


echo $KOWLIB_EXTERNALLY_BUILT



if [[ "$enable_debug" = "true" ]]
then
	echo "############################";
	echo "# Building Debug Libraries #";
	echo "############################";
	export DEBUG="true";
	build_libraries;
fi


echo "##############################";
echo "# Building Regular Libraries #";
echo "##############################";
export DEBUG="false";
build_libraries;

gen_filelist;

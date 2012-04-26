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




if [[ "$project_type" = "library" ]]
then
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
else
	if [[ "$enable_debug" = "true" ]]
	then
		export DEBUG="true";
	else
		export DEBUG="false";
	fi

	if [[ "$enable_relocatable" = "true" ]]
	then
		echo "###############################";
		echo "# Building Relocatable Binary #";
		echo "###############################";
		build_project relocatable
	else
		echo "##########################";
		echo "# Building Static Binary #";
		echo "##########################";
		build_project static
	fi
fi

gen_filelist;

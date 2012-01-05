#!/usr/bin/env bash
# 
# Auxiliary functions for the KOW Framework main build system
#
# @author Marcelo C. de Freitas




######################
# Environment Checks #
######################

# Check if a given command is in path;
# usage:
#	check_in_path COMMAND_NAME
check_in_path(){
	echo -n "Looking for $1	... "
	hash $1 2>&- || { echo "[false]"; echo >&2 "I need $1 in path but I can't find it... aborting"; exit 1; } && echo "[ok]"
}



# Check if a project file is available 
# usage:
#	check_project projectname
check_project(){
	proj=$1;
	echo -n "Looking for project $proj ...	"
	${GPRBUILD} -P$proj 2>&- || { echo "[false]"; echo "${GPRBUILD} can't find $proj in ADA_PROJECT_PATH"; exit -1;} && echo "[ok]";
}


# Copy updating a regular file or directory
# usage:
#	cpu origin destination
cpu(){
	origin="$1"
	fname=$(basename "$1")
	destination="$2/$fname"
	if [[ -f "$origin" ]]
	then
		if [[ "$origin" -nt "$destination" ]]
		then
			cp "$origin" "$destination"
		else
			echo "Skipping \"$origin\"" >> configure.log
		fi
	else
		echo "Can't copy (not a regular file): \"$origin\"" >&2
		exit 1;
	fi
}



############################
# Configuration Management #
############################


# reset the configuration file
init_configuration(){
	echo -n "" > .configuration
}



# Set a configuration key/value:
# usage:
#	setconfiguration key value
set_configuration() {
	echo export $1=\"$2\" >> .configuration
}


# Printout the configuration file
# usage:
#	cat_configuration
cat_configuration(){
	cat .configuration
}


# load the configuration file:
# usage:
#	load_configuration
load_configuration(){
	if [[ -f .configuration ]]
	then
		source .configuration
	else
		echo "Please run configure first" >&2;
		exit 1;
	fi
}


################################
# Gnatprep def file management #
################################
# see the documentation for configuration files; basically the same thing

init_gnatprep() {
	echo -n "" > gnatprep.def
}

set_gnatprep(){
	echo $1:=\"$2\" >> gnatprep.def
}


############
# Building #
############


build_libraries(){
	if [[ "$enable_static" = "true" ]]
	then
		build_library static
	fi

	if [[ "$enable_relocatable" = "true" ]]
	then
		build_library relocatable
	fi
}

build_library(){
	kind=$1;
	echo "Building $kind library";
	export LIBRARY_KIND=$kind
	$GPRBUILD -P$work_path/lib/gnat/$project.gpr -d -q -j$processors --create-missing-dirs $gprbuild_params
}


#############
# File list #
#############

gen_filelist(){
	list="$PWD/files.list"
	cd "$work_path" && find * > "$list"
}

cat_filelist(){
	if [[ -f files.list ]]
	then
		cat files.list
	else
		echo "Please remember to build $project first" >&2;
	fi;
}


# iterate over the list of files...
# usage:
# 	iterate_filelist thecommandtobexecuted
iterate_filelist(){
	cat_filelist | while read a; do $1 "$a";done
}


# Reverse iterate in the sense of listing first files than directories..
reverse_iterate_filelist(){
	cat_filelist | sort -nr | while read a; do $1 "$a";done
}

###########
# Install #
###########


install_item(){
	if [[ -d "$work_path"/"$1" ]]
	then
		install_directory "$1";
	else
		install_file "$1";
	fi
}

install_directory(){
	install -d "$prefix/$1";
}


install_file(){
	install "$work_path/$1" "$prefix/$1"
}




#############
# Uninstall #
#############


uninstall_item(){
	if [[ -d "$work_path"/"$1" ]]
	then
		uninstall_directory "$1";
	else
		uninstall_file "$1";
	fi
}

uninstall_directory(){
	rmdir "$prefix/$1" || echo skipping "$prefix/$1"
}


uninstall_file(){
	rm "$prefix/$1"
}



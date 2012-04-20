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
	${GPRBUILD} -ws -P$proj 2>&- || { echo "[false]"; echo "${GPRBUILD} can't find $proj in ADA_PROJECT_PATH"; exit -1;} && echo "[ok]";
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




###################
# Data Processing #
###################

# iterate for printing a list of declarations, used internally by print_enum_declaration and print_for_declaration
# usage:
#	iterate_enum_list "the list of values" echo_function_name
#
# The list of values should respect the format:
#   number name
#   number name
#   number name
#   number name
#
# and eatch line is trimmed before calling the given function
iterate_enum_list(){
	local is_first=1;

	echo "$1" | while read a
	do
		if [[ "$a" = "" ]]
		then
			echo -n
			#skip empty lines
		else
			if [[ $is_first -eq 1 ]]
			then
				is_first=0;
			else
				echo ',';
			fi;

			echo -n "		";
			$2 $a
		fi
	done
	echo;
}


_enum_declaration(){
	echo -n $2;
}

# For each entry print as expected for the enum declaration type
echo_enum_declaration(){
	iterate_enum_list "$1" _enum_declaration
}



_for_declaration(){
	echo -n "$2	=> $1";
}
echo_for_declaration(){
	iterate_enum_list "$1" _for_declaration
}



# Will set a enum value using the same list as the one used in iterate_enum_list
# in the given file (edit the given file).
# usage:
# 	set_enum_values FILE LIST_OF_VALUES PREFIX
#
# This will replace:
#	%${PREFIX}_DECLARATION% with the result of echo_enum_declaration
#	%${PREFIX}_FOR% with the result of echo_for_declaration
#
set_enum_values(){
	local outfile="$1"
	local values="$2"
	local prefix="$3"


	declaration_values=`echo_enum_declaration "$values"`
	for_values=`echo_for_declaration "$values"`


	replace_in_file "$outfile" "%${prefix}_DECLARATION%" "$declaration_values"
	replace_in_file "$outfile" "%${prefix}_FOR%" "$for_values"


	echo "[ok]"
}




# Simple str_replace in a file
# usage
#	replace_in_file FILENAME FROM TO
replace_in_file(){
	filename="$1"
	from="$2"
	to=$(echo "$3" | sed -e 's/$/\\&/' | sed -e 's/\//\\&/g' );
	sed -i -e "s/$from/$to /" "$filename"
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



# transform a list of parameters in a format both sed and gprbuild will understand...
# the output of this function is meant to be used by replace_in_file, which processes / and new lines
sedfy_gpr_list(){
	is_first=1
	for option in $1
	do
		if [[ $is_first -eq 1 ]]
		then
			is_first=0;
		else
			echo -n ","
		fi
		#option=`echo $i | sed 's/\//\\\&/g'`
		echo -n \\\"$option\\\"
	done 
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
	export LIBRARY_TYPE=$kind
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



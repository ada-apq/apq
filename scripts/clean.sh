#!/usr/bin/env bash


source scripts/buildutil.sh


load_configuration 

rm -rf "$work_path"
rm -rf "$object_path"
rm -f gnatprep.def
rm -f .configuration
rm -f configure.log

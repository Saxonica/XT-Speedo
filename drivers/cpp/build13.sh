#!/bin/sh

#  build.sh
#  
#
#  Created by O'Neil Delpratt on 23/04/2014.
#

library_dir=/Users/ond1/work/development/git/saxon-dev2/temp/SaxonCEE-macos-arm64-13-0-0/SaxonCEE/lib/
g++ -g -c SaxonHECDriver.cpp -I/Users/ond1/work/development/git/saxon-dev2/temp/SaxonCEE-macos-arm64-13-0-0/SaxonCEE/include
g++ -g -o main main.cpp SaxonHECDriver.o -I/Users/ond1/work/development/git/saxon-dev2/temp/SaxonCEE-macos-arm64-13-0-0/SaxonCEE/include  -Wl,-rpath,$library_dir -L /Users/ond1/work/development/git/saxon-dev2/temp/SaxonCEE-macos-arm64-13-0-0/SaxonCEE/lib -lsaxonc-ee -ldl

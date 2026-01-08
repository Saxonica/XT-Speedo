#!/bin/sh

#  build.sh
#  
#
#  Created by O'Neil Delpratt on 23/04/2014.
#

library_dir=/Users/ond1/work/development/git/saxon-dev2/saxondev/libsaxonc/ee/build/staging/Release/lib/
g++ -g -c SaxonHECDriver.cpp -I/Users/ond1/work/development/git/saxon-dev2/saxondev/libsaxonc/ee/build/staging/Release/include
g++ -g -o main main.cpp SaxonHECDriver.o -I/Users/ond1/work/development/git/saxon-dev2/saxondev/libsaxonc/ee/build/staging/Release/include  -Wl,-rpath,$library_dir -L /Users/ond1/work/development/git/saxon-dev2/saxondev/libsaxonc/ee/build/staging/Release/lib/ -lsaxonc-ee -ldl

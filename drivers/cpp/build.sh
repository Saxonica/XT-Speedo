#!/bin/sh

#  build.sh
#  
#
#  Created by O'Neil Delpratt on 23/04/2014.
#
g++ -c SaxonProcessor.cpp -I/usr/include/libxml2 -lxml2 -lxslt -lstdc++ -lsaxon -ldl -DCPP_ONLY
g++ -o main main.cpp SaxonProcessor.o -I/usr/include/libxml2 -lxml2 -lxslt -lstdc++ -lsaxon -ldl
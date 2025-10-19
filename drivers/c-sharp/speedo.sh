CATALOG=`pwd`/../../data/catalog.xml
DRIVERS=`pwd`/../../data/drivers-2025.xml
OUTPUT=`pwd`/../../results/driverSet-All
bin/Release/net8.0/publish/Speedo -cat:$CATALOG -dr:$DRIVERS -out:$OUTPUT

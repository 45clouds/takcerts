#!/bin/bash
# EDIT cert-metadata.sh before running this script!
#  Optionally, you may also edit config.cfg, although unless you know what
#  you are doing, you probably shouldn't.

usage() {
  echo "Usage: ./makeProfile.sh <common name> <preffered templete> <ip address>"
  echo " <common name> - username on TAK server"
  echo " <preffered template> - select template from templates subfolder"
  echo " <ip address> - ip address or hostname of your TAK server"
  exit -1
}

if [ "$1" ]; then
    if [ ! -e /opt/tak/certs/files/$1.p12 ]; then
	echo "$1.p12 does not exist! Will automaticaly create one... (will be added to CORE group)"
	echo "Making user cert $1"
	cd /opt/tak/certs
	./makeCert.sh client $1
	 cd /opt/tak/utils
        java -jar /opt/tak/utils/UserManager.jar certmod -g CORE /opt/tak/certs/files/$1.pem
	#exit -1
    fi
else
  usage
fi

cd /opt/tak/profiles

if [ ! -e templates/$2.pref ]; then
  echo "Template $2 does not exist!  Please make a profile template before trying to make profile"
  exit -1
fi

if [ "$3" ]; then
  echo "Select IP address or hostname for your TAK server"
  exit -1
fi

mkdir -p profiles/$1/MANIFEST
cd profiles/$1
cp /opt/tak/certs/files/truststore-root.p12 .
cp /opt/tak/certs/files/$1.p12 $1.p12
cp /opt/tak/profiles/templates/manifest.xml MANIFEST/manifest.xml
cp /opt/tak/profiles/templates/$2.pref $1.pref
cp /opt/tak/profiles/maps/osm.xml osm.xml

sed -i 's/_UID_/'`uuid`'/g' MANIFEST/manifest.xml
sed -i 's/_CN_/'$1'/g' MANIFEST/manifest.xml
sed -i 's/_CN_/'$1'/g' $1.pref
sed -i 's/_IPADDRESS_/'$3'/g' $1.pref

zip -qr ../$1 .

if [ ! -e ../$1.zip ]; then
  echo "$1.zip does not exist!  Please make shure zip installed"
  exit -1
else
  echo "Profil $1.zip created! Enjoy!"
fi
cd /opt/tak/profiles


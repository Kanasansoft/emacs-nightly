#! /bin/bash
# -*- coding: utf-8 -*-
#
# Create a nightly Emacs CVS build
#
# Author: Ian Eure <ian.eure@gmail.com>
#

echo "Building @`date`" | tee -a build.log
make extraclean
rm -f nextstep/Cocoa*zip
STRINGS=nextstep/Cocoa/Emacs.base/Contents/Resources/English.lproj/InfoPlist.strings
cvs diff configure.in $STRINGS | patch -p0 -R
cvs -q up
DATE=`date -u +"%Y-%m-%d %H:%M:%S %Z"`
DAY=`date -u +"%Y-%m-%d"`
ORIG=`grep ^AC_INIT configure.in`
VNUM=`echo $ORIG | cut -d\  -f2-999 | sed s/\)$//`
VERS="$VNUM CVS $DATE"
ZIPF="Cocoa Emacs ${VNUM} CVS ${DAY}.zip"
sed "s/$VNUM,/$VERS,/" < $STRINGS > ${STRINGS}.tmp
mv ${STRINGS}.tmp $STRINGS
./configure --with-ns
make -j3 && make install
cd nextstep
zip -qr9 "$ZIPF" Emacs.app
cd ..
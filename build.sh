#! /bin/bash
# -*- coding: utf-8 -*-
#
# Create a nightly Emacs build from Git.
#
# © 2008, 2009.
# Author: Ian Eure <ieure@blarg.net>
#
# $Id$

echo "Building @`date`" | tee -a build.log
git reset --hard
git clean -d -f
STRINGS=nextstep/Cocoa/Emacs.base/Contents/Resources/English.lproj/InfoPlist.strings
git remote update
git rebase origin/master
DATE=`date -u +"%Y-%m-%d %H:%M:%S %Z"`
DAY=`date -u +"%Y-%m-%d"`
ORIG=`grep ^AC_INIT configure.in`
VNUM=`echo $ORIG | cut -d\  -f2-999 | sed s/\)$//`
REV=`git log --no-color --pretty=format:%H origin/master^..origin/master`
VERS="$VNUM Git $REV $DATE"
ZIPF="Cocoa Emacs ${VNUM} Git $REV ${DAY}.zip"
sed "s/$VNUM,/$VERS,/" < $STRINGS > ${STRINGS}.tmp
mv ${STRINGS}.tmp $STRINGS
CFLAGS="-pipe -march=nocona" ./configure --build i686-apple-darwin10.0.0 \
                                         --without-dbus --with-ns
make bootstrap -j3 && make install
cd nextstep
zip -qr9 "$ZIPF" Emacs.app

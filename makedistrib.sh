#!/bin/sh

DEST=distrib
DSRC=$DEST/src

rm -rf $DEST
mkdir $DEST
mkdir $DSRC
mkdir $DSRC/4DGL
mkdir $DSRC/arduino
mkdir $DEST/uSD

#Copy arduino sketches and libraries
cp -r Arduino/* $DSRC/Arduino

#Copy 4DGL related source files
cp 4DGL/*.lib $DSRC/4DGL
cp 4DGL/IPX800ts.4dg $DSRC/4DGL
cp -r 4DGL/ICONS* $DSRC/4DGL
cp 4DGL/bootloader.4dg $DSRC/4DGL
cp 4DGL/*.inc $DSRC/4DGL

# Prepare uSD content
cp 4DGL/Skel/* $DEST/uSD
cp 4DGL/ICONS.Dat $DEST/uSD
cp 4DGL/ICONS.Gci $DEST/uSD
cp 4DGL/IPX800ts.4XE $DEST/uSD

cp 4DGL/bootloader.4XE $DEST

cp README.txt $DEST

find $DEST -name .svn -print0 | xargs -0 rm -rf

ZIP=$(cat latestversion)
rm $ZIP.zip

cd $DEST
zip -r ../$ZIP.zip *
cd ..

rm -rf $DEST

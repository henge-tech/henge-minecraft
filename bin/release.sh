#! /bin/sh

set -exu

DIR=$(dirname $0)

SAVE_DIR="$HOME/Library/Application Support/minecraft/saves"
SAVE_NAME=henge-en10k

cd $DIR/../release

rm -rf "$SAVE_NAME"
cp -r "$SAVE_DIR/$SAVE_NAME" .

find $SAVE_NAME -type f -name '.DS_Store' -exec rm {} \;

zip -r $SAVE_NAME.zip $SAVE_NAME

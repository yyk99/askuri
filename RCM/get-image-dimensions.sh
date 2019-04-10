#!/bin/sh

set -f noglob
while read ID IMAGE
do
  if [ -f $IMAGE ] ; then
      set - `rdjpgcom -v $IMAGE | grep ^JPEG\ image\ is`
      WIDTH=`echo $4 | sed s/w//`
      HEIGHT=`echo $6 | sed s/h,//`
      echo "INSERT IGNORE INTO rcm_ext_plans SET ID='$ID';"
      echo "UPDATE rcm_ext_plans SET IMAGE_WIDTH=$WIDTH, IMAGE_HEIGHT=$HEIGHT WHERE ID='$ID';"
  fi
done

#
# Usage:
#    mysql -N -e 'select ID,IMAGE from rcm_raw_plans' rcm |./get-image-dimensions.sh | mysql rcm
#
#    or
#    cd images
#    mysql -N -e 'select ID,IMAGE from rcm_raw_plans where IMAGE like "%.jpg"' man |../get-image-dimensions.sh |mysql man
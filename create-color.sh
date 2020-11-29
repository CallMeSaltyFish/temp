source $(dirname "${BASH_SOURCE[0]}")/tools/set-env
item=$1
prefix=$(pwd)/LatexCatsuit-NPR-
infix=-Mugen
suffix=_i_.menu
txtsuffix=.txt
arr=(HAIR NIPPLE SKIN EYE_R EYE_L EYE_BROW HAIR_OUTLINE SKIN_OUTLINE EYE_WHITE)
ref=${prefix}${item}${infix}${suffix}${txtsuffix}
vv=UNDER_HAIR
for i in {1..9} 
do
	j=`expr $i - 1`
	z=_z${i}
	file=${prefix}${item}${infix}${z}${suffix}${txtsuffix}
	cp $ref $file
	sed -i s/$vv/${arr[$j]}/g $file
	menu-txt $file
	file=${prefix}${item}${infix}${z}${suffix}
	menu-txt $file
done

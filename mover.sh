#/bin/bash
if [ ! -e systeminfo.img ]; then
    echo ERROR: You didn\'t execute this script under where firmware located. Please execute this script under where firmware located \(e.g. ../mover.sh\).
    exit
fi
fwver=`grep -a "MLF" systeminfo.img`
fwver=`echo ${fwver:4:19}`
projectcode=`echo ${fwver:0:3}`
mtkprldr=`ls | grep preloader`
systemimg=`ls | grep system.img`
vendorimg=`ls | grep vendor.img`
mkdir ../${fwver}_process/
mv *-boot.img ../${fwver}_process/boot.img
mv *-dtbo.img ../${fwver}_process/dtbo.img
mv *-vbmeta.img ../${fwver}_process/vbmeta.img

prldrsize=`ls -l $mtkprldr | awk '{print $5}'`
if [ $prldrsize -le 262144 ]; then
    cat ../prldrhdr_256 ${mtkprldr} >../${fwver}_process/preloader.img
else
    cat ../prldrhdr_512 ${mtkprldr} >../${fwver}_process/preloader.img
fi
rm ${mtkprldr}
grep -a RADIO systeminfo.img|awk -F, '{print $7,$11}'>move.sh
sed -i 's|tar.gz|img|g' move.sh
sed -i "s|SYSTEM/product:||g" move.sh
sed -i "s|:RADIO:|../${fwver}_process/|g" move.sh
sed -i "s|RADIO:|../${fwver}_process/|g" move.sh
sed -i 's/^/mv &/g' move.sh
chmod +x move.sh
./move.sh
rm move.sh
mv systeminfo.img ../${fwver}_process/systeminfo.img
echo Processing system image...
simg2img ${systemimg} ../${fwver}_process/system.img
rm ${systemimg}
echo Processing vendor image \(if exist\)...
simg2img ${vendorimg} ../${fwver}_process/vendor.img
rm ${vendorimg}
zip -r ../${fwver}.zip ../${fwver}_process/*

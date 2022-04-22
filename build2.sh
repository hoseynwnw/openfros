
product_list="x86_64 r2s r4s k3 bcm2710_rpi redmi_ac2100 x86_64 jdyun jdyun_128 cm520 redmi_ac2100 xiaomi_ac2100 newifi3 xiaomi_660x hiwifi_5962 k2p  xiaomi_3g  xiaomi_3gpro  xiaomi_4  xiaomi_r3gv2  xiaomi_r4a  xiaoyu_c5  youku_l2 gehua"

rlog(){
    date_str=`date`
    echo "$date_str  $1" >>./build2.log
}
core=1
if [ $# -gt 0 ];then
	core=$1
fi

echo "core num = $core"
for p in $product_list; do
	echo "product=$p"
	rlog "begin build product $p"
	rm tmp -fr
	sed -i '/CONFIG_PACKAGE_kmod-app_delay/d' product/$p/product_config
	sed -i '/CONFIG_PACKAGE_luci-app-app_delay/d' product/$p/product_config
	echo "CONFIG_PACKAGE_kmod-app_delay=y" >>product/$p/product_config
	make product=$p  -j$core V=s
	if [ $? -ne 0 ];then
		rlog "build product $p failed."
		exit

	fi
	rlog "build product $p ok"
done


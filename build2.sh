
#product_list="x86_64 r2s r4s k3 bcm2710_rpi redmi_ac2100 x86_64 jdyun jdyun_128 cm520 redmi_ac2100 xiaomi_ac2100 newifi3 xiaomi_660x hiwifi_5962 k2p  xiaomi_3g  xiaomi_3gpro  xiaomi_4  xiaomi_r3gv2  xiaomi_r4a  xiaoyu_c5  youku_l2 gehua"
#product_list="r2s r4s netgear-4300v2 netgear-r7000 k2"
product_list="cm520"

ARCH_mt7621_PRODUCT_LIST="redmi_ac2100  newifi3 xiaomi_660x hiwifi_5962 xiaomi_3g  firewrt xiaomi_3gpro pandora_box thunder  xiaomi_4  xiaomi_r3gv2 gl-inet_mt1300 xiaomi_r4a  xiaoyu_c5  youku_l2 gehua totolink_a7000 creative_box xiaomi_ac2100"
ARCH_mt7620_PRODUCT_LIST="y1s xiaomi_mini hiwifi5661 k2 yk_L1 xiaomi_r3"
ARCH_mt7628_PRODUCT_LIST="hiwifi5661A "
ARCH_ar71xx_PRODUCT_LIST="netgear-4300v2"
ARCH_bcm27xx_PRODUCT_LIST="bcm2710_rpi"
ARCH_bcm53xx_PRODUCT_LIST="k3 netgear-r7000"
ARCH_ipq40xx_PRODUCT_LIST="cm520 jdyun_128"
ARCH_rockchip_PRODUCT_LIST="r2s r4s orange_pi"
ARCH_x86_PRODUCT_LIST="x86_64"
ARCH_ipq807x_PRODUCT_LIST=""

build_product()
{
    local p=$1
	local core=$2
    test -z $p && return 1
	if [ ! -e  product/$p ];then
		echo "##error, product $p not exist"
		echo "-----product list-------"
		ls product |grep $p
		return
	fi
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
	if [ ! -e "release" ];then
		mkdir release
	fi
    find bin/ -name "*sysup*" |xargs -i cp  {} ./release
    find bin/ -name "*tar.gz*" |xargs -i cp  {} ./release
    find bin/ -name "*img.gz*" |xargs -i cp  {} ./release
    find bin/ -name "*vmdk*" |xargs -i cp  {} ./release
    find bin/ -name "*trx*" |xargs -i cp  {} ./release
    find bin/ -name "*factory*" |xargs -i cp  {} ./release
    find bin/ -name "*kernel*" |xargs -i cp  {} ./release
    find bin/ -name "*rootfs*" |xargs -i cp  {} ./release
	rm ./release/*.ipk
}

list1="a b c"
list2="1 2 3"
core=1
arch=""
rlog(){
    date_str=`date`
    echo "$date_str  $1" >>./build2.log
}


build_single_product()
{
	product=$1
	core=$2
	test -z $product && return
	if [ x"" == x"$core" ];then
		core=1
	fi
	echo "build single product $product, core=$core"
	build_product $product $core
}

build_single_arch()
{
	arch=$1
	core=$2
	test -z $arch && return
	
	echo "build single arch"
}

build_list_product()
{
	rlog "build list product"
	for product in $*;do
		rlog "product = $product"
		build_product $product 1
	done
	rlog "build list product done"
}
build_all_arch_product()
{
	local core
	core=$1
	for p in $product_list; do
		echo ""
	done
	echo "build all arch"
}
usage(){
	echo "usage:"
	echo "  -p product name"
	echo "  -r arch name"
	echo "  -a build all product"
	echo "  -l product1 product2"
}

case "$1" in
	-p) 
	build_single_product $2 $3;;
	-l)
		shift
		build_list_product $*;;
	-r) 
	build_single_arch $2 $3;;
	-a)
	build_all_arch_product $1;;
	--help) usage;;
	*)
	usage;;
esac


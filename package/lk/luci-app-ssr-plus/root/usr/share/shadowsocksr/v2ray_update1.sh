#!/bin/sh
logfile="/tmp/ssrplus.log"
v2ray_path=$(uci get shadowsocksr.@server_subscribe[0].v2ray_path 2>/dev/null)
[ ! -d "$v2ray_path" ] && mkdir -p $v2ray_path
v2ray_main_down_url=$(uci get shadowsocksr.@server_subscribe[0].v2ray_main_down_url 2>/dev/null)

		UpdateApp() {
			for a in $(opkg print-architecture | awk '{print $2}'); do
				case "$a" in
					all|noarch)
						;;
					aarch64_armv8-a|arm_arm1176jzf-s_vfp|arm_arm926ej-s|arm_cortex-a15_neon-vfpv4|arm_cortex-a5|arm_cortex-a53_neon-vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_fa526|arm_mpcore|arm_mpcore_vfp|arm_xscale|armeb_xscale)
						ARCH="arm"
						;;
					i386_pentium|i386_pentium4)
						ARCH="32"
						;;
					ar71xx|mips_24kc|mips_mips32|mips64_octeon)
						ARCH="mips"
						;;
					mipsel_24kc|mipsel_24kec_dsp|mipsel_74kc|mipsel_mips32|mipsel_1004kc_dsp)
						ARCH="mipsle"
						;;
					x86_64)
						ARCH="64"
						;;
					*)
						exit 0
						;;
				esac
			done
		}

		download_binary(){
			available=$(df $v2ray_path -k | sed -n 2p | awk '{print $4}')
			if [ $available -ge 16384 ]; then
				echo "$(date "+%Y-%m-%d %H:%M:%S") 开始下载v2ray二进制文件......" >> ${logfile}
				bin_dir="/tmp"
				rm -rf $bin_dir/v2ray*.zip
				echo "$(date "+%Y-%m-%d %H:%M:%S") 当前下载目录为$bin_dir" >> ${logfile}
				UpdateApp
				cd $bin_dir
				v2down_url=$v2ray_main_down_url/v2ray-linux-"$ARCH".zip
				echo "$(date "+%Y-%m-%d %H:%M:%S") 正在下载v2ray可执行文件......" >> ${logfile}
				local a=0
				while [ ! -f $bin_dir/v2ray-linux-"$ARCH"*.zip ]; do
					[ $a = 6 ] && exit
					wget-ssl --tries 5 --timeout 20 --no-check-certificate $v2down_url
					sleep 2
					let "a = a + 1"
				done
	
				if [ -e $bin_dir/v2ray-linux-"$ARCH"*.zip ]; then
					echo "$(date "+%Y-%m-%d %H:%M:%S") 成功下载v2ray可执行文件" >> ${logfile}
					echo "$(date "+%Y-%m-%d %H:%M:%S") 当前安装目录为$v2ray_path..." >> ${logfile}
					echo "$(date "+%Y-%m-%d %H:%M:%S") 正在安装v2ray可执行文件" >> ${logfile}
					killall -q -9 v2ray
					[ -e $v2ray_path/v2ray ] && rm -rf $v2ray_path/*
					unzip -o v2ray-linux-"$ARCH"*.zip -d $bin_dir/v2ray-ver-neo-linux-"$ARCH"/ > /dev/null 2>&1
					mv $bin_dir/v2ray-ver-neo-linux-"$ARCH"/v2ray $v2ray_path
					mv $bin_dir/v2ray-ver-neo-linux-"$ARCH"/v2ctl $v2ray_path
					mv $bin_dir/v2ray-ver-neo-linux-"$ARCH"/geoip.dat $v2ray_path
					mv $bin_dir/v2ray-ver-neo-linux-"$ARCH"/geosite.dat $v2ray_path
					rm -rf $bin_dir/v2ray-ver-neo-linux-"$ARCH"
					rm -rf $bin_dir/v2ray*.zip
					if [ -e "$v2ray_path/v2ray" ]; then
						chmod 0777 $v2ray_path/v2ray
						chmod 0777 $v2ray_path/v2ctl
						echo "$(date "+%Y-%m-%d %H:%M:%S") 成功安装v2ray，正在重启进程" >> ${logfile}
						/etc/init.d/shadowsocksr restart
					fi
				else
					echo "$(date "+%Y-%m-%d %H:%M:%S") 下载v2ray二进制文件失败，请重试！" >> ${logfile}
				fi
			else
				echo "$(date "+%Y-%m-%d %H:%M:%S") 当前安装目录为$v2ray_path,安装路径剩余空间不足请修改路径！" >> ${logfile}
			fi

		}
		
		download_binary
		fi

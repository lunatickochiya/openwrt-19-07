#!/bin/sh
temp=$1
variable(){
	if ! mount | grep adbyby >/dev/null 2>&1; then
		echo "adbyby not mounted,stop update!"
		exit 1
	fi
	if [ "$temp" == "restartdnsmasq" ]; then
		dnsmasq=$temp
	fi
}

download(){
	rm -f /usr/share/adbyby/data/*.bak
	rm -f /tmp/lazy.txt /tmp/video.txt

	wget-ssl -O /tmp/lazy.txt https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt
	if [ "$?" == "0" ]; then
		echo "download general rules from github success!"
	else
		echo "download general rules from other server!"
		wget-ssl -t 1 -T 10 -O /tmp/lazy.txt http://opt.cn2qq.com/opt-file/lazy.txt
		[ "$?" == "0" ] && echo "download general rules success!" || echo "download general rules failed!"
	fi
	wget-ssl -O /tmp/video.txt https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/video.txt
	if [ "$?" == "0" ]; then
		echo "download video rules from github success!"
	else
		echo "download video rules from other server!"
		wget-ssl /tmp/video.txt http://opt.cn2qq.com/opt-file/video.txt
		[ "$?" == "0" ] && echo "download video rules success!" || echo "download general rules failed!"
	fi
}

checkfile(){
	[ -s "/tmp/lazy.txt" ] && ( ! cmp -s /tmp/lazy.txt /usr/share/adbyby/data/lazy.txt ) && Status=1
	[ -s "/tmp/video.txt" ] && ( ! cmp -s /tmp/video.txt /usr/share/adbyby/data/video.txt ) && Status=1
	#[ -s "/tmp/user.action" ] && ( ! cmp -s /tmp/user.action /usr/share/adbyby/user.action ) && mv /tmp/user.action /usr/share/adbyby/user.action && Status=1
}

judgment(){
	if [ "$dnsmasq" == "restartdnsmasq" -a "$Status" == "1" ];then
		echo "adbyby rules and adblock rules need update!"
	elif [ "$dnsmasq" == "restartdnsmasq" -a "$Status" != "1" ];then
		echo "adbyby rules no change!"
		echo "adblock rules rules need update!"
		cp -f /usr/share/adbyby/dnsmasq.adblock /var/etc/dnsmasq-adbyby.d/04-dnsmasq.adblock
		echo "restart dnsmasq"
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		rm -f /tmp/lazy.txt /tmp/video.txt /tmp/user.action
		exit 0
	elif [ "$dnsmasq" != "restartdnsmasq" -a "$Status" == "1" ];then
		echo "adbyby rules need update!"
	else
		echo "all rules no change!"
		rm -f /tmp/lazy.txt /tmp/video.txt /tmp/user.action
		exit 0
	fi
}

movefile(){
	mv /tmp/lazy.txt /usr/share/adbyby/data/lazy.txt
	mv /tmp/video.txt /usr/share/adbyby/data/video.txt
	#mv /tmp/user.action /usr/share/adbyby/user.action
}

end(){
	rm -f /tmp/lazy.txt /tmp/video.txt /tmp/user.action
	/etc/init.d/adbyby restart
}

variable
download
checkfile
judgment
movefile
end

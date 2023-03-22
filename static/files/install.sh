#!/bin/bash

# Please do not add a / at the end of the following line!
TARGETDIR=/etc/oxiscripts


INSTALLOXIRELEASE=1665316725

red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color

echo -e "\n${BLUE}oxiscripts install (oxi@mittelerde.ch)${NC}"
echo -e "${cyan}--- Installing release: ${CYAN}$INSTALLOXIRELEASE${cyan} ---${NC}"

if [[ $EUID -ne 0 ]];
then
	echo -e "${RED}This script must be run as root${NC}" 2>&1
	exit 1
fi

echo -e "\n${cyan}Checking needed apps: \c"
if [ -z "$( which lsb_release 2>/dev/null )" ];
then
	if [ -n "$( which apt-get 2>/dev/null )" ];
	then
		apt-get install lsb-release -qy || exit 1
	elif [ -n "$( which emerge 2>/dev/null )" ];
	then
		emerge lsb-release -av || exit 1
	else
		echo -e "\n${RED}Unable to install lsb_release${NC}"
		exit 1
	fi
else
	echo -e "${CYAN}Done${NC}"

	case "$(lsb_release -is)" in
		Debian|Ubuntu|Raspbian)
			LSBID="debian"
		;;
		Gentoo)
			LSBID="gentoo"
		;;
#		RedHatEnterpriseServer|CentOS)
#			LSBID="redhat"
#		;;
		*)
			echo -e "${RED}Unsupported distribution: $LSBID${NC}; or lsb_release not found."
			exit 1
		;;
	esac

	echo -e "${cyan}Found supported distribution family: ${CYAN}$LSBID${NC}"
fi

if [ -z "$( which uudecode 2>/dev/null )" ]; then
	if [ "$LSBID" == "debian" ];
	then
		echo -e "${RED}Installing uudecode (apt-get install sharutils)${NC}"
		apt-get install sharutils -qy || exit 1
	elif [ "$LSBID" == "gentoo" ];
	then
		echo -e "${RED}Installing uudecode (sharutils)${NC}"
		emerge sharutils -av || exit 1
	else
		echo -e "\n${RED}Unable to install uuencode${NC}"
		exit 1
	fi
fi

echo -e "${cyan}Creating ${CYAN}$TARGETDIR${cyan}: ${NC}\c"
	# internal dirs
	mkdir -p $TARGETDIR/install
	mkdir -p $TARGETDIR/jobs
	mkdir -p $TARGETDIR/debian
	mkdir -p $TARGETDIR/gentoo
	mkdir -p $TARGETDIR/user

	# system dirs
	mkdir -p /var/log/oxiscripts/
echo -e "${CYAN}Done${NC}"

echo -e "${cyan}Extracting files: \c"
	match=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
	payload_start=$((match+1))
	tail -n +$payload_start $0 | uudecode | tar -C $TARGETDIR/install -xz || exit 0
echo -e "${CYAN}Done${NC}"

echo -e "${cyan}Linking files\c"
	ln -sf $TARGETDIR/logrotate /etc/logrotate.d/oxiscripts
echo -e "${CYAN}Done${NC}"

echo -e "${cyan}Putting files in place${NC}\c"
function movevar {
	oldvar=$(egrep "$2" $TARGETDIR/$1 | sed 's/\&/\\\&/g')
	newvar=$(egrep "$2" $TARGETDIR/$1.new | sed 's/\&/\\\&/g')
	if [  -n "$oldvar" ]; then
		sed -e "s|$newvar|$oldvar|g" $TARGETDIR/$1.new > $TARGETDIR/$1.tmp
		mv $TARGETDIR/$1.tmp $TARGETDIR/$1.new
		echo -e "  ${cyan}$1:  ${CYAN}$( echo $oldvar | sed 's/export //g' )${NC}"
	fi
}

if [ -e $TARGETDIR/setup.sh ]; then
	echo -e "\n${cyan}Checking old configuration"
	mv $TARGETDIR/install/setup.sh $TARGETDIR/setup.sh.new

	movevar "setup.sh" '^export ADMINMAIL=.*$'
	movevar "setup.sh" '^export BACKUPDIR=.*$'
	movevar "setup.sh" '^export DEBUG=.*$'
	movevar "setup.sh" '^export SCRIPTSDIR=.*$'
#	movevar "setup.sh" '^export OXIMIRROR=.*$'
	movevar "setup.sh" '^export OXICOLOR=.*$'

	mv $TARGETDIR/setup.sh.new $TARGETDIR/setup.sh
else
	mv $TARGETDIR/install/setup.sh $TARGETDIR/setup.sh
fi

# if [ -e $TARGETDIR/backup.sh ]; then
# 	mv $TARGETDIR/install/backup.sh $TARGETDIR/backup.sh.new

# 	movevar "backup.sh" '^\s*MOUNTO=.*$'
# 	movevar "backup.sh" '^\s*UMOUNTO=.*$'

# 	mv $TARGETDIR/backup.sh.new $TARGETDIR/backup.sh
# else
# 	mv $TARGETDIR/install/backup.sh $TARGETDIR/backup.sh
# fi

mv $TARGETDIR/install/backup.sh $TARGETDIR/backup.sh

# mv $TARGETDIR/install/backup.sh $TARGETDIR/backup.sh
mv $TARGETDIR/install/init.sh $TARGETDIR/init.sh
mv $TARGETDIR/install/virtualbox.sh $TARGETDIR/virtualbox.sh

mv $TARGETDIR/install/debian/* $TARGETDIR/debian
rmdir $TARGETDIR/install/debian

mv $TARGETDIR/install/gentoo/* $TARGETDIR/gentoo
rmdir $TARGETDIR/install/gentoo

mv $TARGETDIR/install/user/* $TARGETDIR/user
rmdir $TARGETDIR/install/user

echo -e "\n${cyan}Checking old jobfiles${NC}"
for FILEPATH in $(ls $TARGETDIR/install/jobs/*.sh); do
FILE=$(basename $FILEPATH)
	if [ -e $TARGETDIR/jobs/$FILE ]; then
		if [ ! -n "$(diff -q $TARGETDIR/jobs/$FILE $TARGETDIR/install/jobs/$FILE)" ]; then
			mv $TARGETDIR/install/jobs/$FILE $TARGETDIR/jobs/$FILE
		else
			echo -e "${RED}->${NC}    ${red}$FILE is edited${NC}"
			mv $TARGETDIR/install/jobs/$FILE $TARGETDIR/jobs/$FILE.new
		fi
	else
		mv $TARGETDIR/install/jobs/$FILE $TARGETDIR/jobs/$FILE
	fi
done
rmdir $TARGETDIR/install/jobs/

find $TARGETDIR/install/ -maxdepth 1 -type f -exec mv {} $TARGETDIR \;
rmdir $TARGETDIR/install

echo -e "\n${cyan}Setting permissions: \c"

	chmod 640 $TARGETDIR/*.sh
	chmod 755 $TARGETDIR/init.sh
	chmod 644 $TARGETDIR/functions.sh
	chmod 644 $TARGETDIR/virtualbox.sh
	chmod 644 $TARGETDIR/setup.sh
	chmod -R 750 $TARGETDIR/jobs/
	chmod -R 755 $TARGETDIR/debian/
	chmod -R 755 $TARGETDIR/gentoo/
	chmod -R 755 $TARGETDIR/user/

	chown -R root.root $TARGETDIR

echo -e "${CYAN}Done${NC}\n"

echo -e "${cyan}Configuring services${NC}"
if [ "$LSBID" == "debian" ];
then
	# some of those things are now no longer required and will be cleaned up

	# if [ ! -e /etc/init.d/oxivbox ];
	# then
	# 	echo -e "  ${cyan}Activating debian vbox job${NC}"
	# 	ln -s $TARGETDIR/debian/oxivbox.sh /etc/init.d/oxivbox
	# fi
	if [ -L /etc/init.d/oxivbox ]; then
		unlink /etc/init.d/oxivbox
	fi

	# echo -e "  ${cyan}Activating weekly update check: \c"
	# ln -sf $TARGETDIR/debian/updatecheck.sh /etc/cron.weekly/updatecheck
	# echo -e "${CYAN}Done${NC}"
	if [ -L /etc/cron.weekly/updatecheck ]; then
		unlink /etc/cron.weekly/updatecheck
	fi

	# if [ -e /var/cache/apt/archives/ ]; then
	# 	echo -e "  ${cyan}Activating weekly cleanup of /var/cache/apt/archives/: \c"
	# 	ln -sf $TARGETDIR/debian/cleanup-apt.sh /etc/cron.weekly/cleanup-apt
	# 	echo -e "${CYAN}Done${NC}"
	# fi
	if [ -L /etc/cron.weekly/cleanup-apt ]; then
		unlink /etc/cron.weekly/cleanup-apt
	fi

fi
## monthly cron
echo -e "  ${cyan}Activating monthly backup statistic: \c"
	ln -sf $TARGETDIR/jobs/backup-info.sh /etc/cron.monthly/backup-info
echo -e "${CYAN}Done${NC}"

## weelky cron
if [ -L /etc/cron.weekly/backup-cleanup ]; then
	echo -e "  ${cyan}Removing old weekly backup cleanup (this is now done daily): \c"
		unlink /etc/cron.weekly/backup-cleanup
	echo -e "${CYAN}Done${NC}"
fi

# daily cron
echo -e "  ${cyan}Activating daily system, ~/scripts and ~/bin backup: \c"
	ln -sf $TARGETDIR/jobs/backup-system.sh /etc/cron.daily/backup-system
	ln -sf $TARGETDIR/jobs/backup-scripts.sh /etc/cron.daily/backup-scripts
echo -e "${CYAN}Done${NC}"

echo -e "  ${cyan}Activating daily backup cleanup (saves a lot of space!): \c"
	ln -sf $TARGETDIR/jobs/backup-cleanup.sh /etc/cron.daily/backup-Z98-cleanup
echo -e "${CYAN}Done${NC}"

if [ $(which ejabberdctl 2>/dev/null ) ]; then
	echo -e "  ${CYAN}Found ejabberd, installing daily backup and weekly avatar cleanup${NC}"
	ln -sf $TARGETDIR/jobs/cleanup-avatars.sh /etc/cron.weekly/cleanup-avatars
	ln -sf $TARGETDIR/jobs/backup-ejabberd.sh /etc/cron.daily/backup-ejabberd
fi

if [ $(which masqld 2>/dev/null ) ]; then
	echo -e "  ${CYAN}Found mysql, installing daily backup${NC}"
	ln -sf $TARGETDIR/jobs/backup-mysql.sh /etc/cron.daily/backup-mysql
fi

echo -e "\n${cyan}Now activated services${NC}"
for FILE in $( ls -l /etc/cron.*/* | grep /etc/oxiscripts/jobs/ | awk '{print $9}' | sort )
do
	shedule="$( echo $FILE | sed 's/\/etc\/cron\.//g' | sed 's/\// /g' | awk '{print $1}' )"
	file="$( echo $FILE | sed 's/\/etc\/cron\.//g' | sed 's/\// /g' | awk '{print $2}' )"
	printf "  ${CYAN}%-30s ${cyan}%s${NC}\n" $file $shedule
done


# add init.sh to all .bashrc files
# (Currently doesn't support changing of the install dir!)
function addtorc {
	if [ ! -n "$(grep oxiscripts/init.sh $1)" ];
	then
		echo -e "  ${cyan}Found and editing file: ${CYAN}$1${NC}"
		echo -e "\n#OXISCRIPTS HEADER (remove only as block!)" >> $1
		echo "if [ -f $TARGETDIR/init.sh ]; then" >> $1
		echo "       [ -z \"\$PS1\" ] && return" >> $1
		echo "       . $TARGETDIR/init.sh" >> $1
		echo "fi" >> $1
	else
		echo -e "  ${cyan}Found but not editing file: ${CYAN}$1${NC}"
	fi
}

# additionally, let it load this way too
if [ -d "/etc/profile.d/" ];
then
	if [ ! -L "/etc/profile.d/oxiscripts.sh" ];
	then
		echo -e "\n${cyan}Linking /etc/profile.d/oxiscripts.sh${NC}"
		ln -s $TARGETDIR/init.sh /etc/profile.d/oxiscripts.sh
	else
		echo -e "\n${cyan}/etc/profile.d/oxiscripts.sh already exists${NC}"
	fi
fi

echo -e "\n${cyan}Checking user profiles to add init.sh${NC}"
if [ ! -f /root/.bash_profile ];
then
	echo -e "#!/bin/bash\n[[ -f ~/.bashrc ]] && . ~/.bashrc" >> /root/.bash_profile
fi
touch /root/.bashrc
addtorc /root/.bashrc
for FILE in $(ls /home/*/.bash_history); do
	tname="$( dirname $FILE )/.bashrc"
	username=$( dirname $FILE | sed 's/home//g' | sed 's/\.bash_history//g' | sed 's/\///g' )
	touch $tname
	addtorc $tname
	chown $username.$username $tname
	chmod 644 $tname
done

install=""
doit="0"
echo -e "\n${cyan}Checking and installing optional apps\n  \c"
BINS="rdiff-backup fdupes rsync bsd-mailx screen"
for BIN in $BINS
do
	if [ ! -n "$(which $BIN 2>/dev/null )" ]; then
		echo -e "${RED}$BIN${NC} \c"
		install="$install$BIN "
		doit="1"
	else
		echo -e "${cyan}$BIN${NC} \c"
	fi
done
echo -e "${NC}"

if [ "$doit" == "1" ];
then
	if [ "$LSBID" == "debian" ];
	then
		apt-get install -qy $install
	elif [ "$LSBID" == "gentoo" ];
	then
		emerge $install -av
	fi
fi

echo -e "\n${BLUE}Everything done.${NC}\n"
. /etc/oxiscripts/init.sh
exit 0
PAYLOAD:
begin 644 -
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
KF3_S9_[,G_DS?^;/_)D_\V?^S)_Y,W_FS_R9/_-G_CSY\W\AR%9V`&@!````
`
end

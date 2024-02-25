#!/bin/bash

# Please do not add a / at the end of the following line!
TARGETDIR=/etc/oxiscripts


INSTALLOXIRELEASE=1708826946

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

echo -e "${cyan}Linking files \c"
	ln -sf $TARGETDIR/logrotate /etc/logrotate.d/oxiscripts
echo -e "${CYAN}Done${NC}"

echo -e "${cyan}Putting files in place${NC}\c"
movevar () {
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

	chown -R root:root $TARGETDIR

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
addtorc () {
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
	chown $username:$username $tname
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
M'XL(`````````^Q8"3B4:_M7EC(IE9((KS%"-<82.K*$K)4E&2K;F'F986;>
M:38<QK0H*5L;4F0KOA;545/IE*0DE92*BD,D;=*B),O\WW?&EG,ZY_/UG7.=
M_W6^Y[J8=Y[GON_G7GZ_YYWGUL-)_.E#'QZFQL;(IX&IL8'HN\'"A:+/@2%A
ML-#8Q,384-]8WQ">-S4U,I4`C/]\UR0D."PV@0D`$E`XY0_D0";KKW#HKQUZ
M.#AP46Q$)H7!9NG!V=`+_M'PO[D'4F`3<;U_J_[&<-V_KK_!0D,3$PE`_[_I
MQ+?&/[S^ZMLGBA\DVY5#/1X[&OI;E.3,/C4A9@_IH9+VU'7O-LI>3',@L$X_
M3"ZS47ML1KH^_[I!#,COX21A2MYN>2U94.SI-=TA-_K6\C#7L-"%?5=S;=6R
M?>;=.>ZN-_O]P[JZY!+9G_5-G/?MTRK3KP3GX%)-*W%9G9\/7P@WD-.<+Q'^
MQ'^Q?%,<$(7:G*FX\((F^GSM:1\O*=,U=9%2L^7;^>>\,QOXN6Z_U$>-ZW:H
M;E7KO=7%CW`J89OWW45%QO>Y45;==GD5A-LFL[;84CGA5'7'=D)3B*"Q5D'S
M3D9TUT;/I$\A#AW+VTLVZ3VVL%P<TN_&\UILF/!Y7&.Z=/V:!P6]YW]<25%+
MJRQ]1_!L5'CB^52>71[3\,%ZYJ7;%FI6KW=IF/G-VKTT*:DRYN3AO"@KW9//
MTW3>6SN!^MS/UH%[/6+B+/,+9K_R/YTA<:]T1EQ#YB'UCW.\+CFX3;?/:F[Q
M-HP*I!UHS:NO\GX88_59U<TR<=U]W9D/$ERI/X#=%@OVS[R14(P>_['MW6N/
MC>SB!::9#=<Z5==5'528L\SJX!-!AVRY6CV_DW\MU-_'K&'[E"J+J/B);[.$
M4%4/_^0)]YN]0EW@';^S'W0+:<>>#9X2H+2^L'?-K5GW>N<^]:?1FM1;M-_Z
M3I@AB(_I<914[)]\Y9(\>@DS^>GS':=SM]NWYQ^^/K,EN>C"(TK9TR_Z<DLZ
M".1QJGT3':6KK5HLGV?W0O?4&?B^=6>B!;&[]V?'<V/;V_=5AIR7#($2#/(W
M11=+;1MW0*#Q4C;)>OQ=J^[59,Y519V(\);)/:EH-U77=O\W;V5_.:VPH31&
M9=N[NE_>V1VC",C3EFB`UI,S<.,?[&&CE2S'7[-UG5E[6<;TRM0[14V?IE2=
M>3+K>3-J_9?9^-U+>V;..67OQ3@_?9>N5K3:.G"7I%=EY^TC>\X_\([J.TL7
MY/5ONR<5YV#BG!9006%)3_NAH&%B>&;CVO5[-V^=G=#(F;.%/W>==4U/2HO?
ME]I9MFM..#A)J+T5VMS1N=E3XE[1*W22Z%//<"^7>,*3V3MA@2VH]+$W8%)3
M'<=RN\1+_..R`Z;/WT,-A#/Y#R^H+CVR6/#6IO.G+^=W%<=+<;3C;1R7H_)>
M-9W;&B$9Q=U()I\#:J<9['HB2*I0D][F?"QQ2FSIN);UF0$*FIW]NUZ^N+I:
M,FE1(8;\95G[P?Z=-TPCKRT*7]B56/1L7='*`_'-ER@'UP%V-YEWY-U1<V6*
M'\@QOIA-,W69%^MOUU=;?7YG6F3^GKZ@EB-G(S?<C[N<!GTLZ/:LW_(6'3<[
MW[17*K5/+C6^Z--42?^)SL5*2BHV*$%(];+`^.+;G"GSSSCE&5ST<F[\<,;G
MX=E<G1G;3([&F/U\O_%EPYY_]<Y/FR;0-B7A?7Z^W(B>:H=]NL!+\1/O3,)Y
M*T(F_?J!?3=6U;>JK.FW.*`6;B<YB1,B=[2?MV=G!E\Q(=#VW/&:NO+,X(QJ
MS*RC'M3KMW/<:Y(6A%5NJZA1=^$8>4NDJ_T2+J@Y(Y/DT:-@SNZO(5AY"54V
M,[G]5M(W[PD+&P^>:GA*4OB<95<[S<SWMKQF693G7;\V8UNC;=35B>L5;,K4
M901;W5&'W/7(Y8?P.AHK+<OG357$]TTCOG.'U@BP/M,6:<R=1OU!#9/G[BHU
M7DJU>_VB_JFYL9OV;KPD]73NSM,F]@[FV;_8A->4=/H>16&:=DAGJELW0HLS
M5)2\"5)7YD?T`5E!>,Q-Q;Y)KQK[PK/]HL(:`JESMJ;\D+RI.H?,_3R;2]J0
MDW3MK4;"\CE<[A*G!P:S/4K&*=ZY/V6^]N2G\J3L'>1099V\%G3]0P/NI'7:
MN8)&?2^!UPF]HD?Z"P,"J,3RJQ4I*T"RFW>B*3#YXXQ)C&S=%@E0J4UUNZ*V
MM?;5@,2*IAH(W"ZEA:LV][5RNW^#D+_IC=V+YODMQL:)C.H/+XZ!'@D'*W5:
MGWR*3%EVE+Q`8*/5[^ZYLO;2(\?#";?)$Y]4R#^2V6]4*">7F3PC<*>-S4KO
M)39$@PUM:],F=3W6NJO!CMOJ7#_^YVC?WD=WE^.G%BCL*I3%5[K4E1GI1W\\
MUN.T($#E3=,M=,U:ZL426C*QS/ET=SK8%_V*]R8YI;1#8H6#RE:UCM?:6;;1
M1I8=L[J$SBJLMA+W2]FO>_GCTRR%J2U3763&9:LNVK15&<J]I"S'.-LRX3JY
MHC=4+F-#2%<,;Z:94AB^MBFEM6!O?HO-7++9L;V6]CE^.<R>3XD-!$9Q2L+E
M%O70A(::1TY%)_G<4X^/JJH;GUCHIU^\>;IF8YBG^2[?&^7A9J;)Y.13U_39
M^^9>+<QD3-@ELUKO3<.'W3(*27UK+J`20EK971(N1[0_5M+W:/H!.80FZ\S6
M@K6*19XE0%NS!7W5OOUG+Z.D8R0)'JA`NZGR,TK5ER9V;%YVPOGD-+,-C;$5
M_K:S?^I(NV'L)*EP`SV3>.[PT;D$<Y^RL%4+WKEYR?GJ/O>=XFQPRV*&TQ8=
MD\ITY=(NYQV=';>;GRQXHR@31`OBJUTK5WLIA*A/VSX(+]M_ZNMP"I@KM.JM
M+C`^<BCPA/V%-18&">9$:E=6<4__B1#[4C>@W._@:H.UG_09UI-?V,[><>JN
M:["/4W6WH!</OUDL<8"CK_&S"L+UW?+3,Z+B6Z=K+VL-.UI'*.Q!Y^&-"P19
M,5,55FQ;(DL\$9E2.[/]8%SL54O<A]P'BGB4K//$;'G5^L@5-16MMEX3OQ@Z
M&J5.T2S)LNCJ-S<)Z(.Z[%.ZI(\<+62HGN^JC=T0V\LO\D[O$$+T9T9"/BKM
MG?#^0XA\>,(QC4Q_W@Y!ZZ,'*Q91FBFX6,E%_GUI7O[\'R,NVD.G4[^<6U>H
MTLWA'>0<V&=^3&8#].I3P/-P52LP*ORM%D4]4256Q0?WC)`!-6*;[\E>\3ZR
M1SAG6W^E.6]'KO+FR1?.5LUB9LG':6?Y;?AQLI_V_I?FREY$/Z4\_$S):.G"
M,U>#><:G;-M23UPHKZ5K^)A:Z]9KE3P.6^(E-?T%8<'YW0Y:SJ]:S:L"(_QD
MJQXJHXI/:<__\>)AW;;08BZ]CL=KU=WH6B^,[.T5SN^'J"EMM_FYR0W""&4X
MNDTM]C5/<]HGX`L^9NCDV/NN)7.3BKKNRZ>EWUAFOD;I4^?ZU\^:G>L9BOST
M,NFG[V5V]%[4\F<I?C`_W-3=D'-H>_!'N^W8:\&TN,I)DPZ&[];$E:[*/Y[T
M>'RJH6W)N]AIR3[DQ:73G>MX?.[T1DW'EW)5RNJ)W!8-[/N>U/[)9-\;+UX5
M-DYVDGT!I:;P-H_;_D:W0N"Q?'*JZ?K#^7T[E>)6?7:\?U.[BO%3EEE6T_CU
M-AZ\(]7[`YA[=?:>*LQC:3DK7KEP#%>:;.93$#<O\HAA8KAM[9[-93-8>ATV
MSVL,!='W9QG59I_X("_)+;_)2#SY+,_#!]6P3][0B&%YSLI08[DLRT@AO38C
MC;_IS=:EK>J:^`^'[WKCWEJTW5#W[-+0XB^SN.?S4IC_+.UF?"7I)B4TGW2^
MLOV*3P?)QORAEEV@5M>I9P4K(Q,I=Z^F'_I\I->_9@)^*NK5W>C=1_RGJU4*
MG;O>\`/Z4GG"B.EI<<*$F@;I,.,[)MX?.ALVFF8J^58__M?V/;)HXKVP.HN0
M]`C\<54MX;*;/B;SJJO6ZO$<$D&!0#ML_O5W.DY7S)+0XS;?PAI&YY2M3V:F
M/,S;:5YJIN2]^5FSX:KH#D>=$SLQ5>=6):2<5<O":27I9K`/U\UJXV31>?/L
M?@G9Y5"1MN%5./H*ZOVYL/=)UG>%V47=W5^LKO;T'[C/=Y4TZC]>&C7!M'O1
MI>8M;D5;(O:7IN^I";M_:+FB;Z/`QS#S56AY]"++PFNTG#R5O&K'UW6&TNXT
M2<TK:<H[J^:=WM!__4YK=.)Q(Q=C_J%]AAA>X;]8ZW<2EG9Y/.JOR+T86O\L
M.Q+3J=&=OL9E_X*?4[T7Q1^=6+/:;5YD[&G-XIC--_.:?RK9W=/#CC:L`#;)
M_>X_H>EG]<YG,>T2;G_6[W\]')?"9',(U$`H7(]%_E/V^/W['WSSTS<:=?\S
M7&AJ_+_[WU\Q-#5P@10Z+I#`(J-0FGH`#F03D9;`0#L`%\2A$]D4B,[20P3`
M<`;$9`.NWDX>MBN=W%9YV'NZV*YR<G7QL$!C?F/6#`K'<F%D88-!-I9+8Z%1
MHR8`'5T@$B5+"0+6`FB,`1JPL`#06"P9I#+0@.]B@$T&Z2A969!(A@`TBPR%
M(3,`H@@%`00J%1"5!8#]`HEL@`E!;#0LS@39'"8=T$?)!E'@/X@)>'K8K00H
M=`"C0V4!.#)$`W47HV1)$"PLVAL+`FC1-`Z#B.+T\&)6V$#AN!4$(IE"!UF(
M0[#\@$MBGQ`]D4VL`8#%$B$JQ+2@@UR0"?R1-5TT$`6$D2E4$&""!!*`7X$8
M%[LTTCABP(>-P:]`BY?I(/R)A"5ZY'UG39@<.IU"#_YU;48LC+U&2&$&#``B
MRZ-+PF`!!$XXG(!@)L@`AD\@'!Y.D2.<#BK(8@TN8[GBSRB`$!8*:$<RF!0Z
M&X`=\6&C,2[V/.WOR@)"?P2*P^$/SHPM;D0)#A9PL5YA]^N`:1%$B$-G6^B+
MX8A?(09C$(5.$B,%P-()-%"\#Y8=P0`!TA!"!Y4Q.CJ8@6=@OH&N+KS$I2%J
M\(K("Q@E`UG"VN.&,X7D2%=D!V'+'P@;B66'`.B!!(84$A8GL`",V(@9,(!(
M)#MK`8R=I]-2.`00T`=\AU,SL(H>4!)G$*,31H8(-`I,@*]DA]T;6!=-8G00
MDA#)`'P@@2`=,+3$D4`NCLZA4G4!+(GF`6#$.<`.;`(,:7R%I1%Z`*S(&E1#
M-D$*)`M26:(O+,Y@C`"6B'C[Y^Z/'LGF(;`-5!E.&(#6%Y\[(]$F.A@B5]HM
MY;E`<%T\@"!8F@2$4=ADT?F(&(8K9(")=+'EH44(_#Z*0(Q1#!%-C)$@$..;
M_`#@,4P1Y-M86(+(PT0!!L8WZ3(H,`;2#-O\=ZDSJ#&"0!"#\2T"#4K_#HV`
M$>/?YA,P:OR*6Z,%QHQS;"@%AC)B<!#K*PAT0C"H"Q`A.IL)4>%:#Z@`!"*#
MPH#"0&8@A\V&OO9NH/JBE"$4'+GVO5S\#A^'2S/@H)B@@T7X38XBBU]E_S\A
MJWC'[^(K$V2!7[_2!F?&Q%B1TC^4LK_SSOMG4%94_+\E446>_7^F)Q+K5^P<
MF!@3.44)^Q\W_Y'<%+VFH*"@OR4]!YW[&S`4A=(<I!B!!&_/HK`@#H-$8(/_
M.7E'&1HF\:B%,9%Y0`4)!D8^R*03J(#8'@`;!-@00.0PF2!,BN&K,L`%F2P*
M\D-E]%W3QMIVF:>;D[V'!0;^AY(5/6G[T+51(V\/Q`@"G><!$IA(.R)XX(#0
M9@U=&48<&*-Z-B/NI;_-XN$K^N"]DTO['2G#43=.'[8M&22&(E[I#`!0%\$O
MEV8&^!#1(H-LD(6<2#"PL=2OL#T,3@!I17!I%'H0)-8&L%B:N/F"-%P(@500
M/=AB('%)@X\X#HN)8Y$)3!`WJB_AP($WM2:1*.)^&%P9W:'V$5V$9\2K;W:)
MQ!D7&0&&K``TA`(@20/PI(L>X:CU]/0&JR`K"W'8#,X?ACJ"AJ)(X7@(;#8<
M+$"'68?6'7&__2.'Z!![T*DA+X8NJ&(L#0$,-;JY]JM7RXC.U[>.^$$TC7;,
ME@JQ$`S00!*%0Q,!=."DC[1=;>W"$W7&AEP<G2>13Z.S!%L$!\PA%1]+J9$<
M#MS1:=PQ:8Y)6`^BDE"R>!M7;[S=2CB:$=Y'`62D3PA#S6"H,V8'`=IK];$_
M^.K-0S@T(H6B%-F#;#&["41D6\#)PW4$N,)@/L.<8#`AV!B+94&"V&8T,)@`
M8%W'%N#_L?=DVVT;R3X+7]$&X6@%0)!:'&GH,2U1%B?:#DEGXHDR$@@T240$
M0`.@*-KQ?,!\P7V[OW@_X5;U`H*+)=JQZ>2$.#FQV.BNKMZJ:T<G27K[INF&
M@Z`;VJZ1L2B$43L+0!,CFP'I6KY#D$K*M/S>O37!S$QNLHL>#>;=9!+&/%LM
M!+B?O]/&KLL'Z#F9GZ#+^?PX39^8J?F(^ZCV)Y%X8)`XOF>"YI%),A0&@I2)
MBNE-\+$#_ZF$\7.79)($?E"^M0GG=SV&B=/V=9V`/]G_U\KO63M+_]]%/&+]
MXV'@>+[=^RHFX$?6OV`5)NV_Q?S2_KN89\S^VPW;+:]+2RIN!_AA)/>)JBB=
M,$ZLTK,=X_N\81E64<FQ$I!-2#WL1P[E50HE:Z]@6+M&80<JY7FM`M8Z`H*J
M*&[HVUY0LAV'=FGDQ8;347*\$"L-.L"7$PH_0?AQN)[!BY4<6E.'"6=C6B`<
MD1<D'OK-L`OB'7O(42BX5M=K#4G/AHL$88G7CSZ`&4A?I1LF@VT^_>E:OWYZ
M?Z,HTOBHYE2"9P,GQ7#B._*<F(G?,],R^*$H7))3R?/G1!/S*,KT.9Y9[:IG
MY<LZP"?,MDA=PR`:DSEGU!TO4]X+RS+>5:L'J]S"W+=(SSK`.Y[?['U+?:%J
M?`$$&.P.)_HU,V0QI<CLR1'5F=%SHI&E9M_B"RB;A;F</^!!F_U6"\79=Y0\
ML[XO`%&`PB#$M[:#UG6=$2@A&R,H+..[4./_Z#JB:P$GQ'4YP-C:<3P((]<B
M5XJJ]5#'I?,MJ?%_>)/"C"98QAL$H=U/.KZ[@SC$76R$FH,"^?[[XD-3,YI!
MQC;(.3GV`B_N4%>\FG<]$00Y(!_(WV9MO=G;]^,;,MU8$IN'=M:G[]YO3=*6
MSR<\F?O_:[E_/7;_6[M[D_Q?H5#<7M[_BWC&[O^3BWJCI%(WC.S8\+TDP8O:
MI7!1J\H/E3<E53NY.*N81AQWS`BWS/4M':H*"L`E%29055Z6ZY6C*OQBKX%W
M8##12%&Z0:*+@ON-DHN[%.[6';C!"8AC-$!)ZPG)W/0^+`MIHCJ4#$'2(]@O
M<;WHB<(E+^BC#FP*=U)3E?J;\T->9"0A\`9#8K1MSS>!),6(!"-E3=NY[?>(
M';B$73N\-6D.":`NZ26OA"C\C*YPOZ@*#);H'M%@`KBL_T+#,1'_%O`A>H]H
M8M"F)L>*+96(WVWOHC[><(")SGBKD1L("L(9X"KWO<OVL?\?<S9PDQ2>?V>1
MD=X>QL@Q1YRXZGEJ/`#,@O&L?,Z`-$M9&1O0).X(?`[<H1+3S".H252QK!.%
M@??N<]%]#,F/H0>8,_Q_UQC%R%#)<O8&2IB>Y?UHNWY04,TY6B6-U5*XGF>B
ME=S/O(V<K&R++W7^)?UW.@,[>`<'L$V[GM/YHG?!8_+_;G%G,OYSM[",_US(
M,T;_UR;TI`&YZ?<2SZ>IG<0>HEMF#`SL:FP:&T!.K]:8`GKC:AW?&AOFE75E
M6OE-<_5F&IIC)\3L1:%C.KT^L\P(P&<G[R9UAMNJ6<R33?7@PRQ(K8BF6*W^
M^XSZJY/MBRJ@4=@VBYOJ3`ANB^B71+\E^CT)6EEO4^LVA>6UR)IFD?\0E9':
MM=B)O=]B=UU=?T_BS1)J-L6_!Q](Y?R(B-YCWO=.'I#8V=S+PRARDTBHJK(.
M'36=T8Q>K1G:U;II7%F.;ZXN@I,6Y[]G1S&UFT[\-9C`Q\[_CC49_UTL6$O]
MST*>L?-?KQU>EALG)<[F'='X-@E[)FP+I5%[->--0`?7^%89W<6BHJ(<5T\K
MA^>-4EXYK9Z+O\0UAZ_PGKL!R5X3?=X<L*LNM1`@D:`Q,P`BV[2/EQ^V`X9`
M0F;41!._R":Q0.A=R7C4BQ;2OBC1N*'W/;A+Q4_9CEVJ_"Z>Q`&E==D+XA(S
M%C(%T$5O?D/]DXJ]XORCUJT9WE_W8[M-OS0->$S_6YPZ_]OY/6MY_A?QP/E'
M0QC2`!K<$48'<J3<3SIAM$_(1=?#8)93VPW@G[^%7>]%M]_N@$3X'*J=>@X-
M8CB<IZ\N3Y4<*XF3F(C=1)A"3P3J"",;#]B!FJ*8JQ]C13DK5T^9Y&C>V9$T
MR2$@D-\N*[5K+F1JHIJY`9S&ALK>'%U`X?G$.U5I7#3*IZ-2**B5ZR>LBW$H
MYAGT`O3+-!H@]W9,;%R_+)\]6/4?_>"6U3RJE8\;]0?K'D5V*XDYW,IYX\&Z
M=1"&64TACU["M+_F>M@^T3M`,.5D(->`/DQZU$G-WZJI9@RT6]K.%JIXMS^L
MCE@,\L)\8;971U3N*AKK[(@MR'AW?(;GZ1"ZF@F9S2PY#KLNK/X(N%R2WS>6
M#.NF;AOY']1LP3,LF(E3O6?[TRB)E?\F&/&-,HU3NL>^S3RAX]GT//&=_$TP
M:H2)W<WL(CSI?]+[]UL_XO[W`B_YJOK?!_(_`6^P/:7_+126]_\BGBS_G^,F
M/-P+0CF*"MI!9/=Z4(R\NU"XHM,K<`VZ@WZ:L9=ZNTX&#[.ME5:"_46T]R\^
M?*[S?!*&71V(0]=VN-]MMN`3(UMX&Y!!F"Q2KY1KAR>D5KD\+1].N],+L/H[
M@%R<@H:TZ;)+[9B2N$<=-$&#7,(+BB3L,2^B)V0-10?2BD*?).$Z]"$<,AN(
M00G(HI[X/5U;$V:\&/VED%BJ,:H6M8+95HE6E+9GC36#*DRC,BJ!]UH1\??'
MZ[$(P%GK+\X_.M==-[WV-1-POC`E>$S^W]O=F\K_9BWY_X4\XORSTZ]5W7TR
MM1.(99%"/O^]GB_H^5V2?[:_#?]9_R(@#!"-<?W'Z)J)0C$<+#S6T)Q+RL#6
M5\^OZ]5_5>!86V?`+3,C#8H<PI43209!%`CR_<2,V9^P=56E\M/AZ>LC:*DB
M&7);RM%Q"<Y'"R[]=45A1_()\!=D,DA#&N!!DMTG6I[\+>C[31KI7J#[S><C
M/TYZ#W3.4L:B)8XNKJN-T@WS-=406:(S(693DP,A.F=L='I/'8*^"=V.3=Y_
M(%<'&>9E51/82[7D^U7!#^VPL/5=%6C)'O[OV>J'D5[P].*T=,.=*!DFF"+`
M@1Y&-02!@XHJT=N)B)R8':62`90-QD"*EJZ_//_H*=P&@8Q&PR_.!SQZ_HN3
MY[^XM[3_+N89T_^A+>MU[;0D'+H'@X$1PR'M1UW#"7U3[`_3\]O72N7\J'K^
MJF3\VFLKAQ>OSQLO*Z]`"K?X#WA;0C<>I5[^L3)#<YC1LET%@LE/O=4U@<?/
MV@BPKDFXOVB\:]XH@1TN^P!J\X;5*F4:"GQJ@%E&39DV<=QL>ZX]_!E5AZP9
M'#U*TI[)+R,=92M%5L!'A8;V<UI7SZ"P:?VBY"3(+3)S5-(=_VTZ>ME`#E=9
M24?WLWR'D%?D`-/>:UC,=9F/KK\QS:1]\3WVV/G?WI[T_R@6K.7Y7\@S=O[/
MWM2KC4I)LY3Z::5R6;+RBJ(<GE0.?SBKE)*H3Z'&4;E1+MTX0!-8%@O>Y$8>
M'543U56NSX=]BK]G-)"L.H>HDB<E]H-5'\MX(?MOV9QAOO=IC'<[T1V*#H%$
MK:,$(@`3IV,';>H^&7'8G!]@_G$W^R0(1968Q'",8>T-PT"6G_ND:&SDC&'^
MHG;V/^J3/?_HH/--SG]QVOZWM/\OYAD[_]/IOX1>2.$$H5&%<V@IC7+M5:7!
MG,6ZH6-W<=_<WP/[<`'L*R,3@AIH6,()`7-!TAV+:*/61$C62`;^#NPL?<O9
MV<SASQY*['WB4)]`SV2`^DD,/D.YFQ]SU".B[>`>28Z*F[LC-C<9V'!Q@RA=
M/@*.'I7P`(PASNC+RE_GY//',&L5F(J*X;M?K8]']'_6WE3\AU4H+.7_A3PY
M<G'OU85:3VET/`PY9Y'H3NA2M`=2IOD;T021.\".*`&1UK<CKSL<\ZU$L1YM
M2`D-[,"A4FEH*"\IB,+8+NG`24U$7S9&L@])V.7J`V!"PVBXA<Z@`4J['O08
M)YA_P`O0>(C_^$/L^@XU932X\Z(P\($&&(I2AFK`ATO0S&V>Y0E`^K:%#J70
M?X#AUF]HO`7"@VL/H0<R"/O0?>SY/1P+H!G$7K-+=1R^BPP":?8369W'2.,4
MX<\J8#V(/!:^#Z]PU@SR?__[/__%\!320!DA1BGE-@@'R@844-(&9,.0].PH
MB5-T1V,7D3#821^[A]G'P'+X"Q="Z!838N7)D-I1#$"KK92G@=GA:01@6Z.T
MQM8IHF_[7D3=+=+C>DGJ>GP$-Z+B=:\?(>]_P_0VB">P21'%&;9)0`=IQ;0.
M$=D@,,(2+;@\Z9_HB&\>G'D8_OH6)@,D-[Y]2Z\CRC!`,&(V(HP`A2V#_X,N
M_!XS#4]79T!P77VF28%.Q%@C&O>[+-!D!I)WL#\QU)_<5,_KC?+IZ<5/U5KE
MM`(RULVZ0?[)DT@`6)_B%'JQOX4;`O<EMH*%<VF"N24]1$HD:F#+Q4=JP"@.
MPZ#EM?L1S^`PZA&Z.JO6:A>UFU$A`.R%J`B"/X9A'PX6W%M9O`%>'4\0;#W/
MP=EEH&W4(J=;&GUG)F_JF";]'@/P2>??0!_I*$Q@6%^)PCQN_[%V=R?I/_R]
MI/^+>)BW!6R![%;:,*"`O$]UA@-*;[O#4:RWQ_RRPMNTA.\?LE-(2YP03BG(
M:6D!4#.O1?U>,D3SS[<>]?*1CV'^&C;C/US\]^[>]C+^>Q&/6'\'KMF@W]-M
M8*J`I_BR6H!'Z?_.)/^_75SZ_R[F&<__W4AY<L8+`Z-X;[-_6>9M8`EQFW`.
MG]OW<CPK2]A+S-[0CP-3;""BVXRIVRSFB>X"$Y?\503J/]DCSC^7W_11)A3]
MSO6^%!5XY/P7M_<F[7\[VTO^;S%/]OQ/J__XMF`*P)SP<;%=EPLN:/_N8R!^
M^1C-7RCZR(\%/!'!B+"'N%\.XR*Y2G`-95FBMYB]WP29+M,?;CK19<]SUS%7
M`>$:0"M_P-/OC.S:&OK"/`9#458NR[7R604-9*JJK-1>GY]7SU\U*O5&25OK
M`:$*B?K4QHQ$:]T8)$]APQ>YC)@K4>JUN&&:[=7U&<F-H*@?>&_Q58+Y*T22
MKO%X))8#2?1?TC*(8$ZQ3#"C"!C$,:73:&IK,GQVW=0*2NY36QBQ?6?"*J)G
MT">TV%!6<B^Y;@<76/QI&`#HQZ,JAW-14DO/R5EXAR)XIM8<W:#M=PR2-OI;
M6]/\.Z+WYT37W/B4<:W#G.>.JS^=54C<Z2=,>PP2OL@/R`1\_OT")9/@3RQ9
MU@.LB9L3-O.S?)Y\]QV1/[?S>86GDH?QI/G!9`)-GG93I-IL#JFN%<CLG%6B
MQ^GDU"MCTY^9M:L`UJ*.9P97@Y^Y'\_208X,707IVY9=7Y[.!15>RH,=O$RC
MBC.MX*BPXSE[.:\";<UAOC&:->^29E8IHOP+"]C?CV=SKLKV^*H\^\BJ?#0;
M*I'I4.4ZS)O;7^+$ISCUV]&.*B]?OV)^._DIKQVX<U'=J#-)>6B[OH>C&TT(
M$!H"<Z3SV5+1NY%P>-7SXXLZT768XM%\BY1O//<JN@,^2BI!+L]AQF_]'OZH
M^NC)96,H(TU0N18_4<2LE?`U4Y$QQ:V7UF1J7;@;F)I655%-Y>"5`5351PT=
M,I*,;32!=,6&9"[WR>BVX-$?@\&`.9^HQ.S92<=,0G$3*=F:_`,K`JFQ;ZR<
MV)%[Y,6WL8FS=VU?;ZALZO"7G8$Q/XBF@?49C#AIBHG:O/_S\[3C_%\\C!/J
M?XWXKP?XO\).<4K^RR_]OQ?SS,W_L9/,OG74E%IYHGOX&2,/2.X1;7IV\-OK
M9C](^K_5[+B'O]&'^;3^LGI44EU6`0CBP8&R\HH90#)ON46$O\VMK-2H>V(G
M%?3N`.8IIG4:`:GY[1!J7=37L89L&%$7B`XR$=B4QK:#Q*E%!I09/L(`1%G>
M->&V'+[#MZ3!*FLK<4D/"N$&CA7I98F=<%=R@3\ZIO!+)D?XF`7$6$#$&TL"
M[WK`Z0+QF]'!2AIUY_9NVT"[,0]G#-/*/[8EW;SQ9:98IH^8^5(@HJ2^WY.-
M%=J='I>8^>RX^.H\,*Y!&'5=;BA*$6)J9*]ILKN@34U>1Z"4:7M+HX!VA5U#
M67F7R0C`BHSV.SEX7E7GY;JVUF=97_5H?7P:/EIM:D(^#A!OZ1QAR4B)V0Q#
MS#W3"B,JL/Z[$E#J4A<8H34F':BLDLC8TH+5;0*W3]/(I7_GC`U6P]A04S&`
M2'&!@""@*G87@Y2'UR+7<DE`YKTSN#Z`79=;<:(Z7[S,LHEJ'$_N337F1<7:
M^;1DI1X4LH3S@7P&Y+PB$K)G48_W:*5L%D\2S:L>()_!^8[KBTL1QJ'K]-[I
M]EU:8G7,=M1OLO_1X$X=ZTDNU",=]B=[!(0SO"MF$8J$0[EAP.&[13-TVW/(
MP;HBN\.7<E.FK9T(Z`1,=HQ<&@7JAQF).#:ZR[=VW`O#KHD5S=&<9_?^J`(#
MA_/YK4G[7,_$_2],]5\^_N,A_X_"]J3];]M:ZG\6\\RO_V&Z8=@LXNAR)Q'I
M$P(,/5PSZ+P`]QW%_,HX7Z,SA%]F-&7E5%"3!VCL+?Z0&Y&1)0`B/]IH;J35
MOH-;0DI=D_`FJK)/6&0ASAX+1I[,-0ZL.'L,^(;A#W_,P!U?SX%WDWNZ1"F4
MV?@:N&@;W,]A$EOLE&$D*LWJ%;U)9"J.;&69,$-@Q7)?B%'A+N&I,A`M!"!2
M5@G4N:]?%C`&T3P$EXU36T/FC-W&6'\]V]%?R!?O6SSC]#_Z*GD@'[/_[18G
MZ7\1BY;T?P'/W/2_ACGI+LOU^C\O:B!XQ=2)\#-<(LSMZ)IEM>B&<;+)/L^C
M*CP!HB1M?I`(:(25[YOBYPLT)AC,.Q=CC-A+'57;P$`V!UW/]Y*2!9L$@P"1
MZA4C5P35H@8*20TF[455I`BU)4D4]ML=-%<R8-`."*)42S%?KQ:U$^:NE2:%
M9!8-GMR'A>AF\85::/$4^:F!>=Y2<LQ?GE%A@4O"PHK]\(X2EBE!`$LZ*#1Z
M@>A'%W9V?J,>`_)!2&32X?W).5Y$3J'Q\]]KQ9C09;'\7WZG8$WQ?\OXO\4\
M<Y]_IOEE6FDEW:%BNXB``);E515E(RE;!+2_>>H_=?6G)T_/GM;7C7N_JRJ7
MQ_7*>1W:8+QA#!3!RAL_&?`_BT7\BORL3.^OR/@A7?<`NH.G5P]EC'O:/=%/
MB%IA'P/?5XE^3.K])A(0^6D:9D["D>RKFAR%2C2!B.EZ=OM::L0[/26K9LCV
M(L<]BK)/W_W96)7Q\^\/X[?=A=__Q<)4_._N]E+_NY#G,^0_GKN#9\'+RB-L
M\Q`X[C9R\TJJX63E;M_OP>&%VQ+^;W>[NJR7ZCI9-5WV^+8[=OHF7_+.T@,X
MU?9;3^N?YAD__YB2]<M'`#[J_[<]%?^W72@NS_\BGL\X_W#WN<Q%,+$3#X,4
M^#=;@`-&*L!9!)EVO!4NC^(?^AD___17N]FDD;M0_U]K-S]E_RT4E_%_"WGF
M/O^5?Y1?OJS4C@X;(E1V'I9`[J<15Y!KL-!"E`VXYC+NL-B[IK2U49?8_23T
M@;8XP"<,\?L,D]X)0A_;$A_Q8\E+14].TLW:,K/%//<6ANUQPZTPQI*!S53$
MKK*2'>-,T#Q9$,"-V7<6F?HAVP7@V@U#]NE:.Y$N9$3F$8['>U!!-O(BKO5D
MGH@T]3Y,YTW^[OGNI#_ALP^KZ^M9Y%29J$RUM4P_W!AHCUD#<R*D,@A9A-X6
MID+XR)!0N8M<&Y:/H@J%,1UCSF!48\.27^IDK!X;718<_\QXBZ=/ZB<L)DYD
M5,I\X'0]M4D^,B`^GNQ;DF4;4WHFC-@K#[Q,T1P9C">;\]4?<]!Z'<BPO@DH
M)/8P^#4[=H?M](!9EXG0DOU_>U>ZU$:RI7^CITA+<H-LES8P=N.+VYC%)IIM
M$-SN#LM#%ZJ2T$6J4E=)+!?4SS(O,C$1\T+S"G.6S*RLTH8PX-LW5.$PJLK,
MD_O)DYGG?.=[WQ/&^;_CUWIH2ONP-X"3SW^2^(]+2S/_?T_SW%W^6S_S_="5
M^H^HP"?:]G7DHR<0E<-UL=$,\L+0%-_?V_F-CTD]V.GA(2QJ*.13F?BY,0/`
ML>J#XUX(5"6!__1I,IW',DLA91&%$P<K`LU46@B2A]%XB%1Q@0T[S7I=;@ZY
MX'B2NY+*4(#\#H6W\"YK:^WCX?:Z.-S<W?_[IK6_L[%Y:!U]7ML#6DI=,9Y0
M*2P*&]83J.CR[E]*XHW/_^AX^B'SF#3_RV\&YG^I/)O_3_+<:_^'@H++ER].
MK],"08W0";1O!+X((1&PG4<?7\`);,$PC-%2*0<;7=3PS0E""'`8T^*;%+Q#
M$;^*#?LZ3,52?N^V^W=X\H\+_4S/^/E?+K\96/]+Y:79_'^2)X;_G"+`DI`W
M9DT$2$/##@>W-3@U7Y`#5KO6;5ZX+PA2!79O;JM%WMKIFJ;7>04T0/!M]1S<
M^9"EJ-WIV`$(E;"7,PBHI&$/P63@;XWA8X):!TB0*4'-]N81*`,V'`1$XET+
M]OJ>%Z+B"P0(@>2!O-1U?#?$^$XS[+3L:V0[GO0FZ..&Q1%=!F.YQ)W/&8):
M>^)9"F^:*IM'QP?/T.\%;-^Z&I)%-4/-[S21OZG]H\1OP08(:D+C.D-Z=9'5
M:'8OW=,\1\S[0:.`\"X%^0ZAA6[@N@4H@\7-0!U08.,(IHOE.D)3.0)]\0:;
M#AKAB*ZD"9"&Y"JZJ@:)1U4<2)`W9*H-PXXPBK=NZE?TH]F=#TT[#F3(]0#]
M,LMZ<;,3QHIN5$)?08D0-</#?"K"R+9@:R9N;\4S"<6+'Q0T[A\BW4PK#21H
M>:P)U\"SC"KFQ4>7L4X\__)92N)Q2RW5(U@0S@E4I]5LG'6=]BL&+*([>?L4
M5Q*B>"D04N>*P"CL+@+Z(`10S284(0+7@6%WQBW0\/R`'$]>`QV_66/4(QKC
M5MXRNK;G-:_R,-AKY^X5@^Z0WL(?/>@K5#\HO(;MS.L?"Y=GUQ8.24N6T>+)
M9+6O8;OK8T];"'%D01OV&F?XN>4WFAZ/!ZL96O\D3&:5[6FO$>9;=L^KG75L
M)^^YW4*/E.T++YEP0>93>`E1"Z6EY;=O%\O#(-T44`PKP"(BFH_3!M%'*]N?
M?MG>6_],8#=X-@"KKSR\(.0=QMM!Q>A&@&(YKNV;O`&FQK]L>H26'/H\@:GY
M:+I%^A+0Q;!QMEOL'.82QT$&>P-H$HR0M'Z#T9U9?KU<7I1M`$U0\T(T"H(_
M^=IET,N[3J_P)Q#N\N396OL/L;!9*N52X1F=/82Q0F%U-YHA%]9'09[T-K``
MT@H`1KA@1]186<(J@5(T\S`8/S=Y\'?M4^(KCKBTFSP=@&-@`!J[ZQ$#(].]
MZF`TFP&IL@@OFX\*YODG1/^DUG9.HM*DHO:$&4MJB,2F')YO81?/1X`<C/``
M,:?8Q`\J@%#6\(*-5EK\<;GX8Y05$F(BQ.ELF!RD*0BYMK&$\MA>Y4?<#-@Q
ML01IXNL@W=>E-XM+9;5"X,@6;0(#0"]=J':#`XAF,`AG%\"+J&"HM(ZE;-F(
MU.E[KQA(ZPP=NT,;7L?R1N"!UB6Z&&2I$#4'(.O/4;!'RN(>KDEV+?!A6*)_
M(M054*7@Z?2.QQ]YE4=00)6#Y?U.1<]'@X%6-\>MV[T6K!T].LJ!,5AS`P]1
MGEHDVG:5.01\J?ED]D;5(U!C'+]09`]E5:>'J#>O<,7!DH6&YE"]99]?BP72
M2]_;JN2@9NL^'JC1RLC^S1NT]$4M(I>J%ML]$FO`"0E#1R!J5HN[J:[<>*<R
M!X?[NP=')^O[N[MK>QNK\[KB]CQV_SHQ+"(&T\)!4(=FE]5'?]4S,V1;G^S-
MT>;A;I_,>[[8F^=77S'"B]O@ZJ+[XA;X9=M]<7L.-8#U^<4M]7SS"FUZ#BJE
MU?GJEVIQ<?%K\5VU]Z%ZME*]K!:+;ZI?YU-DJ#/'MI8O$M'/H\B+B]5J%)TB
M]CQ<VR!ZRC3V$;C%K_DM/ZCW6A@*HPS:$_7PU4==,>QVIQE0`*J2T+FCOHGF
M!0'QYM`:^+37;'4M5`G61]?F%.R1RAGQUHWM0VCPG?W#"B[)T-@P6EC5#/$S
MV&4]6\MDX$\0T@+;1>'%=BZ@]_$,FB@B6IOC-&D9P:+^0N!H1HE9.QEJ)\<I
MEM4`?N/S]&N@>(4\"L>28K9T#MNQ&;,ZGX*\3HBF/,H'?D_GLM:!D9MAU1HM
MV(K=<Q3D>"T8[M`,4/<#D!J@#G\6\D#D1$;)@.3_]L?4W$Y%-M*J`OVTZHFH
M7[^*R+7&!92:3\A5=YW&H[,/#4TJT163B242&"XYAD7/L2TOM,">WW57L&\D
MK\+8/;O+_:UKJ<QF&<>0F`7-58B$1"3#@4;;KC/>'*[!D.85V[K\W@I_Y]E/
MHYF*@>MEQ*O8IHKP`67/V]UNT#PE2`8MTO`(])@W+E!9&-NQW8$D#A+!(<XD
M"8Q05QH85.;UV\6WI27=8>B:6-=PY244MQ]KYVA8$0JL:D\TE4,$&*IH72XM
MN/SIA::'9FJAE#!(\@_=O)[R.DOJ`G4%0RAYRDAMP<W#ZO>QLB%^`-*GKN.X
M3@X%2-Q`7'?D55(-DR`J(76![ET05RY=+4"?V8%#\(6T>=&\`\N&?!R*=0_V
MR/SN%A:6L/SZ]@5EG!/Q]D)&1TQ-WGMD;W1X7[<Q]T3V9O-X>Z./%E+%6`\`
M_WNIN.F78NG=8JE=_5H],SXLP0=1O135K/I8Q"_SNK<&2)21!#+F.U&1F`*5
MC<P'Z>1G?6>;N@]MSS*?]HXS'^Q6$WJ^%:[.H_\,BYL`;_T@/8?A9F%UGK<,
M%-Y+1'`YACLF2IVCU(=%X;I.:,P,7DY>DNG#!Y["EZX<4V<H1_'PB9H,VX@;
M9;`YXV'R<HLV8V=TQ8;,B,18WOWEG<(+@9`G,+A@X@50R/",)ML//\AM.7`H
M_):62/\9M?2<(]J!`8L*FZ!6JT?"+JI!OA*;![C-1>&D!\L,3S$]T@1M#"J2
M>=$4D+-D)9<*7`>JXGXIXKB:3QUN;M!KB5]/6SU7!2_!^\>=XTT5CN^U:]M3
MX<OPOO[;VIX*Q_>]=0YMSPODLB`=0;Y0&`-Z5N)O*IR9E(%E((,,A_(6-1&6
MHF]9EO!_53BW=,$LXT-(]F9OO8]()(GQ\"PY'C15/B21A1#M7D@W>KA6VVR_
ME`?N%`37SR)74G)B:!(;4B-5.;@-5T2UEM9>(/Z@/M<`HL+:EYJFAJ6,#LV-
M2I9O.Z_')\48N5BQ/#=MEG-WXS5(C>@<HM>6191FF@N0%#Z.*U?RRKJ$EJ\"
M@?X7(K]50U-2R8>F'N)]2W;R_L_4DUC\N=I9VW?$RZOQK38G.51VP96.Q`=`
M8E?S+[+SXZCDS)*LU<C'Z2';QZ]4N]F($E1GS[TTPP8RHZ++YC6^"@LV`.DA
MT8W&&#KDCW&,TP%8-/;5@,>A.4?UBL!G\=-H#/BY.6U`'BL<PK9/6;C?_!ZS
M4&G63$*)YU[B>1?LKE!<R0/#B0JJ"6RS*0?MHNB<2I;>`*C6*,<X(<?T7'ID
MC1I3-/=O>/79;@:!3\<&?LNAW=^UJF&;/4C;=&#"8-3&F%"L?\CY#!>/UA"S
M_8#I]EGTZ0:TF7,I:[^&.O'."C49;(YI'"J<AB]&];Z^(CSG*&B@GE\Q9Y1U
M3:C]*'.0?\7^S\]4WY!GN1B3QO5D&(?&[\R>QQU*/3H3GI-(%B5&KIASW-->
M(Q=KY2._T6CAO&%\G:XO.9^<G`K&!P9^T1P3R9;BO9(3C>(YB2-&Z5>+\F\)
M':&.:A"E':T;",FT+^(?1S?G7#2&!B:A.@`95;Z2+N>CE@^[!/?S"$E`TRBG
M&YKPG<KIX6VL9!2Y0F(G<;-GRXD:I<-;/>M7);";P0>&!)9SMXWTD_:)H3-A
MB^/#G72R:>QF:]J&6=O>F=`LV@F&KKG^DAL2^"3-,M2+W4`3;9+.\9J#QVW)
MMGH1G\U[>*`70,2.SR>IY^XUVMNQ"M8*X9:9\:O=`S\D_'_$D%D1Q"!>*1Z/
M6VMV2RZSHRT;L$"#TS7NPND,J4$U-,@$^G?:B*#1TB""_FU&H(E:[4(P_3*#
MI"=53AR]F%'T^&=YA7^G99V&^%?]RSM"?;C-DEUW3W#?#T.B6SL[:9V%2%R=
MR;5MAXYLH!G1&\3__E<$,`;+=Z]>IW7S`N%6851#Z_"F)#7L8]S!K<*N:;,\
MW5Q^NQQ3\-P]^NU@<S5]!9]3D9"32`6A)\M+P]+9;0<">+F,M@(2'!%/"F'6
M4%2M<TH<2>(;VITN3H'APCJ*?AJ:*0:AE!=K,<5?*=GAC&58&PV?1/ZZ9"["
MTC'IS-:Q4.#RNDV0?R!M[\I"K5*0*>,(0DG91A5K;_]H:-'DP.9[++J21?59
M+I;CXO6*Z]6:;OA,8O[-2;":FH,WJ'-:89G>"P@?N(.%6U/GO1:W9Q[E%Z,_
M:IV[)<$QGI+R_-B8@S6/-%A);Y=N^,CUJZHS#GG\NKYQN+^K[HMP?(H&7GI&
M9]:BYH`([.=5$_1B;6",I*HG29./`+'>#5HOUZ6[$+D5N.J*Q2)D7?/1V`0R
MQ8X)7%(1)&U#[AAL;L:S7"2H1QD#?N&5&$YUZ2>6>-9"!-[(6)LY0XEXD%5'
M:,C(K[%*,+=WT(Q4N?,(M2:Z9*V(=B'W2YHR+F+Y(1'D;3;TD@FC0AXMR1LE
MDW;YDDF!F1CP0^Q6\P;_]%?BD9!T/#DJ><1*-"0UQHF4KN.5HH%?#UQ816$U
M,*LG3]N@W4[BD5;GQZ6?'YN3\M9EEAB?1%X8;3`;F7A\#NA]1UZU3,XGBCR8
M6XS0Z#RU9N6XO#A2/`^=<"3ML&9[+=L;3UM&BM&.$HZF?>8'7:T&.(Y^%#&>
M1XS`Z'P8>&1<!A`C3IF3C"$9DANJ260Y5H*T3CHOIRE?Z.-B1%?\ZF*55`OD
M,=+G[<H1^;I&O(HB)/K,J/DXWP4L/`NH88!W(%)A^D\&Q@EJ.52]TC6(S>2(
MF?!*FI$5R`^/AX#\4^D?YZ52TF-Z`,'6F,[_1ZF\6)[Y_WB*1_?_(ZJ!3M#_
M7GPSX/^C_'II9O_W)$],_U-!?Q+#8LZ"K`\/T_@>6AVWL=SS163QD$X=A&F!
M0+)#V$K*_>;6\=ZZ1(7,#OFZ`EL=PA?K=1H!R.H@TR6^R,V/VOV4&!O2`M&^
MU1D\EDTG4ELE%`B3'\NTZ^>#05&41Y[)C"'I[2W)DJ(T)+1LAO93WUYU*M5@
M+M-5WVV[`?I'MO0=ET,(Z);G7J)B"F.S6O;%J!;X)ZK%X+;BSI0>J/:E(;4O
MW;?V*!_<O88$%?5MM<`CCC;(`T8EU*?[U@&VENQSA_8V%_!JP18'M[EWKYFB
MD0B/D_O&JL,BPNBZ1MWUMRDK+_U.XBV%3-]LPUYM8H63VS>YL#7.47[*WGSH
M?V,=J1$1:EIEVG"[H>[;C"Q^=L'I"0MS'/``@A>8$*\?-1'W[93-`VG0(RBJ
M:]LH@;)B(AFV+;A,T6JB&GR7]O&Y(0T'A04Q%RI,UFMX:"!QFPE)V\!U1#C&
M"F%R.S[A;G_<W-H_W%S-+B0;(8U1TPS.';2%%8`D6RJ\H'?R$#,A#5=N'2OG
M.MAX"UG.2UCO198HY-)<$,]-#O7!6G]C7QO^:XT1;7JU_:85R5R/-(LPOLFA
M-GE],KXH.L8G.>VA)4;:&>=CT^1Q9(P)\M_2XIND_%\NO9GAOSS)$Y?__*#9
M('W1TVMQ8%_X+;'1;/40(*#2K-D=<81&(6Z0HL,C3+BB4)Y6R")W1:,FT,D6
MJYVB1M\\GLZZ4IN=]>Q0R`SL=IVU%26GY[G[\^;AW@G#R37.TT1I0VIHQ_'C
M*>+Z_MX6<#+D_AP:%OC@MYQ?QL0J:83MRU@&*GO4YT:#H4]$;?_O.VR2K#BC
M7L8L&1%I'J.R;HB7'&@9!/6U@R;#/7:U(N$IGV_BK4+3B_*+\OFXC7R(029Z
M#BS'(OIM.VWYUCZOAWGWJKLDW]UR/:R=RQ?\B8'EQ/MBXGU)%=IQZ]"#CH@6
M9SMHL,V_+-C:X2=";V_USE%;!()ZW-IF6TY*GKV)WOI`!2/C8%C-WNC.7;%Z
M'GK%]OJ$ZB>;1[7RJB+!'8)Q/-^"*,#BSZVV[_300I3@`/'L'PM7.=A9JWP6
M:XD2\6==+[0."\]6/80`M5LGRO4$;7[TZ&+;".I7-3#6=S=6-::9KC^>"4/:
M+;TQRJ12O1!64D,1+7V,'U:$J892S(F_?;%.;RV+Q*^OMU^L&KP0Q\:7#KRT
M@T[@=]S@ZWNZC&N<0V&[)ZWF:<C$6WX-IRJT`#;X![S:E9]64XS"?$IK^`U&
MZ;,V8:1[#9]1H3!:J5J.PQ^UQP*(N["WA2M;.:?<%Y3>$0:J$;:DPQ;?B?Z\
M7*G(>.M6A+C^6CU9?O+I+3O8;*!U%/G8R"4Q*]/CJRE_M;#"2NJ(CYO4G+H=
MLAR$C*3-K-60?]L"3Z8>(@USO?LDO&\Z&`BCNSG6QRA:Z`Q&4H>HB2SPFX3A
MYHP(#B:[8(Q$E6U.#:^)V;0&LJ&:<#9]GDZ[L,S`#Y2WS*%.!@BXVR8UJKH-
M:U-`(]'S#8Y$'AQ"4IQ])JPKG1M,8-48:LO.UB.]MAV>+\`0A^4))ES0A.U'
MZQKOK^"[0`OEE-8:NBGUI=Z0G+FWUBG>4(]C?L"WI("*/]6LE@H$2(A"IR.D
M)41)0E&]M=I34!DH"QO:(+LB[4AY[*$UTU-S\34BO&[#4GLN&;SVK:*X/*[,
M46]3_I!3@@^8HP%7Q+YB"A6T*$:F8&XNR=`NUJ/QZJDW@^GW\:X61Q8.)]F%
M?RF,CL=\\@5]IO>=Y/_2\G+Y=5+^G_E_?J)G//Z':2M,%]_RL"$Z!QZWP_:O
M>#N<DC_B*BPCM\P\^\GT@@S7F8:Y%8ZKTD-8)GN3";O!"<CLP#[:]M5)R_70
MLQ&5IK*:71!:ZR]9SLB]ZTJAZJ&NHY1:<KSF[>YO'$M?%C=,KB\=6;`RZ$V&
M8_1);S@K,R<E#J7%H4L413:DI*C`V86%B,!+41:Y7&K0F&'M`A8^TMG0:MU1
MA^!ZW.JY_06EX&NH_FI]ZM"^<,D;[AWJE\YR!-.GE*Z7C''#45:**\M]CI?%
M+&1D'5OF&X\>UUV,5/GF2*:L(W4T%.D_M[(WLFGZ6$NT)ND_#T75XUH)HZ3H
MTU.^"!Y?(I>.M;B1(2P,]SDF(E^=.$AI>.NWZ<<X+YFP%R&M,ZU9,F3$_Y65
M"6,1R!R,P^GGMW6"@<<7]84)TC=5E[BP[V-`6R*!V$;2OX,D9JC(#NDCF4N1
M%.S(CXV91V7_^'!]<S6]SG:!D?*C##!VB$@CE]#`0Y7?6QC9D+>T\$8+_S0=
MEC*%7-I0X64-3CXF;?D-V0YM8.$(=;'*1^*1]IX*B"D$0KJ&&PBKR^I3OMUN
MYC[L_YHVXRNM2I47M_WP[&#Z-KIGS.EN,BJP#]QN$;G='(B3$6N"2,W5XCO1
M_-MJEA/"[Y<O*2)Q*(X->PKXV[?2`[,;F0/QS"S&4.POR5!O%3O151(J9%22
MB!X:CAEUMUMNH)1_S;;GVC]=8V3NVQ@9I2Z>;(O,U&V!1_/<$O"K&Z[&='KC
M#98^9*S4%2%W^-Q`B1$%\T:!5OCG@IHM(BDLD:5\H$64XF`^S=J^)+O0/O1N
M-]CC;`[O=:E`/(DI\7V"\6'*JP15'E2@CG'8Y&6!J>2I^WZR)61:'Q*-M,&Y
MIQ%.M*%,E$Y./\,F<@76GQH/1$QY3ZO(;S6+-$M(0H@RCQPH>LQ,$LN>CCH4
M1RDKGK+%9.[[F4P.5,BTF;RKT>1#64T.-.*@]207TA!A)9N1"1+VE#+V0&F,
M*M[3N#(^D7!4XCS:]IK=YH"!Y9#I--30<JREY?U-+;_=UG*@7Z:UN90=,:;[
M#</.^QI@#G;)H"7FPQAB1O;APPRW5.Z/;),I\Z>MT0BKT(1A)L7%2_"1MIGW
M7\E"=/TV9[RI-6S<%N6N"UQ(@#[FIHA]"@]?XNZ\5'$CW7G!TLVH6CMA-FH:
MC@Y.&6U!JA:.I"'I)%/2.QB3/I@YZ916>L8LN)-1Z8.9E4Y=3CY(D%:!T(.$
MNG*W#J-]Z;`.4WO6;^PS10::0?_\U^TYHXA&P9^Z_PSSX#%VL(-]>S=+X2>T
M%7Z@;L,J).V&S0HEFT^9$-^O\<98$S^A/?%C-9UI3SRF#5\,L@]>>B>9&)LT
M#4MCR6V&&AP3NQJP.S8(R4+1S5R\3"!U]/=181O%BK!C7Z+*!YNYDF8$2T1D
MQR?/&U$RT!9_((CXC7Q2D`!)(O-___/?`S:L<\.-6.\E71"96JOIXLF`08VE
MC5&A]]I!AVS#R.0$DQLM8HRSN=4'W#&KVSN9W2:3*L-;*>A-,KTU;6]%S/A6
ME`WXOA%[P`<SQ?U&6]Q!@?8AK7%E)\;M<:<WR-4]-:5)[IUL<@=;X%&L<F53
M).UR'\LP=YQE+C`4MJNCHSG"OHP?S6'GI).L'>.I77+,='=\S,A"4!D"BZ0E
M\.!\F<(L^*&M@I_P_C=?8&]8_V+V?Z7ETLS^[RD>W?^\*!)'?6A%D$G^7Y8&
M_;\4BS/_OT_RC-?_,'6#4I%'7[7<2^DKXIPI[:]M82`R:C:&Z`!`V4!(EP#S
M\MUY-:^]!%R(^:+0WV&;#7)L)(;P)\-MC.?@,7?2*]RPJ^#TVL$1P^*YHM*U
MNSWR79%=0,@`%$ARI#PPI*)<9"@]52/W_1VW/="CY[^4X1]#"6S"_%]^LYB<
M_XOEF?^GIWDRST3$`%*93$9\W/RTO2>V][:/X+^M?1!N#@+_HND@1*E^Y&B!
MP$/WCUX3]IL6J6M2E"QIZY[40Y'%&=IU\2=&=X*+>`J_PS0GI*B0CU`C!TB!
M.IU&B**D0Z2E@IFH+!;%DG@="]3IBJ(DEIEBT+4V7&:!P/M6!)$HA!#7J'<L
M!C_#XD&#;NYM&,TI;6?86B9F,J-M:5*H-TMH6$E^K"8I'H^CV`G;]!/'AA;S
M3MIA`W;!>$J`'SN!WT`17GYF>''#&L7X6;&#AHMP\Q]AUW])3AC0X\TUN\%!
M93^\:6Z%I\1-Q6*^:+U^19LN1A+W+EP/MM`U`K%'H`_TEH([?Y@OC&_.[C4D
MZU9W3AA;$^W($891P^BN/7S%_A"D(X13@NAW%`Q_/I6*UY^/`;`G(IBR4K3U
M56-7[N]+]`'%]WB*\F`*WA_A+KNTDD[0453P3RH960`UU$!(=LD]2QHC+[(?
MB':>O"46H"UI"V%%VZC1%XR3-C4IZ"18,T_"7L<-D//Q`8M-A%>SI=1<0G."
M=WB,L8F5E;KY5-=T15%!.Y$+V,4B-EH@N8`:26E1Q0UPNIK.<C;5M.`?N',E
MS8$EK"[YF5*J137<R**>9V(@I.5$$;CG)!4EB&*'72R$5JCY^RY;,]"]^IB)
MEGLG%6Q4?MF%A:S\+5Z6Z"[[HLW63?)@$TCS3;RU58ANX_>VT``8Z5`YQD=>
MQ+CJH.(9J5MA*M8%4'6)G>L,#++T@DRDE1_GX)]N!QDHOPXDSG*=#'40[G#/
M9549G2^'&@5<-73%TB(6-ZJ[#*>/>C_.,/GQO3A(7.V*D*6Q9"XBMH7_#-R`
M_`<D$H8JV<#5:=@3BI)5,PX$'JL`:9$RU$^UFJ`<1=2IQ:3>7:(_]GP8L14^
M429UQ%[7Q^$MX=;F>!*XGD/1BSQ7_(ZRGXG/#USX.GB<)T]SA3QAQ!/0C#@'
M;HM^GQ9RVJM:-[@FSPC"]=#!#O(M9.N=IJ/=I+6;(3I%>47^L7TAS?C)N85H
MH#68+0^RN"#D8(Z\4$L_V:G,G,I86!V1/=C>("1'+8VW>Q`-Q'DT>P9FLYK]
M*5%87N:ZL()3&;FHK^"O]!*GLSZS0UA-V*,)-A)Z'6_;7@\/.X'-==&ZOAL"
M8\G,L9^=9UA3OSY0MNS&VN;N_IZQ!2([J,Q<1(34U-2;>`EB1HXLWOEPK)@O
MOL:W+T8<U$@I2Z:*[K":7L_%.&;_EO"#7A\R4M?O"\I/79,I#XXCAW288L0P
MD?*QQB\*."^=S:1IRI<B3C/`WZ5Y(_%06F$<Q3\54[\AKGV+37T+)9$ON/WJ
M*^9>II.TV"6[8*>".?@QEUR01!97Q3F*("G@<'CWCE+YG?&)_$XRC2S5I&0:
M[P43CL@<JT5T8,A`[X\=.+EH)%/L&_C_N>B+3#3>8%Q#23HMM"^V81Y"RY-K
M!L31>X4:)\V.P`-5OIXVNE]S7>RPL%>KZ2&P2Q-I#YV<P"14;NH7H&P@L4#&
M#(V.U2IJ]%!-N<3._8POY41>L<$1S\L!1OE*V"UVTQ4U!]OLY76^I<%\%Q.Y
M7-H!%GM8+N@F3-8J(KG(;')<4NX[(<V2#;E#"634PW@'>)<Y$+&KJ:9!Y-MJ
M,!//O>JX-7*VR]^UWA5[`!*G/:RQ;,*[[/_T_O_[X7^]+I?*2?NOI>7B;/__
M%$\<_T%>LR7PO^AR0SH])25`],%V?V]R:C)=F0Z3-O'EUJ;_S^E_=J&4&\`#
M3[JXDQLBO+UBCW/9F^/*YF'_0_;F\W[E")$&GC_/O^BO9&\.?MDH,&SBGWWT
M1Y>>'Z!.,YP?E@6G+<#)7;-'#W?#"\"S/^FC[=_7U9U`9`KV'4G8(SP6&RW_
M]#3A^%+G0<?$#,^03VD4[E4>987"E__\LF*WO%Y[Y>O7PD]]:%:0\VQ4U_VG
M*S!*2N-UXW9PF#,Z(4W%C8AH@"9?^MF%OR6]T8WT0S>6RJ`;NB]T(&!&$UR:
MJAXL,8HQ1W6)CLXAM>Q\U9N/T8,MV@OZFL;&($]2J@W[+V21$\[<1GDD4T6Z
MOVO`Y`R8Z!TPF4`]Y+=OK,O`0><"=W$@.$U^R>X<2*P.G**:CO`_EDQH^,D<
MY]GMET&?;%%EA[A72)*=RMM;DEAF.G)?JK]S$U2S/ZDML!3R^)P+_8$!B=5J
MCAV#2>R1**P$80O2:=@[:-OJ[TAZ5#'-MA_C@RX>9;0KNEA[3M67=_0L-[RO
MV)7<+^Q*[@Y]&W,]9S0%:R[\A<`]QV-SC@'G+`^J=44Z2QI)[5\&OS-1LJ$X
M<(]3^H?`WXQ?#D\H/&L*]O]=;E/_>H_>_TF<>0OZYJGU/Y:+R\G[WS>+L_W?
MDSS3Z']DR'CF'_ZIH,%"MW4B#^-'U.S:F9M"['N-#RI14`E&CX)1F:)@![4S
M\HL^#!I5L06&K41J"CCT'L0DH'XV*A0JB&0U53QLCYG@-+I\:#9)>V0=\^<R
MDDO[A/9(A=PTNR#^HJ9NE'O5HQ"[#D+VBE&.[ZQ)DB]HWPR/EL<$_)_%I6(I
MJ?_W>O'-;/X_Q1,[_]$P.44)BA,6XIB%A4)#Y%+2__!(NXNC[=W-RM':[D%D
M\?_;\_9SY_GGY[O/84N4"IQFO<[C3@H7._N?2.$!=J+PDT#AC$CYEM]0P`/I
M0R-QJ"#"[*Z$`LC1QC-;(C<Z93;S[-@!E!_U$6#B+:;%^_>"LL$<^\I5$U-,
MS6WM[VQL'C+X:"$"2,&*&B4J&),>?9+A!?/ZY_U?]O:ASFQ'_>;-&Y&-J.%E
M[N[/0`ECM,_1TP_>!T011/G]#R6,=;!V"*_(^-1-M0)COMG\=7WG>&-SXP1;
MB!'WC-A9_=NRW*M:JP>R-2(L"X4%`<25*3K5Q>+*Y$24$IO.+-0/[]\;;34B
MN65!*6MH\\P:>9;?<MS`ZI[9'KIJ&TTO-8=\<"OB\'=M\!RG_#QM2IGNZ"[I
ML"_V-G_9V:X<;>]]@A2X46R=V7<N).:VNW^\A[FQRKW4;XP(Z$[OF8/01&4A
M`J:8S133%!^MWNF=S(,C`)HHY?Y`TOUDVOUAB8\'4Q\/)#\>G9Z'>BQS'OQ&
MYO0A2DRN<]($#-[UNW8+XU!G53WZB$VKOGV6W^KV:="LJ:];.`V!]U36/FTB
M/*'`4581VWNQ(6A952\;=6S5JWH0%=.3AE:%(^"[#&(!P0BC:F</-[:WMDI0
M`?Y5WE<A^ZIA=!6SS!MBGK5-/E9O>LWPS'7RT!H)]C0W5$B1;1H33HS!AZS/
MG*)I`NGBAHF<]J8FL>`AW/?C-(Q7^GR\"]>%CT-Y[O")9:XKN=@:5<KELWK]
MR4,I\Z?_+*>'\]YI,Y*3=>YHC0C1PHG"0_:&*9VPG3J";-;^48<Q)RN%K1+C
M>[E)C.]>/.\>[&XZ3G>')GH,CG=_AO=-_&XJ=H=#PDA+(R0-8P.3X<N=6.3W
MY9!3SX:'XJ/8/L,99XQ?1@RLZGU\/+8YCF$&Z"1FHMP:19*<<V=__6>.11O8
MH.<98K-EQN\TT:\+B%@M8&4+7;3CLP@"49'HIPEH6;#R4*F(+QKD*YL5[^.1
MM<QL%'QJUBW02Z04#_N#?'PZ<75:>;4;V!V11FCONC!K!N/LT^?C`_RSO7>$
M?^A:SW!0?%CY;6_]8*U2^67_<,,41"@`&;@69K%U<NC&Z`RK:R%@FX6WF*M1
M16.-0$)R.>%%=B#']P,[),JH<VEELWDV#N6=PG*Q.#EJ1A;[3A7HV&&(]N=<
MB_&TIZDON5.>4-(X.*LY\AY%RD'ZD90SC,MP<TDM21Y)\4D2B4)-K^XKW,+8
MZL2K:(+UCE]3TVJY3L=X\]W7[K26$IB"7Q<ZY@HO"C#9MM8^'FZOLR8S+-N3
MR?(\E(1Y49A""N'L<CK[W?V]H\]WSUVEE\S@VTI1R'+N0X[_"+Z40JFDS"1C
MN>&:E([KXUK.';=V)J*G2=/H)B,I]]7DSAJY9YVBL49N1LU^XZ+0AFC*HB2Z
M[R&*5)!;LY&]R,%<<.G[*=&140CY:![-+R0?XEG>0W])Y)6#?^5RS#^&)"!`
M?&(F4J`YDG\_2\F&A:PPDGA(SHI)N'W%8^1%RU`VHX1#Q=CK3J_CAKG$>$N>
ML4^:+\BXUTF(+JK.WY:(SPN<`^(C`ENT_IA,2W7]NA3S%[+T2]I!('^E?8_J
MDLAZH"16_Q3_:?WTI6C]^/5E-F860!@'Z4EYIX6%`!@""MHF/P`O@2A(#FY-
M0+8W?5%E0)3IJ#DP\ECB0G@\L;.]MTFHU5Q-\WH?FXM)8Z2H-)"^!ONEG+SU
M?V>F4S5,7LT';=R%*DH@*FBS`=P?F2D8@4:.?`9P&'(U,GD,J!O<$8OLQ%DC
MQ^W(2:+&-4\3`JN0MR0.KGOKO&L+C>L1N2=1]R-A=#\B0^0%"=\:2UG+\^O-
MKBIF(NLMA+H6::D2JY!(>(@_4YNHQ*S\W@?PW_G)ZV/[Q\MCPOUO^?6;I/\'
M"%V:W?\\Q6/>_Z0RC.#"\.>V0V!8"I<]0N\BK24RV$4>@*DNS]P`]9<(;/,<
M=Z9$!W5+Y2Y!48DPXU=C_LM3*9V[G-,T2SL^R`(JK>9PJX6VUY6'DP6=C@HM
M/7>I)`92^JHVV,*(5W%++<X^)&-BNM7V>UUTUG[J:M7:G\1"L5#*&3#U$A$/
M4S9<SPWP:(2@NU3J6`()>IABBU:%ZH6+L=2"B0A+@+FS;K<3KA20G^=K9P7B
MJ":&+&KX^F3K4(L4L16&J-=KG[J!050A\Y;>%-^^+2__N+2<(C5?J5![80=A
MBH\PY#$%;`K-;1X(-`;CC`Q8DX<5PXXXHM.-H:<7I+^F#S#&$V`%OHPR>T`4
M).Y].FV4IQ8RCGMEMR%>N"+?][8JZDA0'4]:7>'50U'ZL9PO+;_-E_*EE4+'
M[IX5NKX<8(-'ETR,Q5)]Q)B6G__^<?]74=F"W_&<\F@.%=;%.*(1+1`6>P.M
M/:+FO:FK+E-,4['C^"L>`XSO)MQ3#_A@T(+4*`<)`_X1M&JC#HI?2*<'3:/O
MYR<!]3'5W#$\TR$U`]M9@4V;7E6`9@03*;_=FEN9L!O445Q=2#^OI5_A%05L
M;7+IF>PQ>V;/[)D]LV?VS)[9,WMFS^R9/;-G]LR>V3-[9L_LF3VS9_;,GL=Y
*_A_OUJXN`&@!````
`
end

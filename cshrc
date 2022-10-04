############################################################################
#   Default MMIL cshrc file
#   Created 2010-04-30 tcooper
#   Master Copy Stored at /usr/pubsw/scripts/cshrc
############################################################################

############################################################################
### Default software/script locations
setenv PUBSW /usr/pubsw        ### Override the default pubsw location for
                               ### ALL shells here *NOT RECOMMENDED*
setenv PUBSH /usr/pubsw

############################################################################
### Default path additions
set addpathlist = ( \
~/bin \
./ \
)
foreach dir ( $addpathlist )
  if ("$path" !~ *$dir*) set path = ($dir $path)
end
unset addpathlist dir


############################################################################
### common shell variables
set system=`hostname`       # name of this system.
set cpu=`uname -m`
set release="CentOS Linux release 7.9.2009 (Core)"
limit coredumpsize 0
set prompt = "${USER}@${system} %c[\!] "
set history = 200
set ignoreeof
set savehist = (1000 merge)


############################################################################
### common aliases
alias h 'history'
alias ncs 'nedit ~/.cshrc &'
alias cs 'source ~/.cshrc'
alias gterm 'gnome-terminal &'
alias gt3 'gterm; gterm; gterm'
alias smc 'ssh -Y mmilcluster'
alias smc2 'ssh -Y mmilcluster2'
alias smc3 'ssh -Y mmilcluster3'
alias smc4 'ssh -Y mmilcluster4'
alias smc5 'ssh -Y mmilcluster5'
alias cl 'clear'
alias fixvid '/bin/chmod a+rw /dev/nvidia*'
alias countfiles 'du -a \!:1 | cut -d/ -f2 | sort | uniq -c | sort -nr'
alias qlogin12 'qlogin -hard -l 'h_vmem=12G''
#alias code '/usr/pubsw/packages/VSCode-linux-x64/Code'
alias R '/usr/pubsw/packages/R/R-3.3.3/bin/R'
alias RStudio '/usr/pubsw/packages/RStudio/bin/RStudio'
alias ocalc "localc"
setenv RSTUDIO_WHICH_R /usr/bin/R
alias open "xdg-open"

############################################################################
### custom aliases
if ( -e ~/.alias ) then
  source ~/.alias
endif


############################################################################
### Setup standard software environment.
### Override by setting $PUBSH to point somewhere else or specify path to
### specific setup file.
source $PUBSH/bin/SetUpFreeSurfer.csh 711
source $PUBSH/bin/SetUpMatlab.csh  R2021b
source $PUBSH/bin/SetUpAFNI.csh
source $PUBSW/bin/SetUpFSL.csh 6.0.5.2-ubuntu
source $PUBSH/bin/SetUpMMPS.csh 254

############################################################################
### Remove duplicates from path WITHOUT reording
set path=`echo $path | awk '{for(i=1;i<=NF;i++){if(!($i in a)){a[$i];printf s$i;s=" "}}}'`


############################################################################
### Set the default umask for file permissions 
umask 022


############################################################################
### Setup Perl for local packages
#setenv PERL_LOCAL_LIB_ROOT "/home/hbartsch/perl5"
#setenv PERL_MB_OPT "--install_base /home/hbartsch/perl5"
#setenv PERL_MM_OPT "INSTALL_BASE=/home/hbartsch/perl5"
#setenv PERL5LIB "/home/hbartsch/perl5/lib/perl5/x86_64-linux-thread-multi:/home/hbartsch/perl5/lib/perl5"
#setenv PATH ${HOME}/perl5/bin:${PATH}:${HOME}/bin
#setenv MANPATH ${MANPATH}:${HOME}/perl5/man

setenv PATH ${PATH}:${HOME}/bin:/sbin/

setenv GPG_TTY `tty`

#setenv GOROOT ${HOME}/src/go
setenv GOPATH ${HOME}/src/go

setenv MATLAB_JAVA /usr/pubsw/packages/matlab/R2021b/sys/java/jre/glnxa64/jre/

setenv DTITK_ROOT /usr/pubsw/packages/dtitk/dtitk-2.3.1-Linux-x86_64
setenv PATH ${PATH}:${DTITK_ROOT}/bin:${DTITK_ROOT}/utilities:${DTITK_ROOT}/scripts:${GOPATH}/bin

setenv DISPLAY :1.0

# start fake X server in the background
/etc/init.d/xfstt start
/usr/bin/Xvfb :1 -screen 0 1024x768x16 >& /tmp/Xvfb_logfile.log &

#!/bin/bash

role=""
if [ `whoami` != "root" ] ; then
    role=sudo
fi

function installCommandLineDeveloperToolsOnMacOSX() {
    which git >& /dev/null
    if [ $? -eq 0 ] ; then
        echo "CommandLineDeveloperTools already installed!"
    else
        xcode-select --install
    fi
}

# 配置Brew的环境变量
function configBrewEnv() {
    echo "# -----------------------------------------------" >> ~/.bashrc
    echo "export PATH=${HOME}/.linuxbrew/bin:\$PATH" >> ~/.bashrc
    echo "export MANPATH=${HOME}/.linuxbrew/share/man:\$MANPATH" >> ~/.bashrc
    echo "export INFOPATH=${HOME}/.linuxbrew/share/info:\$INFOPATH" >> ~/.bashrc
    source ~/.bashrc
}

# 在Mac OSX上安装HomeBrew
function installBrewOnMacOSX() {
    which brew >& /dev/null
    if [ $? -eq 0 ] ; then
        echo "brew already installed!"
    else
        echo -e "\n" | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && configBrewEnv && brew update
    fi
}

# Mac OSX上用HomeBrew安装软件
# $1是要安装的软件包名称
# $2是这个软件包中的一个可执行文件，可以为空
function installByBrewOnMacOSX() {
    if [ -z "$2" ] ; then
        brew install "$1"
        return 0
    fi

    which "$2"  >& /dev/null
    if [ $? -eq 0 ] ; then
        echo "$1 already installed!"
    else
        brew install "$1"
    fi
}

# 在Ubuntu上用apt-get安装软件
# $1是要安装的软件包名称
# $2是这个软件包中的一个可执行文件，可以为空
function installByAptOnUbuntu() {
    if [ -z "$2" ] ; then
        $role apt-get install -y "$1"
        return 0
    fi

    which "$2" >& /dev/null
    if [ $? -eq 0 ] ; then
        echo "$1 already installed!"
    else
        $role apt-get install -y "$1"
    fi
}

# 在CentOS上用yum安装软件
# $1是要安装的软件包名称
# $2是这个软件包中的一个可执行文件，可以为空
function installByYumOnCentOS() {
    if [ -z "$2" ] ; then
        $role yum install -y "$1"
        return 0
    fi

    which "$2" >& /dev/null
    if [ $? -eq 0 ] ; then
        echo "$1 already installed!"
    else
        $role yum install -y "$1"
    fi
}

# $1是要安装到的目录
function installBashCompletionExt() {
    cd "$1"
    curl -L -O https://raw.github.com/git/git/master/contrib/completion/git-completion.bash
    cd -
}

function main() {
    osType=`uname -s`
    echo "osType=$osType"

    if [ $osType = "Darwin" ] ; then
        installCommandLineDeveloperToolsOnMacOSX
        installBrewOnMacOSX
        installByBrewOnMacOSX curl curl
        installByBrewOnMacOSX bash-completion 

        $role echo "[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion" >> /etc/profile && source /etc/profile

        installBashCompletionExt "/usr/local/etc/bash_completion.d"
    elif [ $osType = "Linux" ] ; then
        if [ -f '/etc/lsb-release' ] ; then
            installByAptOnUbuntu curl curl
            installByAptOnUbuntu bash-completion

            $role echo "[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion" >> /etc/profile && source /etc/profile

            installBashCompletionExt "/etc/bash_completion.d"
        elif [ -f '/etc/redhat-release' ] ; then
            installByYumOnCentOS curl curl
            installByYumOnCentOS bash-completion
            
            $role echo "[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion" >> /etc/profile && source /etc/profile

            installBashCompletionExt "/etc/bash_completion.d"
        fi
    fi
    
}

main

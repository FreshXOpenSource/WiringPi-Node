#!/bin/bash -x

check_make_ok() {
  if [ $? != 0 ]; then
    echo "failed."
    echo ""
    echo "================================================================================"
    if [ $2 == 1 ]; then
      echo "FATAL: Making $1 failed."
    else
      echo "Making $1 failed."
    fi
    echo "Please check install.log and fix any problems. If you're still stuck,"
    echo "then please open a new issue then post all the output and as many details as you can to"
    echo "  https://github.com/WiringPi/WiringPi-Node/issues"
    echo "================================================================================"
    echo ""
    if [ $2 == 1 ]; then
      exit 1
    fi
  fi
}

rm ./install.log 2>/dev/null 1>&2

echo $CC / $CXX
export CC
export CXX

echo -n "Making libWiringPi ... "
cd ./WiringPi/wiringPi/
make clean >> ../../install.log 2>&1
env CC=$CC CXX=$CXX make static >> ../../install.log 2>&1
check_make_ok "libWiringPi" 1
cd ../../
echo "done."

cd ./WiringPi/devLib/
echo -n "Making devLib ..."
make clean >> ../../install.log 2>&1
env CC=$CC CXX=$CXX make static >> ../../install.log 2>&1
check_make_ok "devLib" 0
cd ../../
echo "done."

cd ./WiringPi/gpio/
echo -n "Unistalling gpio utility ... "
make uninstall >> ../../install.log 2>&1
echo "done."

echo -n "Making gpio utility ... "
make clean >> ../../install.log 2>&1
env CC=$CC CXX=$CXX make >> ../../install.log 2>&1
check_make_ok "gpio utility" 0
echo "done."

echo -n "Installing gpio utility ... "
env CC=$CC CXX=$CXX make install >> ../../install.log 2>&1
check_make_ok "gpio utility" 0
cd ../../
echo "done."

echo -n "Making WiringPi-node ... "
env CC=$CC CXX=$CXX CXX.target=$CXX node-gyp rebuild --verbose 2>&1 | tee -a ./install.log
check_make_ok "WiringPi-node" 1
echo "done."

echo "Enjoy !"

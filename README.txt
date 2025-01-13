How to launch a container:

lxc launch ubuntu:24.04 cuda-container-01 --profile bridged
sudo lxc config device add cuda-container-01 allnvidia gpu vendorid=10de # verify vendor id here
sudo lxc exec cuda-container-01 -- su - root -c 'tmux new-session -A -s main'

In container:
sudo apt update

Install user space libraries (no kernel modules):

wget https://us.download.nvidia.com/XFree86/Linux-x86_64/565.57.01/NVIDIA-Linux-x86_64-565.57.01.run
sudo bash NVIDIA-Linux-x86_64-565.57.01.run --no-kernel-modules

Install CUDA (no driver!):
Install cuda with .run file to explicitly unselect the driver from being installed.
apt packages may pull in the driver as a dependency and or install mismatched user space libraries in the process!

wget https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/cuda_12.6.3_560.35.05_linux.run
sudo bash cuda_12.6.3_560.35.05_linux.run # make sure to unselect driver and kernel objects

Add /usr/local/cuda/bin to $PATH with method of choice.
Enjoy.

#Virtual Machines Preparation
##Run VirtualBox
Install Centos 6.5 or Ubuntu 10.13-server as two new VirtualBox.
For the scope of this tutorial call the virtual machines as follow:
* Ubuntu VM name: vagrant-ubuntu64-1310
* Centos VM name: vagrant-centos64-65

**Set up an initial user called 'user' with any password of your choice**
> The password for root must be 'vagrant'

Log in to each virtual machine.

Activate the Network
```bash
ifup eth0
```

Copy the 'vagrantme' script collection into the VM.
```bash
# may require the installation of the 'unzip' and 'wget' tools
cd /home/user/
wget https://github.com/marcomc/vagrantme/archive/master.zip
unzip master.zip
```

From the 'vagrantme' directory withing the virtual machine run:
```bash
sudo ./common_vm_settings.sh <choose_a_vm_hostname>
# <choose_a_vm_hostname> could be centos64-65 or ubuntu64-1013
```

At the stage the 'root' user will be assigned the password 'vagrant'
> log out from the user 'user' and log in as root and delete the user 'user':
```bash
userdel -f -r user
``` 

##Now restart the virtual machine
This will start the system with the most updated kernel for which we will build/install the VirtualBox Guests Additions.

Install the VirtualBox Guest Additions:
    1. Click on "VirtualBOX VM (menu) -> Devices -> Insert Guest Additions CD image"
    2. In the Guest command-line type
```bash
sudo mount /dev/cdrom/ /media/cdrom
sudo /media/cdrom/VBoxLinuxAdditions.run
```
>If the command fails you may need to run the command 'yum install -q -y kernel-devel-$(uname -r)'

##Now shutdown the virtual machine.
From the command-line of the host machine run:
```bash
vagrant package --base vagrant-ubuntu64-1310 -o ubuntu64.box
vagrant box add ubuntu64 ubuntu64.box

vagrant package --base vagrant-centos64-65 -o centos64.box
vagrant box add centos64 centos64.box
```
#Setup of the vagrant virtual machine
Create a folder to contain your vagrant VMs such as ~/vms/

##ubuntu64
Create a folder to contain your ubuntu64 vagrant virtual machine such as ~/vms/ubuntu64
Initialise the vagrant virtual machine:
```bqsh
mkdir ~/vms/ubuntu64
cd ~/vms/ubuntu64
vagrant init ubuntu64
```
Clone the 'vagrantme' scripts in the 'vagrant' folder that will be shared with between the host and the server:
```bash
cd ~/vms/centos64
git clone https://github.com/marcomc/vagrantme.git
```
###Vagrantfile for Ubuntu virtual machine
After initialising the folder tor the vagrant virtual machine, add the following lines to the 'Vagrantfile' configuration:
```
  # add the user 'barney' with password 'password' member of 'admin'
  config.vm.provision "shell" do |s|
    s.inline = "/vagrant/vagrantme/create_new_user.sh $1 $2 $3"
    s.args   = ["barney","password","admin"]
  end
```
##centos64
Create a folder to contain your ubuntu64 vagrant virtual machine such as ~/vms/centos64
Initialise the vagrant vm:
```bqsh
mkdir ~/vms/centos64
cd ~/vms/centos64
vagrant init centos64
```
Clone the 'vagrantme' scripts in the 'vagrant' folder that will be shared with between the host and the server:
```bash
cd ~/vms/centos64
git clone https://github.com/marcomc/vagrantme.git
```
###Vagrantfile for Centos virtual machine
After initialising the folder tor the vagrant virtual machine, add the following lines to the 'Vagrantfile' configuration:
```
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  config.vm.network :forwarded_port, guest: 443, host: 8443, auto_correct: true
  config.vm.network :forwarded_port, guest: 6081, host: 8081, auto_correct: true

  # Enable provisioning with Script stand alone.  Bash  manifests
  
  config.vm.provision "shell", path: "vagrantme/setup_centos_webserver.sh"

  # add the user 'barney' with password 'password' member of 'admin'
  config.vm.provision "shell" do |s|
    s.inline = "/vagrant/vagrantme/create_new_user.sh $1 $2 $3"
    s.args   = ["barney","password","admin"]
  end
```

###Testing the Centos webserver
The provisioning script for the centos64 runs some test with readable output to make sure that the requirements are met.

After the vm is up and running you can verify that all works as expected visiting the following url on a browser on you host machine:
* http://localhost:8080/multispace_test.html (or phpinfo.php)
* http://localhost:8081/multispace_test.html (or phpinfo.php)
* http://localhost:8443/multispace_test.html (or phpinfo.php)


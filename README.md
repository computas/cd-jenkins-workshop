# Jenkins Workshop Server Environment


The Vagrant and Puppet setup in this project installs and configures a virtual box environment for a Jenkins workshop. For instance, the environment can be used for a workshop about Continuous Delivery with Pipelines as Code.

The virtual box is provisioned with

* Jenkins
* Various Java JDKs
* Maven
* git
* Artifactory

Note that this project has only been tested on Windows, but is expected to work elsewhere too.

1. Download and install [Git](https://git-scm.com/download/).
2. Download and install [Vagrant](https://www.vagrantup.com/).
3. Donwload and install [VirtualBox](https://www.virtualbox.org/).
4. Clone this repo.
5. Have a look at the [Vagrantfile](https://github.com/mgfeller/cd-jenkins-workshop/blob/master/Vagrantfile) for up-to-date instructions and configuration.
6. Open a command line and navigate to the folder containing this repo.
7. Run `vagrant up` (this might take  while).
8. Run `vagrant ssh` to connect to the virtual box. This requires an SSH client. The (optional) Unix tools of the [Windows Git client](https://git-scm.com/download/win) include an SSH client. 
9. Open http://192.168.33.10:8080 (IP address configured in the Vagrantfile) in a web browser to get started with Jenkins.
10. Open http://192.168.33.10:8081/artifactory/ (IP address configured in the Vagrantfile) in a web browser to get started with Artifactory.

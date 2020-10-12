# dbautogen

Some shell scripts that are used to automatically create or update certain databases

## Installing dependencies

The provided scripts have the following dependencies:

- **zsh** via [github repository](https://github.com/zsh-users/zsh) or your package manager
- **pv** [command line tool](http://manpages.ubuntu.com/manpages/trusty/man1/pv.1.html) for monitoring live statistics of data flows through pipes Using `apt` you find this  command in the package with the same name 
-  **sqlite3** as a lightwight, serverless but blazing fast [database backend](https://sqlite.org/index.html) which is easy extensible by a wide range of plugins used in this repository.
- **GNU parallel** a  [tool](https://www.gnu.org/software/parallel/) to parallelize and speed up creation or updating of the databases
> **Important:** Please make sure you use `GNU parallel` and not the identically named command provided by the `moreutils` package
## Installation   

If you are using apt as package manager you can just execute the `install.sh` script doing:
```
git clone https://github.com/chriskipp/dbautogen.git
cd dbautogen
./install.sh
```
The script will install the availible packages via apt and provides th the functions `install_parallel` and `install_sqlite` to download and install the other dependencies from source. 


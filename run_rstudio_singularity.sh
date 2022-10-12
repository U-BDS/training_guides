#!/bin/bash

#-------------------------------------------------------------------
# Statement: U-BDS is not responsible for the misuse of this script
#-------------------------------------------------------------------

###################
### DEFINITIONS ###
###################

set -ueo pipefail
progname=`basename $0`
cwd=`pwd`

red=`tput setaf 9`
yellow=`tput setaf 11`
reset=`tput sgr0`
add_bind_params=""
max_path_length=75

function usage () {
    cat >&2 <<EOF

USAGE: ./$progname -s SINGULARITY_IMAGE -p PASSWORD -u SERVER_USER \
[-m SINGULARITY_MODULE] [-w PORT] [-b "DIR_BINDS"] [--server-data-dir] \
[-c RSTUDIO_USER_PREFERANCES]

A helper script to execute RStudio Singularity containers

options:
    -s (Required) The singularity image
    -p (Required) The password for your RStudio container
    -u (Required) The server username. Typically the same as $USER
    -m (Optional) The Singularity module to load (Default: Singularity/3.5.2-GCC-5.4.0-2.26)
    -w (Optional) The port number to RStudio container (Default: 8787)
    -b (Optional) Directory to bind. Can be specified multiple times to bind additional directories
    --server-data-dir (Optional) Use --server-data-dir param of rserver; \
typically available to rocker/rstudio tags > 4.0.0 (Default: false)
    -c (Optional) The rstudio user config absolute path (e.g.: rstudio-prefs.json)

EOF
}

function err_exit() {
    echo -e "${red}\n---ERROR:---\n$1" >&2
    usage
    exit 1
}


########################
### INPUT PARAMETERS ###
########################

SINGULARITY_IMAGE=""
PASSWORD=""
SERVER_USER=""
SINGULARITY_MODULE="Singularity/3.5.2-GCC-5.4.0-2.26"
PORT="8787"
BINDING_PATH=""
SERVER_DATA_DIR="false"
USER_CONFIG_PATH=""

while [[ $# -gt 0 ]]; do
    flag=$1
    
    case "${flag}" in
        -s) SINGULARITY_IMAGE=$2; shift;;
        -p) PASSWORD=$2; shift;;
        -u) SERVER_USER=$2; shift;;
        -m) SINGULARITY_MODULE=$2; shift;;
        -w) PORT=$2; shift;;
        -b) BINDING_PATH+="$2 "; shift;;
        --server-data-dir) SERVER_DATA_DIR="true";;
        -c) USER_CONFIG_PATH=$2; shift;;
        *) err_exit "Unknown option $1 ${reset}"
    esac

    shift
done

#######################
### VALIDATE INPUTS ###
#######################

# Singularity image check already performed by Singularity
# Lmod already checks for spelling etc. of module

### CHECK REQUIRED PARAMS
if [ -z "$SINGULARITY_IMAGE" ]; then
    err_exit "No argument supplied -s ; missing singularity image ${reset}"
elif [ -z "$PASSWORD" ]; then
    err_exit "No argument supplied -p ; missing password ${reset}"
elif [ -z "$SERVER_USER" ]; then
    err_exit "No argument supplied -u ; missing server username ${reset}"
fi

### CHECK cwd LENGTH
if [[ "$SERVER_DATA_DIR" == "true" ]]; then
    
    # Get the length of the path
    path_length=$(echo $cwd | awk '{print length}')
    
    if [[ $path_length -gt $max_path_length ]]; then
        err_exit "The length of the current path is too long; Please run this "`
                 `"in an upstream directory or a path with a shorter total "`
                 `"length (\$USER_SCRATCH for example) ${reset}"
    fi

fi

#########################################
### SETUP OF ADDITIONAL BINDING PATHS ###
#########################################

### --server-data-dir
if [ "$SERVER_DATA_DIR" == "true" ]; then
    mkdir -p singularity_tmp_dir
    add_bind_params+="--bind ${cwd}/singularity_tmp_dir "
    server_data_dir="--server-data-dir ${cwd}/singularity_tmp_dir"
else
    echo -e "--server-data-dir set to $SERVER_DATA_DIR, thus not mounting custom data directory for R server" #false
    server_data_dir=""
fi

### rstudio-prefs.json (-c)
if [ "$USER_CONFIG_PATH" != "" ]; then
    add_bind_params+="--bind ${USER_CONFIG_PATH}:/home/${SERVER_USER}/.config/rstudio/rstudio-prefs.json "
else
    echo -e "\nNo custom RStudio preferances provided. Defaulting to standard profile"
fi

### USER PROVIDED PATHS

for dir in $BINDING_PATH; do
    add_bind_params+="--bind $dir "
done

if [ "$add_bind_params" != "" ] ; 
then
    echo -e "\nWill append the following binding commands: $add_bind_params"
else
    echo -e "\nNo additional binding paths or directories provided"
fi

#################
### ENV SETUP ###
#################

module load $SINGULARITY_MODULE

#######################
### PRE-REQUIREMENTS ##
#######################
# All files, directories etc. below are to avoid specific Singularity errors identified
# For more details see troubleshooting tips at: 
# https://u-bds.github.io/training_guides/intro_to_docker_rstudio_part3.html#Troubleshooting_tips

mkdir -p run var-lib-rstudio-server rstudio_tmp

printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf

uuid > my_secure_cookie_key

#######################
### RUN SINGULARITY ###
#######################

# explicit export the $PASSWORD and $USER environment variable
# see issue #15
export SINGULARITYENV_PASSWORD=$PASSWORD
export SINGULARITYENV_USER=$SERVER_USER

# launch the container, bind all needed directories etc.
echo -e \
"${yellow} \n---- Initiating singularity exec ---- \
\n---- Go to http://localhost:${PORT} to visit your RStudio session ---- \
\n---- To stop the container, exit this script (e.g. ctrl+C)---- \n ${reset}"

#NOTE: add_bind_params should be first in binding commands
# in case user re-binds pwd/cwd, or path within pwd/cwd

singularity exec \
    --cleanenv \
    --containall \
    $add_bind_params \
    --bind run:/run,var-lib-rstudio-server:/var/lib/rstudio-server,database.conf:/etc/rstudio/database.conf,rstudio_tmp:/tmp \
    --bind $cwd/my_secure_cookie_key \
    $SINGULARITY_IMAGE \
    rserver \
    --auth-validate-users=0 \
    --auth-none=0  \
    --auth-pam-helper-path=pam-helper \
    --www-address=127.0.0.1 \
    --secure-cookie-key-file $cwd/my_secure_cookie_key \
    --server-user=$SERVER_USER \
    --www-port $PORT \
    $server_data_dir

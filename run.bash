#!/usr/bin/env bash

# Initialize environment variables
HBNB_ENV=''
HBNB_TYPE_STORAGE=''
HBNB_MYSQL_USER=''
HBNB_MYSQL_HOST=''
HBNB_MYSQL_DB=''
HBNB_MYSQL_PWD=''
APP_FILE=''
APP_ARGS=()

# Function to print usage and exit
print_usage_and_exit() {
    echo -e "\e[31mError:\e[0m No file or command provided"
    echo 'Usage: ./run.bash file|command [environment] [storage]'
    exit 1
}

# Get the application or command to run
if [[ $# -gt 0 ]]; then
    file="$1"
    if [ -x "$file" ]; then
        APP_FILE="$file"
        [[ "${APP_FILE:0:2}" != "./" ]] && APP_FILE="./$file"
    else
        APP_FILE=$(echo "$file" | cut -d ' ' -f 1)
        args_str=$(echo "$file" | cut -d ' ' -f 2-)
        read -r -a APP_ARGS <<< "$args_str"
    fi
else
    print_usage_and_exit
fi

# Get the application environment
if [[ $# -gt 1 ]]; then
    HBNB_ENV="$2"
else
    read -p 'Environment [dev]: ' -r HBNB_ENV
    HBNB_ENV=${HBNB_ENV:-dev}
fi

# Get the storage mechanism
if [[ $# -gt 2 ]]; then
    HBNB_TYPE_STORAGE="$3"
else
    read -p 'Storage Type [db]: ' -r HBNB_TYPE_STORAGE
    HBNB_TYPE_STORAGE=${HBNB_TYPE_STORAGE:-db}
fi

# Get database details if storage type is 'db'
if [[ "$HBNB_TYPE_STORAGE" == 'db' ]]; then
    read -p 'User [hbnb_dev]: ' -r HBNB_MYSQL_USER
    HBNB_MYSQL_USER=${HBNB_MYSQL_USER:-hbnb_dev}

    read -p 'Host [localhost]: ' -r HBNB_MYSQL_HOST
    HBNB_MYSQL_HOST=${HBNB_MYSQL_HOST:-localhost}

    read -p 'Database [hbnb_dev_db]: ' -r HBNB_MYSQL_DB
    HBNB_MYSQL_DB=${HBNB_MYSQL_DB:-hbnb_dev_db}

    read -sp 'Enter DB password: ' HBNB_MYSQL_PWD
    echo
fi

# Echo the command being run
echo -e "Running \e[34m[$APP_FILE]\e[0m"

# Run the application with the environment variables
env HBNB_MYSQL_USER="$HBNB_MYSQL_USER" \
    HBNB_MYSQL_HOST="$HBNB_MYSQL_HOST" \
    HBNB_MYSQL_DB="$HBNB_MYSQL_DB" \
    HBNB_ENV="$HBNB_ENV" \
    HBNB_TYPE_STORAGE="$HBNB_TYPE_STORAGE" \
    HBNB_MYSQL_PWD="$HBNB_MYSQL_PWD" \
    "$APP_FILE" "${APP_ARGS[@]}"


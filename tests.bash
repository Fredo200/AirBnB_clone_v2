#!/usr/bin/env bash

# Requirements
# pip install pycodestyle==2.7.0
# pip install pep8==1.7.0

# Function to run unit tests with different configurations
run_unit_tests() {
    local storage_type=$1
    echo -e "\e[104m Running Unit Tests [${storage_type}] \e[0m\e[33m"
    
    if [[ $storage_type == "FileStorage" ]]; then
        env HBNB_MYSQL_USER="" \
            HBNB_MYSQL_HOST="" \
            HBNB_MYSQL_DB="" \
            HBNB_ENV="test" \
            HBNB_TYPE_STORAGE="file" \
            HBNB_MYSQL_PWD="" \
            python3 -m unittest discover tests
    else
        env HBNB_MYSQL_USER="hbnb_test" \
            HBNB_MYSQL_HOST="localhost" \
            HBNB_MYSQL_DB="hbnb_test_db" \
            HBNB_ENV="test" \
            HBNB_TYPE_STORAGE="db" \
            HBNB_MYSQL_PWD="hbnb_test_pwd" \
            python3 -m unittest discover tests
    fi
    
    if [[ $? -ne 0 ]]; then
        echo -e "\e[0m\e[101m Unit Tests Failed [${storage_type}] \e[0m"
        exit 1
    fi
    
    echo -e "\e[0m"
}

# Run unit tests
run_unit_tests "FileStorage"
run_unit_tests "DBStorage"
echo -e "\e[100m\e[32m PASSED \e[0m"

# Function to run style checks
run_style_checks() {
    echo -e "\e[104m Running Style Checks \e[0m\e[31m"
    
    Src_Files=$(find . -type f -name '*.py' | tr '\n' ' ')
    
    pycodestyle $Src_Files
    if [[ $? -eq 0 ]]; then
        ~/.local/bin/pep8 $Src_Files
        if [[ $? -eq 0 ]]; then
            echo -e "\e[100m\e[32m PASSED \e[0m"
        else
            echo -e "\e[0m\e[101m PEP8 Checks Failed \e[0m"
            exit 1
        fi
    else
        echo -e "\e[0m\e[101m PyCodeStyle Checks Failed \e[0m"
        exit 1
    fi
    
    echo -e "\e[0m"
}

# Run style checks
run_style_checks


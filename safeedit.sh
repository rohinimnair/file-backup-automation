#!/bin/bash
LOG_FILE="backup_log.txt"
MAX_LOG_ENTRIES=5

backup_file() {
    local filename="$1"
    local backup="${filename%.*}.bak"

    if [[ -f "$filename" ]]; then
        cp "$filename" "$backup"

        # Check if log exceeds max entries and trim if necessary
        if [[ -f "$LOG_FILE" ]] && [[ $(wc -l < "$LOG_FILE") -ge "$MAX_LOG_ENTRIES" ]]; then
            tail -n $((MAX_LOG_ENTRIES - 1)) "$LOG_FILE" > "${LOG_FILE}.tmp"
            mv "${LOG_FILE}.tmp" "$LOG_FILE"
        fi

        # Add backup info to the log
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup created: $filename → $backup" >> "$LOG_FILE"

        # Open the file for editing
        vi "$filename"
        return 0
    else
        echo "Error: File '$filename' does not exist. No backup created."
        return 1
    fi
}

prompt_continue() {
    while true; do
        read -r -p "Do you want to continue? (yes/no): " choice
        case "$choice" in
            yes|y|Y|Yes|YES)
                return 0
                ;;
            no|n|N|No|NO)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid input. Please enter 'yes' or 'no'."
                ;;
        esac
    done
}

interactive_mode() {
    echo "==============================="
    echo " Welcome to SafeEdit (Bash)"
    echo "==============================="
    echo
    echo "This script safely edits a file by creating a .bak backup and logging the operation."
    echo

    while true; do
        read -r -p "What File Do You Wish to Edit? : " filename

        if [[ -z "$filename" ]]; then
            echo "Filename cannot be empty. Please try again."
            prompt_continue   # <-- added
            continue
        fi

        if [[ "$filename" =~ \  ]]; then
            echo "Error: Too many parameters entered. Please provide only one filename."
            prompt_continue   # <-- added
            continue
        fi

        if [[ ! "$filename" =~ \.(txt|sh)$ ]]; then
            echo "Invalid filename. Only .txt or .sh files are allowed. Please try again."
            prompt_continue   # <-- added
            continue
        fi

        if [[ -f "$filename" ]]; then
            backup_file "$filename"
            echo "File '$filename' edited successfully."
            prompt_continue   # <-- added
        else
            read -r -p "File '$filename' does not exist. Do you want to create it? (yes/no): " create_choice
            case "$create_choice" in
                yes|y|Y|Yes)
                    touch "$filename"
                    echo "File '$filename' created."
                    vi "$filename"
                    prompt_continue   # <-- added
                    ;;
                no|n|N|No)
                    echo "Creation aborted."
                    prompt_continue   # <-- added
                    ;;
                *)
                    echo "Invalid input. Please enter 'yes' or 'no'."
                    prompt_continue   # <-- added
                    ;;
            esac
        fi
    done
}

if [[ $# -gt 1 ]]; then
    echo "Error: Too many parameters entered. Please provide only one filename or run without arguments for interactive mode."
    exit 1
elif [[ $# -eq 1 ]]; then
    filename="$1"
    if [[ "$filename" =~ \.(txt|sh)$ ]]; then
        if [[ -f "$filename" ]]; then
            backup_file "$filename"
        else
            echo "File '$filename' does not exist."
	    read -r -p "Do you want to create it? (yes/no): " create_choice
            case "$create_choice" in
                yes|y|Y|Yes|YES)
                    touch "$filename"
                    echo "File '$filename' created."
                    vi "$filename"
		    ;;
                no|n|N|No|NO)
                    echo "Creation aborted."
                    ;;
                *)
                    echo "Invalid input. Please enter 'yes' or 'no'."
		    create_choice
                    ;;
            esac
        fi
    else
        echo "Invalid filename. Only .txt or .sh files are allowed."
    fi
else
    interactive_mode
fi

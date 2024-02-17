#!/bin/bash
# Function to display usage information and available options
function display_usage {
	echo "Usage: $0 [OPTIONS]"
	echo "options:"
	echo "  -c, --create  Create a new user account."
	echo "  -d, --delete  Delete an exisiting user account."
	echo "  -r, --reset   Reset password for an existing user account."
	echo "  -l, --list    List all user accounts on the system."
	echo "  -h, --help    Display this help and exit."
}

# Function to create a new user account
create_user() {
    read -p "Enter the new username: " username

    # Check if the user name already exists
    if id "$username" &>/dev/null; then
        echo "Error: The username '$username' already exists. Please choose a different username."
        return 1
    fi

    # Prompt for password (Note: you might want to use 'read -s' to hide the password input)
    read -p "Enter the password for $username: " password

    # Create the user account using sudo
    if sudo useradd -m -p "$password" "$username"; then
        echo "User account '$username' created successfully."
    else
        echo "Error: Failed to create user account '$username'."
        return 1
    fi
}



# Function to delete an existing user account
function delete_user {
    read -p "Enter the username to delete: " username

    # Check if the username exists
    if id "$username" &>/dev/null; then
        if sudo userdel -r "$username" 2>/dev/null; then # Redirect stderr to /dev/null
            echo "User account '$username' deleted Successfully."
        else
            echo "Error: Failed to delete user account '$username'."
            return 1
        fi
    else
        echo "Error: The username '$username' does not exist. Please enter a valid username."
        return 1
    fi
}


#function to reset the password for an existing user account
function reset_password {
	read -p "Enter the username to reset password: " username
	#check if the username exists
	if id "$username" &>/dev/null; then
		#prompt for password (Note: you might want to use 'read -s' to hide the password input)
		read -p "Enter the new password for $username: " password
		#set the new password
		echo "$username:$password" | chpasswd
		echo "password for user '$username' reset Successfully."
	else
		echo "Error: The username '$username' does not exists. please enter a valid username."
	fi
}
#function to list all user accounts on the system.
function list_users {
	echo "User account on the system:"
	cat /etc/passwd | awk -F: '{print "- " $1 " (UID: " $3 ")"}'

}

#check if no arguments are provided or if the -h or --help option is given

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
	display_usage
	exit 0
fi
#command-line argument parsing
while [ $# -gt 0 ]; do
	case "$1" in
		-c| --create)
			create_user
			;;
		-d| --delete)
			delete_user
			;;
		-r| --reset)
			reset_password
			;;
		-l| --list)
			list_users
			;;
		*)
			echo "Error: Invalid option "$1". Use "--help" to see available options."
			exit 1
			;;
		esac
		shift
done


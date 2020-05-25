touch users.txt
umask 0077
email_id_validation()
{
openssl prime -generate -bits 19 > .otp_registration
otp=`cat .otp_registration`
echo "Here is your OTP $otp" | mail -s "OTP Validation" email_id_register
read -p "Enter your OTP which we sent to your email address: " otp
if [ $otp_num -eq $otp ]
then
echo "Email ID successfully verified"
proceed_register
else
echo "Email ID verification failed"
fi
}
mfa_enable()
{
read -p "Your current MFA setting is disabled, please type yes to enable it: " mfa_response
        if [ $mfa_response == yes ] || [ $mfa_response == Yes ] || [ $mfa_response == Yes ]
        then
        openssl prime -generate -bits 19 > .otp-number
        otp=`cat .otp-number`
        echo "Here is your OTP $otp" | mail -s "OTP Validation" harish09457@gmail.com
        read -p "Enter your otp number: " otp_num
                if [ $otp_num -eq $otp ]
                then
                sed "s/Multi-Factor-Authentication: Disabled/Multi-Factor-Authentication: Enabled/g" account_info_$user_register.txt > account_info_$user_register.txt.tmp
                cat account_info_$user_register.txt.tmp > account_info_$user_register.txt
                echo "MFA Authentication is successfully enabled"
                else
                echo "You have entered the wrong OTP"
                fi
        fi       
}


mfa_disable()
{
read -p "Your current MFA setting is enabled, please type yes to disable it: " mfa_response
        if [ $mfa_response == yes ] || [ $mfa_response == Yes ] || [ $mfa_response == Yes ]
        then
        openssl prime -generate -bits 19 > .otp-number
        otp=`cat .otp-number`
        echo "Here is your OTP $otp" | mail -s "OTP Validation" hkodamunja@salesforce.com
        read -p "Enter your otp number: " otp_num
                if [ $otp_num -eq $otp ]
                then
                sed "s/Multi-Factor-Authentication: Enabled/Multi-Factor-Authentication: Disabled/g" account_info_$user_register.txt > account_info_$user_register.txt.tmp
                cat account_info_$user_register.txt.tmp > account_info_$user_register.txt
                echo "MFA Authentication is successfully enabled"
                else
                echo "You have entered the wrong OTP"
                fi
        fi       
}
proceed_register()
{
echo "dummy text" > .tmp_$user_register_dummy.txt
openssl enc -aes-256-cbc -in  .tmp_$user_register_dummy.txt -out dummy_$user_register.txt -k $re_pass
rm -rf .tmp_$user_register_dummy.txt
echo "$user_register:$email_id_register:dummy_$user_register.txt:account_info_$user_register.txt:All_password_info_$user_register.txt" >> users.txt
touch All_password_info_$user_register.txt.enc
openssl enc -aes-256-cbc -in All_password_info_$user_register.txt.enc -out All_password_info_$user_register.txt -k $re_pass
rm -rf All_password_info_$user_register.txt.enc
touch account_info_$user_register.txt.enc
openssl enc -aes-256-cbc -in account_info_$user_register.txt.enc -out account_info_$user_register.txt -k $re_pass
rm -rf account_info_$user_register.txt.enc
echo "Login ID: $user_register" > account_info_$user_register.txt
echo "Email Address: $email_id_register" >> account_info_$user_register.txt
echo "First Name: $first_name" >> account_info_$user_register.txt
echo "Last Name: $last_name" >> account_info_$user_register.txt
echo "Multi-Factor-Authentication: Disabled" >> account_info_$user_register.txt
echo "Registration is successful and quit"
}
password_check()
{
read -s -p "Enter your password:" pass
read -s -p "Re-Enter your password:" re_pass
if [ $pass != $re_pass ]
then
echo "Passwords do not match, try again"
password_check
else
email_id_validation
fi
}
login()
{
change_password()
{
echo "$user"
if [ $? -eq 0 ]
then
read -s -p "Enter New password:" new_password
read -s -p "Re-Enter New password:" re_new_password
if [ $new_password == $re_new_password ]
then
openssl enc -aes-256-cbc -in  .dummy_$user.txt.enc -out dummy_$user.txt -k $new_password
rm -rf .dummy_$user.txt.enc
echo "Password Changed Successfully"
else
echo "Passwords do not match, try again"
read  -s -p "Enter Current Password:" current_password
openssl enc -aes-256-cbc -d -in  dummy_$user.txt -out .dummy_$user.txt.enc -k $current_password
change_password
fi
else
echo "current password is wrong, try again"
read  -s -p "Enter Current Password:" current_password
openssl enc -aes-256-cbc -d -in  dummy_$user.txt -out .dummy_$user.txt.enc -k $current_password
change_password
fi
}
read -p "Enter your user name:" user
cut -d ":" -f 1 users.txt |  grep -w "$user" > /dev/null
if [ $? -eq 0 ]
then
read -s -p "Enter your password:" pass
openssl enc -aes-256-cbc -d -in dummy_$user.txt -k $pass > /dev/null
	if [ $? -eq 0 ]
	then
        echo "1. Change Password"
        echo "2. Add new website info"
        echo "3. View/Modify Account info"
        echo "4. Enable/Disable MFA"
        echo "5. Logout from the session"
        
        read -p "Select any one option from above:" select_option
		echo "$select_option"
        	if [ $select_option -eq 1 ]
        	then
		read  -s -p "Enter Current Password:" current_password
		openssl enc -aes-256-cbc -d -in  dummy_$user.txt -out .dummy_$user.txt.enc -k $current_password
		change_password
                elif [ $select_option -eq 3 ]
		then
 		cat account_info_$user.txt
                elif [ $select_option -eq 2 ]
		then
		Add_password_info
                elif [ $select_option -eq 4 ]
		then
		current_setting=`sed -n '5 p' account_info_$user_register.txt | awk 'BEGIN {FS=":"} {print $2}'`
		if [ $current_setting == Disabled ] 
		then
		mfa_enable
		elif [ $current_setting == Enabled ]
		then
		mfa_disable
		else
		echo "Invalid MFA settings"
		fi
		else
		echo "You are logged out"
		fi
	else
	read -p "Login failed, if you want to try again type yes and if you want to quit type anything:" response
		if [ $response == yes ] || [ $response == Yes ] || [ $response == YES ]
		then
		login
		else
		echo "You are quit"
		fi
        fi
else
read -p "User account doesn't exist, If you want to register type yes and type anything to quit:" response_register
		if [ $response_register == yes ] || [ $response_register == Yes ] || [ $response_register == YES ]
		then
		register
		else
		echo "Exit from the script"
		fi
fi
}
register()
{
read -p "Enter new user name:" user_register
cut -d ":" -f 1 users.txt |  grep -w "$user_register" > /dev/null
if [ $? -ne 0 ]
then
read  -p "Enter email address:" email_id_register
cut -d ":" -f 2 users.txt |  grep -Fw "$email_id_register" > /dev/null
	if [ $? -ne 0 ]
	then
	read  -p "Enter First Name:" first_name
	read  -p "Enter Last Name:" last_name
	password_check
        else
        echo "Email id already exists"
        fi
else
read -p "User id already exits, type yes to try register again or type anything to quit from registration process or type login to login:" response_new_register
	if [ $response_new_register == yes ] || [ $response_new_register == Yes ] || [ $response_new_register == YES ]
	then
	register
	elif [ $response_new_register == login ] || [ $response_new_register == Login ] || [ $response_new_register == LOGIN ]
	then 
	login
	else
	echo "You are quitting from registration"
	fi
fi	
}
Add_password_info()
{
read -s -p "Enter your master password to proceed:" master_pass
openssl enc -aes-256-cbc -d -in dummy_$user.txt -k $master_pass > /dev/null
if [ $? -eq 0 ]
then
read -p "Enter the website info:" website
read -p "Enter your user name:" user_website
read -s -p "Enter your password for the website:" pass_website
echo "Adding your details to the account"
openssl enc -aes-256-cbc -d -in All_password_info_$user.txt -out .All_password_info_$user.txt.enc -k $master_pass
echo "$website:$user_website:$pass_website" >> .All_password_info_$user.txt.enc
openssl enc -aes-256-cbc -in .All_password_info_$user.txt.enc -out All_password_info_$user.txt -k $master_pass
rm -rf .All_password_info_$user.txt.enc
else
read -p "Your master password is wrong, type yes to try again or type anything to quit:" master_response
	if [ $master_response = yes ] || [ $master_response = Yes ] || [ $master_response = YES ]
	then
	Add_password_info
	else
	echo "You are quit"
	fi
fi
}
#login
register

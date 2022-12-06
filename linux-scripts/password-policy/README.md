# Password Policy

The following policies need to be enforced:
- At least 15 characters
- Uses all four types (lowercase, uppercase, number, special)
- Must not use previous three passwords
- Must be changed every six (6) months, with a warning given 7 days prior

# Scripts

There are two scripts. 
The first one is **pw-policy-guide.sh**. It guides you through enforcing our password policy.

    If you have never done this before, it is recommended you do it manually one time
    
    You will get a better idea of what is happening before you run the automated script



The second one is **auto-pw-policy.sh**. It automatically changes the files to enforce our password policy. It
1. backs up the original file and places it in the pw-policy-config folder
2. uses the prewritten file in the same folder to overwrite the original
    
This also allows you to restore the configuration files if they have been tampered with

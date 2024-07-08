
# How to Install and Uninstall SQL Server and Workbench (macOS)

## How to Uninstall (completely)
Uninstalling can help handle crashes and abnormal quits in SQL server and MySQL workbench. Refer to this video for a visual guide on uninstalling: [Uninstall Flow](https://www.youtube.com/watch?v=PBAnWXKIps8)
(start from 4:50)

### Step 1: Uninstallation Process
- Go to Setting 
- Click Uninstall
- Confirm

### Step 2: Verify Uninstallation
Open the terminal and enter the following commands:

```bash
mysql
# zsh: command not found: mysql
mysql -u root -p
# zsh: command not found: mysql
```
If you see the messages shown in the comments, the uninstallation was successful.


### Step 3: Remove Related Folders and Files
Execute these commands to remove residual files.
```bash
sudo rm -rf  /usr/local/mysql
sudo rm -rf  /usr/local/mysql*
sudo rm -rf  /usr/local/var/mysql
sudo rm -rf  /Library/StartupItems/MySQLCOM
sudo rm -rf  /Library/PreferencePanes/My*
sudo rm -rf  /Library/Receipts/MySQL*
sudo rm -rf  /Library/Receipts/mysql*
sudo rm -rf  /private/var/db/receipts/*mysql*
sudo rm -rf  /var/db/receipts/com.mysql.mysql*
clear

# Edit host configuration to remove MySQL references
sudo nano /etc/hostconfig
# Remove any MySQL lines, save with Control + X, and confirm with Y
```

After entering your password for the first sudo command, subsequent sudo commands won't require it within a short time frame.

### Step 4: Final Cleanup

Exit session with `exit` and close the window.


## How to Install Server and MySQL Workbench
Refer to the following video for a detailed installation guide: [Installation Flow](https://www.youtube.com/watch?v=ODA3rWfmzg8)



## Start MySQL
If server is not running, open terminal and type the following:
```bash
sudo /usr/local/mysql/support-files/mysql.server start
```
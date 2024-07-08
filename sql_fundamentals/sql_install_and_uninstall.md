
# How to Install and Uninstall SQL Server and Workbench (MAC)?

## How to uninstall (completely)?
Uninstalling can help handle crashes and abnormal quits in SQL server and MySQL workbench.

[Uninstall Flow](https://www.youtube.com/watch?v=PBAnWXKIps8)
(start from 4:50)

1. Go to Setting, Click Uninstall and Confirm

2. Check if uninstalled successfulling in terminal

```bash
mysql
# zsh: command not found: mysql
mysql -u root -p
# zsh: command not found: mysql
```
If the output showed just as above in the comments, it means uninstall is successful


3. Delete Related Folders and Files
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
```

Entered terminal password once for the first command and you do not have to type it again.

```bash
sudo nano /etc/hostconfig
```
If some thing exist in the config remove the line.

Use `control + x` to exit. Finally, exit session with `exit` and close the window.


## How to install?
[Installation Flow](https://www.youtube.com/watch?v=ODA3rWfmzg8)



## Start MySQL
Open terminal and type the following if server is not running:
```bash
sudo /usr/local/mysql/support-files/mysql.server start
```
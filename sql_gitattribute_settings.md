
# How SQL can show in the GitHub language statistics bar?

> [!NOTE]
> The idea is to create a `.gitattributes` file that contains settings regarding SQL. <br>
> The settings will apply to this **single repository** but **globally**.



### 1. Navigate to the repository in terminal

### 2. Create the .gitattributes file
Use a random text editor to create or edit the `.gitattributes` file. Below is an example of using terminal to create one.

```bash
nano .gitattributes
```

### 3. Edit the .gitattributes file

Add the following lines for linguist settings:

```bash
*.sql linguist-detectable=true
*.sql linguist-language=sql
```
Save and exit the editor (`Ctrl+O` to save, then click `Enter`, then `Ctrl+X` to exit).

### 4. Add the .gitattributes file to Git
```bash
git add .gitattributes
```

### 5. Commit and Push the .gitattributes
```bash
git commit -m "Add .gitattributes to detect and classify .sql files correctly"
git push origin main
```


### References
This tutorial is based on answers from [Github issue 348](https://github.com/github/markup/issues/348).

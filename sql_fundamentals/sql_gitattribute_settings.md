
1. Navigate to the repository in terminal:

2. Create the .gitattributes file:
You can use any text editor to create or edit the .gitattributes file. 

```bash
nano .gitattributes
```

3. Edit the .gitattributes file:
Add the following lines for linguist settings:
```bash
*.sql linguist-detectable=true
*.sql linguist-language=sql
```
Save and exit the editor (Ctrl+O to save, then click Enter, then Ctrl+X to exit).

4. Add the .gitattributes File to Git:
```bash
git add .gitattributes
```

5. Commit and Push:
```bash
git commit -m "Add .gitattributes to detect and classify .sql files correctly"
git push origin main
```

References:
Github issue 348: https://github.com/github/markup/issues/348

# Freeze files of brew and pip

it may include unnecessary packages

```bash
brew list --versions > requirements.brew.txt
# after sourcing virtual env
pip freeze > requirements.pip.txt
```
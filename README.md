# Django Basic Auth Project Generator

A beginner-friendly Windows PowerShell generator that creates a basic Django project with a simple authentication system.

Repository: **[https://github.com/WalidShahriar/Django-basic-auth-powershell-generator](https://github.com/WalidShahriar/Django-basic-auth-powershell-generator)**

> Created and maintained by **MD WALID SHAHRIAR** ([@WalidShahriar](https://github.com/WalidShahriar)).




## What it creates

The script asks for a project name, app name, and virtual-environment name, then creates:

- A Python virtual environment
- A Django project and one Django app
- A custom `UserModel` based on `AbstractUser`
- Registration, login, logout, and protected home views
- App and project URL files
- Bootstrap templates
- Database migrations
- An optional superuser with optional email
- VS Code launch
- A Django development server in one Windows Command Prompt window
- Automatic opening of the registration page

The generated code intentionally stays close to a beginner classroom workflow. It uses function-based views and `import *` because the project is designed to match the author's current learning style.

## Generated structure

```text
projectName/
├── virtualEnvironmentName/
├── manage.py
├── projectName/
│   ├── settings.py
│   ├── urls.py
│   └── ...
└── appName/
    ├── migrations/
    ├── templates/
    │   ├── master/
    │   │   ├── base.html
    │   │   ├── navbar.html
    │   │   └── message.html
    │   ├── home.html
    │   ├── login.html
    │   └── register.html
    ├── admin.py
    ├── models.py
    ├── urls.py
    └── views.py
```

## Requirements

- Windows 10 or Windows 11
- Python 3 available as `py` or `python`
- PowerShell 5.1 or newer
- Internet access while Django and Pillow are installed
- VS Code is optional

## Quick start

1. Download or clone this repository.
2. Open PowerShell inside the repository folder.
3. Temporarily allow the script to run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

4. Run the generator:

```powershell
.\New-DjangoBasicAuthProject.ps1
```

The script will ask for all required names and options.

## Command-line examples

Provide the names directly:

```powershell
.\New-DjangoBasicAuthProject.ps1 `
    -ProjectName autoProject `
    -AppName autoApp `
    -VenvName Env
```

Create the project without a superuser:

```powershell
.\New-DjangoBasicAuthProject.ps1 `
    -ProjectName autoProject `
    -AppName autoApp `
    -VenvName Env `
    -SkipSuperuser
```

Do not open VS Code or start the server:

```powershell
.\New-DjangoBasicAuthProject.ps1 `
    -ProjectName autoProject `
    -AppName autoApp `
    -VenvName Env `
    -SkipVSCode `
    -SkipServer
```

## Parameters

| Parameter | Purpose |
|---|---|
| `ProjectName` | Django project and outer folder name |
| `AppName` | Django application name |
| `VenvName` | Virtual-environment folder name |
| `Destination` | Parent folder where the project is created |
| `SkipSuperuser` | Skips the superuser question and creation |
| `SkipVSCode` | Does not open the generated project in VS Code |
| `SkipServer` | Does not open Command Prompt or run the server |

## Main generated imports

When the app name is `autoApp`, the generator creates imports such as:

```python
from autoApp.models import *
from autoApp.views import *
```

This is intentional for consistency with the learning workflow. In larger production applications, explicit imports are normally easier to maintain.

## Important notes

- The script is intended for learning and local development.
- Django's development server is not a production server.
- The generated logout view is simple and uses a normal link.
- The generated registration view performs basic validation but is not a replacement for Django forms in a production application.
- The script displays the generated superuser password in the terminal summary. Use it only in a safe local environment.

## Creator credit

This repository identifies its creator in several places:

- Script help header and startup banner
- README author section
- `AUTHORS.md`
- `NOTICE`
- Apache 2.0 copyright notice
- `CITATION.cff`, which enables GitHub's **Cite this repository** feature
- Original Git commit history

When redistributing this project, keep the license and notices included with the source.

## Citation

GitHub should display a **Cite this repository** link after `CITATION.cff` is present on the default branch. The citation identifies Eyakub Hossain as the software author.

## Contributing

Small fixes and beginner-friendly improvements are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

Copyright 2026 MD WALID SHAHRIAR.

Licensed under the [Apache License 2.0](LICENSE). See [NOTICE](NOTICE) for attribution information.

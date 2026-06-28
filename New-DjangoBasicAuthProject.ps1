<#
.SYNOPSIS
    Creates a beginner-friendly Django project with a basic authentication system.

.DESCRIPTION
    Generates a Django project, one Django app, a custom user model, registration,
    login, logout, admin registration, Bootstrap templates, migrations, an optional
    superuser, VS Code launch, and a Django development server in Command Prompt.

.AUTHOR
    MD WALID SHAHRIAR (@WalidShahriar)

.VERSION
    1.1.0

.COPYRIGHT
    Copyright 2026 MD WALID SHAHRIAR. Licensed under the Apache License 2.0.

.LINK
    https://github.com/WalidShahriar/Django-basic-auth-powershell-generator
#>

[CmdletBinding()]
param(
    [string]$ProjectName,
    [string]$AppName,
    [string]$VenvName,
    [string]$Destination = (Get-Location).Path,
    [switch]$SkipSuperuser,
    [switch]$SkipVSCode,
    [switch]$SkipServer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Repository identity. Run Customize-Repository.ps1 to change these values everywhere.
$GeneratorAuthor = 'MD WALID SHAHRIAR'
$GeneratorGitHubUsername = 'WalidShahriar'
$GeneratorRepositoryName = 'Django-basic-auth-powershell-generator'
$GeneratorRepositoryUrl = "https://github.com/$GeneratorGitHubUsername/$GeneratorRepositoryName"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $ParentFolder = Split-Path -Parent $Path
    if ($ParentFolder -and -not (Test-Path $ParentFolder)) {
        New-Item -ItemType Directory -Path $ParentFolder -Force | Out-Null
    }

    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Test-PythonName {
    param([string]$Value)

    if ($Value -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
        return $false
    }

    $PythonKeywords = @(
        'False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await',
        'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except',
        'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is',
        'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try',
        'while', 'with', 'yield'
    )

    return $PythonKeywords -notcontains $Value
}

function Read-PythonName {
    param([string]$Prompt)

    while ($true) {
        $Value = (Read-Host $Prompt).Trim()

        if (Test-PythonName $Value) {
            return $Value
        }

        Write-Warning 'Use letters, numbers, and underscores only. The name cannot begin with a number or be a Python keyword.'
    }
}

function Convert-SecureStringToText {
    param([Security.SecureString]$SecureValue)

    $Pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Pointer)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Pointer)
    }
}

function Read-ConfirmedPassword {
    while ($true) {
        $FirstSecure = Read-Host 'Superuser password' -AsSecureString
        $SecondSecure = Read-Host 'Confirm superuser password' -AsSecureString

        $FirstPassword = Convert-SecureStringToText $FirstSecure
        $SecondPassword = Convert-SecureStringToText $SecondSecure

        if ([string]::IsNullOrWhiteSpace($FirstPassword)) {
            Write-Warning 'Password cannot be empty.'
            continue
        }

        if ($FirstPassword -ne $SecondPassword) {
            Write-Warning 'Passwords do not match. Try again.'
            continue
        }

        return $FirstPassword
    }
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $FilePath @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $FilePath $($Arguments -join ' ')"
    }
}

function Invoke-BasePython {
    param([string[]]$Arguments)

    $AllArguments = @($script:PythonLauncherArguments) + @($Arguments)
    & $script:PythonLauncher @AllArguments

    if ($LASTEXITCODE -ne 0) {
        throw "Python command failed with exit code ${LASTEXITCODE}."
    }
}

Write-Host 'Basic Django Authentication Project Generator' -ForegroundColor Green
Write-Host "Created by $GeneratorAuthor (@$GeneratorGitHubUsername)" -ForegroundColor DarkGray
Write-Host "Repository: $GeneratorRepositoryUrl" -ForegroundColor Blue
Write-Host 'Creates the simple project structure used in the learning workflow.'

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Read-PythonName 'Project name (example: demoProject)'
}
elseif (-not (Test-PythonName $ProjectName)) {
    throw "Invalid project name: $ProjectName"
}

if ([string]::IsNullOrWhiteSpace($AppName)) {
    $AppName = Read-PythonName 'App name (example: demoApp)'
}
elseif (-not (Test-PythonName $AppName)) {
    throw "Invalid app name: $AppName"
}

if ([string]::IsNullOrWhiteSpace($VenvName)) {
    $VenvName = Read-PythonName 'Virtual environment name (example: Env)'
}
elseif (-not (Test-PythonName $VenvName)) {
    throw "Invalid virtual environment name: $VenvName"
}

if ($ProjectName -eq $AppName) {
    throw 'The project name and app name must be different.'
}

if ($VenvName -eq $ProjectName -or $VenvName -eq $AppName) {
    throw 'The virtual environment name must be different from the project and app names.'
}

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

$Destination = (Resolve-Path $Destination).Path
$ProjectRoot = Join-Path $Destination $ProjectName

if (Test-Path $ProjectRoot) {
    $ExistingItems = @(Get-ChildItem -Force $ProjectRoot)
    if ($ExistingItems.Count -gt 0) {
        throw "The project folder already exists and is not empty: $ProjectRoot"
    }
}
else {
    New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
}

if (Get-Command py -ErrorAction SilentlyContinue) {
    $script:PythonLauncher = 'py'
    $script:PythonLauncherArguments = @('-3')
}
elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $script:PythonLauncher = 'python'
    $script:PythonLauncherArguments = @()
}
else {
    throw 'Python 3 was not found. Install Python and make sure py or python works in PowerShell.'
}

Push-Location $ProjectRoot
try {
    Write-Step "Creating virtual environment named $VenvName"
    Invoke-BasePython @('-m', 'venv', $VenvName)

    $VenvPython = Join-Path $ProjectRoot "$VenvName\Scripts\python.exe"
    if (-not (Test-Path $VenvPython)) {
        throw "Virtual environment Python was not found: $VenvPython"
    }

    Write-Step 'Installing Django and Pillow'
    Invoke-CheckedCommand $VenvPython @('-m', 'pip', 'install', 'django', 'pillow')

    Write-Step 'Creating Django project and app'
    Invoke-CheckedCommand $VenvPython @('-m', 'django', 'startproject', $ProjectName, '.')
    Invoke-CheckedCommand $VenvPython @('manage.py', 'startapp', $AppName)

    Write-Step 'Updating settings.py'
    $SettingsPath = Join-Path $ProjectRoot "$ProjectName\settings.py"
    $SettingsContent = Get-Content -Raw $SettingsPath
    $InstalledAppsLine = "    'django.contrib.staticfiles',"

    if (-not $SettingsContent.Contains($InstalledAppsLine)) {
        throw 'Could not find INSTALLED_APPS in settings.py.'
    }

    $SettingsContent = $SettingsContent.Replace(
        $InstalledAppsLine,
        "$InstalledAppsLine`r`n    '$AppName',"
    )

    $SettingsContent += @"

# Basic custom authentication settings
AUTH_USER_MODEL = '$AppName.UserModel'
LOGIN_URL = 'login'
"@

    Write-Utf8File $SettingsPath $SettingsContent

    Write-Step 'Creating project URLs'
    $ProjectUrls = @'
from django.contrib import admin
from django.urls import path
from django.urls import include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('__APP_NAME__.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
'@
    $ProjectUrls = $ProjectUrls.Replace('__APP_NAME__', $AppName)

    Write-Utf8File (Join-Path $ProjectRoot "$ProjectName\urls.py") $ProjectUrls

    Write-Step 'Creating app URLs'
    $AppUrls = @'
from django.urls import path
from __APP_NAME__.views import *

urlpatterns = [
    path('register/', register_view, name='register'),
    path('login/', login_view, name='login'),
    path('logout/', logout_view, name='logout'),
    path('home/', home_view, name='home'),
]
'@
    $AppUrls = $AppUrls.Replace('__APP_NAME__', $AppName)

    Write-Utf8File (Join-Path $ProjectRoot "$AppName\urls.py") $AppUrls

    Write-Step 'Creating the custom user model'
    $ModelsContent = @'
from django.contrib.auth.models import AbstractUser
from django.db import models


class UserModel(AbstractUser):
    full_name = models.CharField(blank=True, max_length=100)

    # This makes email optional when creating a superuser.
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.username
'@

    Write-Utf8File (Join-Path $ProjectRoot "$AppName\models.py") $ModelsContent

    Write-Step 'Creating admin.py'
    $AdminContent = @'
from django.contrib import admin
from __APP_NAME__.models import *


admin.site.register([UserModel])
'@
    $AdminContent = $AdminContent.Replace('__APP_NAME__', $AppName)

    Write-Utf8File (Join-Path $ProjectRoot "$AppName\admin.py") $AdminContent

    Write-Step 'Creating the basic views'
    $ViewsContent = @'
from django.shortcuts import render, redirect
from __APP_NAME__.models import *
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.contrib.auth import login, logout, authenticate


def register_view(request):
    if request.method == 'POST':
        username = request.POST.get('username', '').strip()
        email = request.POST.get('email', '').strip()
        full_name = request.POST.get('full_name', '').strip()
        password = request.POST.get('password')
        confirm_password = request.POST.get('confirm_password')

        if not username or not password:
            messages.warning(request, 'Username and password are required.')
            return redirect('register')

        user_exists = UserModel.objects.filter(username=username).exists()
        if user_exists:
            messages.warning(request, 'User already exists.')
            return redirect('register')

        if password == confirm_password:
            UserModel.objects.create_user(
                username=username,
                email=email,
                full_name=full_name,
                password=password,
            )
            messages.success(request, 'User registration successful.')
            return redirect('login')

        messages.warning(request, 'Passwords do not match.')
        return redirect('register')

    return render(request, 'register.html')


def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username', '').strip()
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            messages.success(request, 'Log-In successful.')
            return redirect('home')

        messages.warning(request, 'Invalid credentials.')
        return redirect('login')

    return render(request, 'login.html')


@login_required
def logout_view(request):
    logout(request)
    messages.success(request, 'Log-Out successful.')
    return redirect('login')


@login_required
def home_view(request):
    return render(request, 'home.html')
'@
    $ViewsContent = $ViewsContent.Replace('__APP_NAME__', $AppName)

    Write-Utf8File (Join-Path $ProjectRoot "$AppName\views.py") $ViewsContent

    Write-Step 'Creating templates'
    $TemplatesRoot = Join-Path $ProjectRoot "$AppName\templates"
    $MasterTemplatesRoot = Join-Path $TemplatesRoot 'master'
    New-Item -ItemType Directory -Path $MasterTemplatesRoot -Force | Out-Null

    $BaseHtml = @'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
  </head>
  <body>
    {% include 'master/navbar.html' %}

    <div class="container">
      {% if messages %}
        <div class="py-1">
          {% include 'master/message.html' %}
        </div>
      {% endif %}

      {% block bodyContent %}
      {% endblock bodyContent %}
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
'@

    Write-Utf8File (Join-Path $MasterTemplatesRoot 'base.html') $BaseHtml

    $MessageHtml = @'
{% if messages %}
    {% for each_message in messages %}
        <div class="alert alert-info py-2" role="alert">
            {{ each_message }}
        </div>
    {% endfor %}
{% endif %}
'@

    Write-Utf8File (Join-Path $MasterTemplatesRoot 'message.html') $MessageHtml

    $NavbarHtml = @'
<nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav">
        {% if request.user.is_authenticated %}
          <li class="nav-item">
            <a class="nav-link active" aria-current="page" href="{% url 'home' %}">Home</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">Nav_Element</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="{% url 'logout' %}">Logout</a>
          </li>
        {% else %}
          <li class="nav-item">
            <a class="nav-link" href="#">Nav_Element</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="{% url 'register' %}">Register</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="{% url 'login' %}">Login</a>
          </li>
        {% endif %}
      </ul>
    </div>
  </div>
</nav>
'@

    Write-Utf8File (Join-Path $MasterTemplatesRoot 'navbar.html') $NavbarHtml

    $RegisterHtml = @'
{% extends 'master/base.html' %}

{% block bodyContent %}
    <h1 class="py-2">Get Registered!</h1>

    <form method="POST" action="">
        {% csrf_token %}

        <div class="mb-3">
            <label for="full_name" class="form-label">Full Name</label>
            <input type="text" name="full_name" class="form-control" id="full_name">
        </div>

        <div class="mb-3">
            <label for="username" class="form-label">Username</label>
            <input type="text" name="username" class="form-control" id="username" required>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">Email address</label>
            <input type="email" name="email" class="form-control" id="email">
        </div>

        <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input type="password" name="password" class="form-control" id="password" required>
        </div>

        <div class="mb-3">
            <label for="confirm_password" class="form-label">Confirm Password</label>
            <input type="password" name="confirm_password" class="form-control" id="confirm_password" required>
        </div>

        <div class="mb-3">
            <button type="submit" class="form-control btn btn-success">Register</button>
        </div>

        <div class="mb-3">
            <a href="{% url 'login' %}" class="form-control btn btn-primary">Login</a>
        </div>
    </form>
{% endblock bodyContent %}
'@

    Write-Utf8File (Join-Path $TemplatesRoot 'register.html') $RegisterHtml

    $LoginHtml = @'
{% extends 'master/base.html' %}

{% block bodyContent %}
    <h1 class="py-2">Log-In</h1>

    <form method="POST" action="">
        {% csrf_token %}

        <div class="mb-3">
            <label for="username" class="form-label">Username</label>
            <input type="text" name="username" class="form-control" id="username" required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input type="password" name="password" class="form-control" id="password" required>
        </div>

        <div class="mb-3">
            <button type="submit" class="form-control btn btn-success">Log-In</button>
        </div>

        <div class="mb-3">
            <a href="{% url 'register' %}" class="form-control btn btn-primary">Register</a>
        </div>
    </form>
{% endblock bodyContent %}
'@

    Write-Utf8File (Join-Path $TemplatesRoot 'login.html') $LoginHtml

    $HomeHtml = @'
{% extends 'master/base.html' %}

{% block bodyContent %}
    <h1 class="py-2">Welcome, {{ request.user.username }}!</h1>
{% endblock bodyContent %}
'@

    Write-Utf8File (Join-Path $TemplatesRoot 'home.html') $HomeHtml

    Write-Step 'Creating and applying migrations'
    Invoke-CheckedCommand $VenvPython @('manage.py', 'makemigrations', $AppName)
    Invoke-CheckedCommand $VenvPython @('manage.py', 'migrate')

    $SuperuserCreated = $false
    $SuperuserUsername = ''
    $SuperuserEmail = ''
    $SuperuserPassword = ''

    if (-not $SkipSuperuser) {
        $CreateSuperuserAnswer = Read-Host 'Create a superuser now? [Y/n]'

        if ([string]::IsNullOrWhiteSpace($CreateSuperuserAnswer) -or $CreateSuperuserAnswer.Trim().ToLower() -eq 'y') {
            while ([string]::IsNullOrWhiteSpace($SuperuserUsername)) {
                $SuperuserUsername = (Read-Host 'Superuser username').Trim()
            }

            $SuperuserEmail = (Read-Host 'Superuser email (press Enter to skip)').Trim()
            $SuperuserPassword = Read-ConfirmedPassword

            Write-Step 'Creating superuser'
            $env:DJAUTO_USERNAME = $SuperuserUsername
            $env:DJAUTO_EMAIL = $SuperuserEmail
            $env:DJAUTO_PASSWORD = $SuperuserPassword

            try {
                $CreateSuperuserCode = "import os; from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(username=os.environ['DJAUTO_USERNAME'], email=os.environ.get('DJAUTO_EMAIL', ''), password=os.environ['DJAUTO_PASSWORD'])"
                Invoke-CheckedCommand $VenvPython @('manage.py', 'shell', '-c', $CreateSuperuserCode)
                $SuperuserCreated = $true
            }
            finally {
                Remove-Item Env:DJAUTO_USERNAME -ErrorAction SilentlyContinue
                Remove-Item Env:DJAUTO_EMAIL -ErrorAction SilentlyContinue
                Remove-Item Env:DJAUTO_PASSWORD -ErrorAction SilentlyContinue
            }
        }
    }

    if (-not $SkipVSCode) {
        $CodeCommand = Get-Command code -ErrorAction SilentlyContinue

        if ($CodeCommand) {
            Write-Step 'Opening the project in VS Code'

            # Run code.cmd inside the current PowerShell window.
            # Using Start-Process with code.cmd can open an extra CMD window.
            & $CodeCommand.Source $ProjectRoot

            if ($LASTEXITCODE -ne 0) {
                Write-Warning 'VS Code could not be opened automatically. Open the project folder manually.'
            }
        }
        else {
            Write-Warning 'The code command was not found. Open the project folder manually in VS Code.'
        }
    }

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host 'Project created successfully.' -ForegroundColor Green
    Write-Host "Project folder : $ProjectRoot"
    Write-Host "Project name   : $ProjectName"
    Write-Host "App name       : $AppName"
    Write-Host "Virtual env    : $VenvName"
    Write-Host "Generator      : $GeneratorAuthor (@$GeneratorGitHubUsername)"
    Write-Host "Repository     : $GeneratorRepositoryUrl"

    if ($SuperuserCreated) {
        Write-Host "`nSuperuser credentials:" -ForegroundColor Yellow
        Write-Host "Username       : $SuperuserUsername"
        Write-Host "Email          : $SuperuserEmail"
        Write-Host "Password       : $SuperuserPassword"
    }

    Write-Host "`nRegistration page: http://127.0.0.1:8000/register/"
    Write-Host "Admin page       : http://127.0.0.1:8000/admin/"
    Write-Host '============================================'

    if (-not $SkipServer) {
        Write-Step 'Starting Django development server in Windows Command Prompt'
        $ServerCommand = "call $VenvName\Scripts\activate.bat && python manage.py runserver"
        Start-Process -FilePath 'cmd.exe' -ArgumentList @('/k', $ServerCommand) -WorkingDirectory $ProjectRoot
        Start-Sleep -Seconds 2
        Start-Process 'http://127.0.0.1:8000/register/'
    }
}
catch {
    Write-Host "`nProject generation stopped." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    throw
}
finally {
    Pop-Location
}

# PowerShell version of initpost.sh script

# -------------------------------------------------------------------------
# VARIABLES
# -------------------------------------------------------------------------

# Core
$POST_TITLE = $args[1..($args.Length-1)] -join ' '
$POST_NAME = $POST_TITLE -replace ' ', '-' -replace '[A-Z]', { $_.ToLower() }
$CURRENT_DATE = Get-Date -UFormat "%Y-%m-%d"
$TIME = Get-Date -UFormat "%T"
$FILE_NAME = "${CURRENT_DATE}-${POST_NAME}.md"

# Settings
$BINPATH = Get-Location
$POSTPATH = Join-Path $BINPATH "_posts"
$DIST_FOLDER = $POSTPATH
$BLOG_URL = "https://jekflix.rossener.com/"
$ASSETS_URL = "assets/img/"

# -------------------------------------------------------------------------
# FUNCTIONS
# -------------------------------------------------------------------------

# Header logging
function e_header {
    Write-Host "→ $($args[0])" -ForegroundColor Cyan
}

# Success logging
function e_success {
    Write-Host "✔ $($args[0])" -ForegroundColor Green
}

# Error logging
function e_error {
    Write-Host "✖ $($args[0])" -ForegroundColor Red
}

# Warning logging
function e_warning {
    Write-Host "! $($args[0])" -ForegroundColor Yellow
}

# Help
function initpost_help {
    @"
------------------------------------------------------------------------------
INIT POST - A shortcut to create an initial structure for my posts.
------------------------------------------------------------------------------
Usage: .\initpost.ps1 [options] <post name>
Options:
  -h, --help        output instructions
  -c, --create      create post
Example:
  .\initpost.ps1 -c How to replace strings with sed
------------------------------------------------------------------------------
"@
}

# Initial Content
function initpost_content {
    @"
---
date: $CURRENT_DATE $TIME
layout: post
title: \"$POST_TITLE\"
subtitle:
description:
image:
optimized_image:
category:
tags:
author:
paginate: false
---
"@
}

# Create file
function initpost_file {
    $fullPath = Join-Path $DIST_FOLDER $FILE_NAME
    if (-not (Test-Path $fullPath)) {
        e_header "Creating template..."
        initpost_content | Out-File $fullPath -Encoding utf8
        e_success "Initial post successfully created!"
    } else {
        e_warning "File already exists."
        exit 1
    }
}

# -------------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------------

function main {
    param(
        [string]$option
    )
    
    switch ($option) {
        '-h' { initpost_help; exit }
        '--help' { initpost_help; exit }
        '-c' { initpost_file; exit }
        '--create' { initpost_file; exit }
        default { Write-Host "Invalid option. Use -h for help." }
    }
}

main $args[0]

# Safe File Editing with Backup and Logging

**Author:** Rohini Manikandan    
**Institution:** Anglia Ruskin University, Cambridge  

---

## Overview

This project provides scripts to safely edit files while automatically creating backups and maintaining a log of backup actions. It includes implementations for both **MS-DOS (Windows)** and **Linux Bash** environments.  

Key features:  
- Automatic creation of `.bak` backups before editing files.  
- Maintains a log of the last 5 backup actions with timestamps.  
- Handles invalid filenames, multiple parameters, and non-existent files.  
- Supports both interactive and command-line modes.  
- Ensures secure editing for files with specific extensions:  
  - `.bat` and `.txt` for Windows  
  - `.sh` and `.txt` for Linux  

---

## Table of Contents

- [MS-DOS Batch Script](#ms-dos-batch-script)  
- [Linux Bash Script](#linux-bash-script)  
- [Usage](#usage)  
- [Features](#features)  
- [Test Cases](#test-cases)  
- [References](#references)  
- [License](#license)  

---

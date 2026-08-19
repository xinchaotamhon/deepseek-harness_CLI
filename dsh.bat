@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title DeepSeek Harness (dsh) - Local launcher

rem ============================================================
rem  DeepSeek Harness - self-contained launcher
rem  This batch makes the checkout fully standalone:
rem    - .portable\node.exe        portable Node.js runtime
rem    - .portable\pnpm.cmd        pnpm (installed via portable npm)
rem    - .portable\corepack.cmd    corepack shim (bundled with Node)
rem  It locates itself via %~dp0 so the whole folder can be
rem  moved/copied to any Windows machine and still run.
rem  API credentials are read automatically from .env at repo root.
rem
rem  UPDATE CHECK: on every launch this script fetches the upstream
rem  DeepSeek repo (origin = deepseek-ai/deepseek-harness) and shows
rem  a notice when new commits exist, so the owner can decide whether
rem  to merge them now or later.
rem ============================================================

set "ROOT=%~dp0"
set "PNPM=%ROOT%.portable\pnpm.cmd"
set "PORTABLE_NODE=%ROOT%.portable\node-v24.12.0-win-x64"

rem --- Put the portable toolchain first on PATH -----------------
set "PATH=%PORTABLE_NODE%;%ROOT%.portable;%PATH%"

rem --- Check for upstream (DeepSeek) updates --------------------
call :check_update

rem --- First-run: build artifacts (docs require pnpm run build) --
if not exist "%ROOT%apps\web\dist" (
    echo [dsh] First run detected: building package + web artifacts...
    echo [dsh] This takes a few minutes. Subsequent runs are instant.
    call "%PNPM%" run build
    if errorlevel 1 (
        echo [dsh] Build failed. Fix errors above, then re-run this file.
        pause
        exit /b 1
    )
    echo [dsh] Build complete.
)

:menu
cls
echo ============================================
echo   DeepSeek Harness - choose an entry mode
echo ============================================
echo   [1] Web UI        - open the agent UI in your browser
echo   [2] Headless      - one-shot agent, type a task, get the answer
echo   [3] ACP server    - automation server over JSON-RPC stdio
echo   [4] Cordis demo   - self-referential agent demo
echo   [5] Rebuild       - rebuild lib + web artifacts
echo   [6] Check update  - re-check DeepSeek upstream for new commits
echo   [0] Exit
echo ============================================
set /p CHOICE="Your choice: "

if "%CHOICE%"=="1" goto web
if "%CHOICE%"=="2" goto headless
if "%CHOICE%"=="3" goto acp
if "%CHOICE%"=="4" goto cordis
if "%CHOICE%"=="5" goto rebuild
if "%CHOICE%"=="6" goto check_update
if "%CHOICE%"=="0" exit /b 0
echo Invalid choice.
pause
goto menu

rem ============================================================
rem  Update check: fetch upstream, compare, offer merge
rem ============================================================
:check_update
echo [dsh] Checking for new commits from DeepSeek upstream...
git fetch origin --quiet 2>nul
if errorlevel 1 (
    echo [dsh] Could not reach GitHub (offline?). Skipping update check.
    goto :update_done
)
set "UPSTREAM_AHEAD=0"
for /f "delims=" %%i in ('git rev-list --count HEAD..origin/master 2^>nul') do set "UPSTREAM_AHEAD=%%i"
if not defined UPSTREAM_AHEAD set "UPSTREAM_AHEAD=0"
if "%UPSTREAM_AHEAD%"=="0" (
    echo [dsh] Up to date with DeepSeek upstream.
    goto :update_done
)
echo.
echo ============================================================
echo   [dsh] UPDATE AVAILABLE: %UPSTREAM_AHEAD% new commit(s)
echo   from DeepSeek upstream (origin/master). Latest:
echo ============================================================
git log --oneline -5 origin/master
echo.
choice /C YN /M "Merge now? (Y=merge + reinstall + rebuild / N=skip)"
if errorlevel 2 goto :update_done
echo [dsh] Merging upstream...
git merge origin/master
if errorlevel 1 (
    echo [dsh] Merge FAILED (likely conflicts). Aborting to keep the repo clean.
    echo [dsh] Resolve manually or ask an AI to handle the merge, then re-run this file.
    git merge --abort
    goto :update_done
)
echo [dsh] Merge OK. Reinstalling dependencies and rebuilding...
call "%PNPM%" install
if errorlevel 1 (
    echo [dsh] pnpm install FAILED after merge. See errors above.
    goto :update_done
)
call "%PNPM%" run build
if errorlevel 1 (
    echo [dsh] Build FAILED after merge. See errors above.
    goto :update_done
)
echo [dsh] Update merged and rebuilt successfully.
:update_done
echo.
pause
goto menu

:web
echo Starting Web UI... press Ctrl+C to stop.
call "%PNPM%" dsh --profile web
pause
goto menu

:headless
set /p TASK="Task for the agent (press Enter for default): "
if not defined TASK set "TASK=summarize this workspace"
echo Running one-shot agent...
call "%PNPM%" dsh --profile headless "%TASK%"
echo.
pause
goto menu

:acp
echo Starting ACP automation server... press Ctrl+C to stop.
call "%PNPM%" run demo:acp
pause
goto menu

:cordis
echo Starting cordis demo... press Ctrl+C to stop.
call "%PNPM%" run demo:cordis
pause
goto menu

:rebuild
call "%PNPM%" run build
if errorlevel 1 (
    echo Build failed.
) else (
    echo Build complete.
)
pause
goto menu
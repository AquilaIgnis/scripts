#!/bin/python3

import os
import pathlib
import subprocess
import sys

from pyfzf import FzfPrompt

home = pathlib.Path.home()

# Python projects
python_projects = {}

# other projects
other = {
    'ViveNotes': f'{home}/AndroidStudioProjects/viveNotes',
    'multiplataform-vive': f'{home}/repos/viveHub/multiplataform-vive',
    'vivenotes.net': f'{home}/repos/viveHub/vivenotes.net',
    'cloud-sync': f'{home}/repos/viveHub/cloudServer-viveNotes/',
    'ByteInk': f'{home}/repos/viveHub/byteink/',
    'viveHub': f'{home}/repos/viveHub',
    "gobook": f'{home}/golang/book/',
    'Stims': f'{home}/AndroidStudioProjects/stims/',
    'Datastructures': f'{home}/golang/datastructures/',
}


def main():
    fzf = FzfPrompt()
    choices = {}

    for key in python_projects:
        if "python" not in choices:
            choices["python"] = []

        choices["python"].append(key)

    for key in other:
        if "go" not in choices:
            choices["go"] = []

        choices["go"].append(key)

    # Flatten all values into one list or is [[]]
    all_choices = [item for sublist in choices.values() for item in sublist]

    selection: list = fzf.prompt(all_choices, '--prompt="Launch:"')

    if not selection:
        print('Nothing selected')
        sys.exit(0)

    selected: str = selection[0]
    print("selected:", selected)

    # Handle selection

    # UV
    if selected in python_projects:
        project_path = python_projects[selected]
        print("project_path:", project_path)

        os.chdir(project_path)

        inner_cmd = "tmux new-window && exec zsh"

        tmux_cmd = ["tmux", "new", '-d', "-s", selected, "zsh", "-c", inner_cmd]

        subprocess.run(tmux_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)

        esac(selected)

    elif selected in other:
        project_path = other[selected]

        os.chdir(project_path)
        subprocess.run(["tmux", "new", "-s", selected], check=False)


def esac(selected: str):
    if 'esac.sh' in os.listdir():
        other_commands = f"tmux send-keys -t {selected} 'sh ./esac.sh' C-m"
        subprocess.run(other_commands, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True, check=False)

    subprocess.run(
        ['tmux', 'attach', '-t', selected], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False
    )


if __name__ == "__main__":
    main()

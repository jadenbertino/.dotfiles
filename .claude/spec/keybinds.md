# Specification Template

> Ingest the information from this file, implement the Low-Level Tasks, and generate the code that will satisfy the High and Mid-Level Objectives.

## High-Level Objective

> Adjust the stow.sh script so that it stows the code key binds JSON file to the correct location based on the user's OS.

## Mid-Level Objective

- Identify the path to the user's existing `code` key binds JSON file
- use gnu stow adopt to symlink `.config/Code/User/keybinds.json` to the user's existing `code` key binds JSON file

## Implementation Notes

- May need to adjust the .stow-local-ignore file as it currently ignores the `.config/Code` directory
- Create a separate `scripts/stow-vs-code.sh` script that will be used to stow the code key binds JSON file to the correct location based on the user's OS. Then source this script from the `stow.sh` script.

## Context

### Beginning context

- `scripts/stow.sh`
- `.config/Code/User/keybinds.json`
- `.stow-local-ignore`
- `README.md`

### Ending context

- `scripts/stow.sh`
- `.config/Code/User/keybinds.json`
- `.stow-local-ignore`
- `README.md`
- `scripts/stow-vs-code.sh`

## Low-Level Tasks
> Ordered from start to finish

1. Identify the path to the user's existing `code` key binds JSON file
```claude
CREATE `scripts/stow-vs-code.sh`
  USE detect_os function from utils.sh to determine the user's OS
  CREATE function `get_code_keybinds_path` that will return the path to the user's existing `code` key binds JSON file or throw error if it could not be found. Use detect_os to determine the path based on the user's OS.
```

2. Create a function `stow_vs_code` that will stow the code key binds JSON file to the correct location based on the user's OS
```claude
UPDATE `scripts/stow-vs-code.sh`
  USE get_code_keybinds_path function to get the path to the user's existing `code` key binds JSON file
  USE gnu stow adopt to symlink `.config/Code/User/keybinds.json` to the user's existing `code` key binds JSON file
```

3. Update the `stow.sh` script to source the `stow-vs-code.sh` script
```claude
UPDATE `scripts/stow.sh`
  SOURCE `scripts/stow-vs-code.sh`
```
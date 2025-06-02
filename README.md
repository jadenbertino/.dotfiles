# Prerequisites

### Install `zsh`

- Install `zsh`
- Set `zsh` as the default shell
- (Optionally backup and) Remove any existing `.zshrc` files or configuration (e.g. `oh-my-zsh`)

### Install packages

You'll need to install the following packages:
- `git`
- `fzf`
- `zoxide`
- `stow`

### Install a Nerd Font

- Recommended: `JetBrainsMono Nerd Font`
- Go to [Nerd Fonts Download Page](https://www.nerdfonts.com/font-downloads)
- Download the font zip
- Unzip the download
- Install the fonts
  - Mac: Open up `Font Book` and drag and drop the fonts into the app
  - Ubuntu: Copy the .ttf files to `/usr/local/share/fonts`
- Ensure your terminal is using the font
  - Mac (`ghostty`):
      ```bash
      ghostty +list-fonts | grep -i jetbrains
      # choose a top level (non indented) font

      # Open up config file
      # code "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
      # add this line (NL = non ligatures)
      # font-family = "JetBrainsMonoNL Nerd Font Mono"

      # Open up a new ghostty tab
      # confirm config loaded
      ghostty +show-config | grep font-family
      ```

# Usage

1. Clone this repo into your home directory
2. `cd` into the repo
3. run `stow -v .` to symlink the files

# Additional Notes

- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.
- If there are conflicts, you can run `stow --adopt .`. This will move the original files into this directory and then symlink the files back to the original location. Keep in mind that this will overwrite the files in this repo.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)


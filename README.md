# Pre-requisites

- TODO: add this

# Setup

1. Install GNU Stow
    - mac: `brew install stow`
    - ubuntu: `sudo apt-get install stow`

2. Clone this repo into your home directory

3. `cd` into the repo

4. run `stow -v .` to symlink the files

# Additional Notes

- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.
- If there are conflicts, you can run `stow --adopt .`. This will move the original files into this directory and then symlink the files back to the original location. Keep in mind that this will overwrite the files in this repo.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)

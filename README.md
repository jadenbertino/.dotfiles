# Usage

1. Ensure you meet all the [prerequisites](docs/Prerequisites.md)
2. Clone this repo into your home directory
3. `cd` into the repo
4. Refer to `.config/env/.env.example` to set up your `.env` file
5. Run `bash scripts/stow.sh`
6. Review and make changes to files in the repo
7. Run `source ~/.zshrc` to load the config
   - After you source the first time, you can just run `reload` to reload the config

# Codespaces

if using this in codespaces

1. clone the repo into home dir: `cd && gh repo clone jadenbertino/.dotfiles`
2. install stow: `sudo apt-get update && sudo apt-get install stow`
3. attempt to stow (will fail): `cd ~/.dotfiles && stow .`
4. delete all the conflicting files
5. stow again
6. ???
7. profit

# Additional Notes

- If you ever want to delete the symlinks, you can run `stow -D .`
- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)

# MCD-CLI Test

*Version: [0.2.10](https://changelog.makerdao.com/releases/0.2.10/index.html) kovan deployment*

This test checks the [mcd-cli guide](https://github.com/makerdao/developerguides/blob/master/devtools/mcd-cli/mcd-cli-guide-01/mcd-cli-guide-01.md) against the mcd-cli tool to see if there's any breaking changes.  
The `test` folder has necessary files to run the test.

Make sure to install the [mcd-cli](https://github.com/makerdao/mcd-cli) tool first before running the test.

## Install

- Linux: `sudo apt install bats`
- Mac:
  - Press Command+Space and type Terminal and press enter/return key.
  - Run in Terminal app:
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null`
and press enter/return key.
If the screen prompts you to enter a password, please enter your Mac's user password to continue. When you type the password, it won't be displayed on screen, but the system would accept it. So just type your password and press ENTER/RETURN key. Then wait for the command to finish.
    - Run: `brew install bats`

## Steps

- Navigate to `test` folder
- To run the tests, run `bats test.bats` command and the test will start.

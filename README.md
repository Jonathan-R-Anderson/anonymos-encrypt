# anonymos-encrypt

This repository provides scripts for creating a hidden VeraCrypt volume that contains the [internetcomputer](https://github.com/Jonathan-R-Anderson/internetcomputer) operating system. The approach is similar to the [VeraCrypt Hidden Operating System](https://veracrypt.io/en/VeraCrypt%20Hidden%20Operating%20System.html), allowing the OS ISO to be stored inside a hidden volume for plausible deniability.

## Requirements
- VeraCrypt installed and accessible via the `veracrypt` command
- `qemu` (optional, for booting the ISO)
- Dependencies needed to build the Internet Computer OS

## Usage
1. Clone the Internet Computer repository next to this one:
   ```bash
   git clone https://github.com/Jonathan-R-Anderson/internetcomputer
   ```
2. Build the OS ISO:
   ```bash
   cd internetcomputer
   make build
   ```
3. Run the helper script to create the hidden volume and place the ISO inside it:
   ```bash
   ../anonymos-encrypt/create_hidden_os.sh
   ```
4. Mount the resulting volume and boot the ISO if desired:
   ```bash
   veracrypt --text --mount anonymOS_hidden.hc /mnt
   qemu-system-x86_64 -cdrom /mnt/anonymOS.iso
   ```

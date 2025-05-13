```markdown
# PrisonBrute 🗝️🔓💥

**A High-Speed Hydra Attack Orchestrator for Ethical Pentesters & Security Researchers**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Bash Version](https://img.shields.io/badge/bash-%3E%3D4.x-blue)
![Kali Linux](https://img.shields.io/badge/Kali%20Linux-Compatible-blueviolet)

```ascii
██████╗ ██████╗ ██╗███████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔══██╗██║██╔════╝██╔═══██╗████╗  ██║
██████╔╝██████╔╝██║███████╗██║   ██║██╔██╗ ██║
██╔═══╝ ██╔══██╗██║╚════██║██║   ██║██║╚██╗██║
██║     ██║  ██║██║███████║╚██████╔╝██║ ╚████║
╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝
               P R I S O N B R U T E
        High-Speed Hydra Attack Orchestrator
```

**Disclaimer:** ⚠️ **This tool is intended for legal and ethical use ONLY.** Use it exclusively on systems for which you have explicit, written permission to test. Unauthorized access to computer systems is illegal. The developers assume no liability and are not responsible for any misuse or damage caused by this program.

---

## 🚀 Overview

`PrisonBrute` is a powerful Bash script designed to simplify and accelerate online brute-force attacks using the legendary `hydra` tool. It provides a user-friendly, colorful interface while allowing for aggressive, high-speed attempts against various network services.

Think of it as a streamlined frontend for `hydra`, making it easier to launch common brute-force scenarios with sensible defaults and clear output, while still giving you access to `hydra`'s core power for customization.

## ✨ Features

*   🌈 **Colorful & Thematic UI:** Enhanced readability and a distinct "PrisonBrute" feel.
*   ⚡ **Speed-Focused Defaults:** Configured for faster attacks out-of-the-box (default tasks: 64).
*   🛡️ **Hydra Backend:** Leverages the full power and protocol support of THC-Hydra.
*   🌐 **Wide Protocol Support:** SSH, FTP, HTTP(S)-GET, HTTP(S)-FORM, SMB, RDP, Telnet, VNC, MySQL, PostgreSQL, and virtually any service Hydra supports.
*   📝 **Flexible User/Pass Input:**
    *   Single username/password.
    *   Path to user list file.
    *   Path to password list file.
    *   Path to colon-separated `user:pass` combo file (`-C` option).
*   🎯 **Easy Targeting:** Specify target IP/hostname and optional port.
*   ⚙️ **Customizable Hydra Options:**
    *   `-t <tasks>`: Control the number of parallel attack threads.
    *   `-w <seconds>`: Set wait time between attempts per thread.
    *   `-x <min:max:charset>`: Utilize Hydra's password generation.
    *   `-f`: Stop after the first found credential.
    *   `-e ns`: Additional checks (null password, password same as username).
    *   `-v / -V`: Control Hydra's verbosity.
*   📄 **Output Logging:** Found credentials are automatically saved to `pb_found_credentials.txt`.
*   🆘 **Comprehensive Help Menu:** Detailed usage instructions and examples.
*   ✅ **Dependency Check:** Ensures `hydra` is installed before running.
*   🔐 **HTTP/S Form Support:** Basic handling for POST form-based logins, including path, parameters, and failure string detection.

## 🛠️ Prerequisites

*   **Linux Environment:** Primarily designed for Kali Linux, but should work on other Linux distributions.
*   **Bash:** Version 4.x or higher.
*   **THC-Hydra:** This is the core engine. Install it if you haven't already:
    ```bash
    sudo apt update && sudo apt install hydra
    ```

## 📥 Installation

1.  **Clone the repository (or download the script):**
    ```bash
    git clone https://github.com/yourusername/PrisonBrute.git # Replace with actual repo URL
    cd PrisonBrute
    ```
    Or, simply download `PrisonBrute.sh`.

2.  **Make the script executable:**
    ```bash
    chmod +x PrisonBrute.sh
    ```

3.  **Optional: Move to your PATH for global access:**
    ```bash
    sudo cp PrisonBrute.sh /usr/local/bin/prisonbrute
    # Now you can run it as 'prisonbrute' from anywhere
    ```

## 📖 Usage

The basic syntax is:

```bash
./PrisonBrute.sh <protocol> <target> <user_source> <pass_source> [port] [options]
```

Or if installed globally:

```bash
prisonbrute <protocol> <target> <user_source> <pass_source> [port] [options]
```

---

### 📜 Arguments Explained

*   **`<protocol>`** (Required)
    *   The service you want to attack.
    *   Examples: `ssh`, `ftp`, `http-get`, `https-get`, `http-form`, `https-form`, `smb`, `rdp`, `telnet`, `vnc`, `mysql`, `postgres`.
    *   This is passed directly to `hydra`, so any service `hydra` supports by name can be used.

*   **`<target>`** (Required)
    *   The IP address or hostname of the target machine/service.
    *   Example: `192.168.1.101`, `example.com`.

*   **`<user_source>`** (Required, unless `-C` is used)
    *   Can be a single username (e.g., `admin`) or the path to a file containing a list of usernames (one per line).
    *   Example: `root`, `users.txt`.

*   **`<pass_source>`** (Required, unless `-C` is used)
    *   Can be a single password (e.g., `password123`) or the path to a file containing a list of passwords (one per line).
    *   Example: `P@$$wOrd`, `rockyou.txt`.

*   **`[port]`** (Optional)
    *   The specific port number for the service if it's not running on its default port.
    *   If omitted, `hydra` will use the default port for the specified protocol.
    *   Example: `2222` (for SSH on a non-standard port).

---

### ⚙️ Core Speed & Brute-Force Options

*   **`-t <tasks>`**:
    *   Number of parallel connection attempts (threads) `hydra` will use.
    *   Default: `64`.
    *   Higher values mean faster attempts but can overwhelm the target or your network.
    *   ⚠️ **Use high values with extreme caution!**
    *   Example: `-t 128`

*   **`-w <seconds>`**:
    *   Wait time in seconds (can be decimal, e.g., `0.5`) between connection attempts *per thread*.
    *   Default: `0` (or `hydra`'s internal default, effectively meaning as fast as possible per thread).
    *   Useful for evading simple rate-limiting or reducing load on the target.
    *   Example: `-w 1`

*   **`-x <min:max:charset>`**:
    *   Engages `hydra`'s password generation feature.
    *   `min`: Minimum password length.
    *   `max`: Maximum password length.
    *   `charset`: Characters to use.
        *   `a`: Lowercase letters
        *   `A`: Uppercase letters
        *   `1`: Numbers
        *   Special characters can be listed directly (e.g., `@#$`).
    *   Example: `-x 3:5:a1` (generates passwords of 3 to 5 characters using lowercase letters and numbers).
    *   **Note:** When using `-x`, `<pass_source>` is ignored for password generation.

---

### ✨ Other Useful Options

*   **`-f`**:
    *   Stop the attack as soon as the first valid credential pair is found.
    *   Useful if you only need one point of entry.

*   **`-C <file>`**:
    *   Use a colon-separated `username:password` file (combo list).
    *   If this option is used, `<user_source>` and `<pass_source>` arguments are ignored.
    *   Example: `-C credentials.txt` where `credentials.txt` contains lines like `admin:password123`.

*   **`-e <n|s|r>`**:
    *   Perform additional checks:
        *   `n`: Try null/empty password.
        *   `s`: Try password same as username.
        *   `r`: Try reversed username as password.
    *   Can be combined: `-e ns`
    *   Example: `-e ns`

*   **`-v` / `-V`**:
    *   Control `hydra`'s verbosity.
    *   `-v`: Verbose mode.
    *   `-V`: Very Verbose mode (shows individual login attempts).
    *   `PrisonBrute` defaults to `-V` if neither is specified, to provide attack feedback.

---

### 🌐 HTTP(S) Form Specific Arguments

When using `http-form` or `https-form`, you need to provide additional arguments *after* the main ones but *before* any optional port or `-` options. The order is important:

1.  **`/<path_to_form>`** (Required for forms)
    *   The URL path to the login form page on the target server.
    *   Must start with `/`.
    *   Example: `/login.php`, `/admin/index.html`

2.  **`"<form_parameters>"`** (Required for forms)
    *   A **quoted string** defining the POST request parameters.
    *   Use `^USER^` as a placeholder for the username.
    *   Use `^PASS^` as a placeholder for the password.
    *   Find these by inspecting the login form's HTML source or a captured login request (e.g., with Burp Suite or browser developer tools).
    *   Example: `"username=^USER^&password=^PASS^&loginsubmit=Login"`

3.  **`"<failure_string>"`** (Required for forms)
    *   A **quoted string** that uniquely appears on the page ONLY when a login attempt **FAILS**.
    *   `Hydra` uses this to determine unsuccessful attempts.
    *   This is crucial and often requires careful inspection of failed login responses.
    *   Example: `"Invalid username or password"`, `"Login incorrect"`

**Example `http-form` command structure:**

```bash
./PrisonBrute.sh http-form example.com users.txt passwords.txt /auth/login.aspx "user=^USER^&pass=^PASS^&btnSubmit=Sign In" "Authentication failed"
```

---

## 💡 Examples

*   **SSH attack with a user list and password list, 100 tasks, stopping on first find:**
    ```bash
    ./PrisonBrute.sh ssh 192.168.0.42 userlist.txt passlist.txt -t 100 -f
    ```

*   **FTP attack against a specific user on a non-standard port:**
    ```bash
    ./PrisonBrute.sh ftp 10.10.10.50 johndoe common_passwords.txt 2121
    ```

*   **HTTP GET Basic Authentication:**
    ```bash
    ./PrisonBrute.sh http-get protected.example.com admins.txt top1000pass.txt
    ```

*   **HTTP POST Form attack (DVWA example - might need CSRF handling for real DVWA):**
    ```bash
    ./PrisonBrute.sh http-form 192.168.1.123 users.txt pass.txt /dvwa/login.php "username=^USER^&password=^PASS^&Login=Login" "Login failed"
    ```
    *Note: Real-world web form brute-forcing can be complex due to CSRF tokens, captchas, JavaScript, etc. `PrisonBrute` provides the basic `hydra` structure; manual `hydra` tweaking might be needed for advanced forms.*

*   **SMB attack using a combo list:**
    ```bash
    ./PrisonBrute.sh smb 192.168.1.200 ignored_user ignored_pass -C smb_creds.txt
    # smb_creds.txt contains:
    # administrator:Password123
    # shareuser:backup@pass
    ```

*   **RDP attack with 32 tasks:**
    ```bash
    ./PrisonBrute.sh rdp 172.16.30.5 rdp_users.txt winter2023_pass.txt -t 32
    ```

*   **MySQL attack trying null password and password same as user:**
    ```bash
    ./PrisonBrute.sh mysql db.internal.lan root common_db_passwords.txt -e ns
    ```

## 📈 Output

*   Found credentials will be printed to the console upon discovery.
*   All successfully found credentials are also logged to `pb_found_credentials.txt` in the directory where `PrisonBrute` is run. The format is similar to `hydra`'s standard output file.

## 🚨 Warnings & Best Practices

*   🛑 **ETHICAL USE ONLY:** Only attack systems you have explicit permission to test.
*   🐢 **START SLOW:** When unsure about a target, start with a low number of tasks (`-t 4` or `-t 8`) and gradually increase if the target is stable and not blocking you.
*   ⏳ **ACCOUNT LOCKOUTS:** Be aware of account lockout policies on the target system. Too many failed attempts can disable accounts.
*   🚫 **IDS/IPS/WAFs:** Modern security systems can detect and block brute-force attempts. Consider using techniques like proxy rotation (if `hydra` supports it for the module) or slower, more targeted attacks.
*   📚 **WORDLISTS ARE KEY:** The success of a brute-force attack heavily depends on the quality of your username and password lists. Use common lists (SecLists is a great resource) and tailor them to your target if possible.
*   🔎 **VERIFY FINDINGS:** Always manually verify any credentials found by `PrisonBrute` to ensure they are accurate and provide the expected level of access.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Please feel free to:

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📜 License

Distributed under the MIT License. See `LICENSE` file for more information.

---

Happy (ethical) brute-forcing! Remember to always stay within legal boundaries.
```

**To make this GitHub-ready:**

1.  **Create a `LICENSE` file** in your repository with the MIT License text (you can find templates online easily).
2.  Replace `https://github.com/yourusername/PrisonBrute.git` with the actual URL once you create the repository.
3.  Save the content above as `README.md` in the root of your GitHub repository.

This README provides a good balance of information, examples, and warnings, making it useful for potential users of your `PrisonBrute` tool. The emojis add a bit of visual flair.

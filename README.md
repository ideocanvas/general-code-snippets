# General Code Snippets Repository

This repository contains a collection of useful scripts and code snippets organized by functionality.

## 📁 Repository Structure

```
.
├── sendmail-scripts/          # Email automation scripts
│   ├── scripts/
│   │   ├── send-mail.sh       # Email sending utility
│   │   ├── sample.env         # Configuration template
│   │   └── .env              # Local config (gitignored)
│   └── README.md             # Detailed documentation
└── .gitignore                # Git ignore rules
```

## 🚀 Available Script Collections

### Email Automation
**Location:** [`sendmail-scripts/`](sendmail-scripts/)
- **Script:** [`send-mail.sh`](sendmail-scripts/scripts/send-mail.sh) - Command-line email utility
- **Template:** [`sample.env`](sendmail-scripts/scripts/sample.env) - Configuration template

For detailed usage instructions and examples, see the [sendmail-scripts README](sendmail-scripts/README.md).

## 📝 Usage

Each script collection contains its own detailed documentation. Navigate to the specific directory and refer to the included README files for setup and usage instructions.

## 🔒 Security Note

Sensitive configuration files (`.env`) are excluded from version control via `.gitignore`. Always use the provided sample templates and customize locally.
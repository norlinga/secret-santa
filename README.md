# 🎄 Secret Santa Pairing Bot

A Ruby application that automatically generates Secret Santa gift pairings and sends personalized email notifications to all participants. Perfect for family gatherings, office parties, or any group gift exchange!

## Features

- 🎲 **Smart Pairing Algorithm** - Automatically pairs gift givers and receivers while respecting exclusion rules
- 📧 **Email Notifications** - Sends personalized emails to each participant with their Secret Santa assignment
- 🔒 **Privacy First** - Keeps pairings secret with separate email delivery to each participant
- ⚙️ **Configurable** - Easy YAML configuration for participants, gift amounts, and event details
- 🎨 **Festive Output** - Beautiful, colorful terminal display for dry-run mode
- 📝 **History Tracking** - Saves pairing history by year for future reference
- ✅ **Well Tested** - Comprehensive test suite with automated testing via Guard

## Quick Start

### Prerequisites

- Ruby 3.0 or higher
- Bundler gem installed

**OR**

- Docker and Make (for containerized deployment)

### Installation

#### Option 1: Native Ruby

1. Clone the repository:
```bash
git clone https://github.com/norlinga/secret-santa.git
cd secret-santa
```

2. Install dependencies:
```bash
bundle install
```

3. Configure your event:
```bash
cp config/event.example.yml config/event.yml
# Edit config/event.yml with your participants
```

4. Set up email credentials:
```bash
cp .env.example .env
# Edit .env with your SMTP settings
```

#### Option 2: Docker (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/norlinga/secret-santa.git
cd secret-santa
```

2. Set up configuration files:
```bash
cp config/event.example.yml config/event.yml
cp .env.example .env
# Edit both files with your details
```

3. Build the Docker image:
```bash
make build
```

That's it! The Docker setup handles all dependencies automatically.

## Configuration

### Event Configuration (`config/event.yml`)

Define your Secret Santa event details:

```yaml
year: 2025
gift_amount: 75

organizer:
  name: Alice
  email: alice@example.com

participants:
  - name: Alice
    email: alice@example.com
    exclude:
      - Bob  # Alice won't be paired with Bob
  
  - name: Bob
    email: bob@example.com
    exclude:
      - Alice
```

**Key Fields:**
- `year` - The year of your event
- `gift_amount` - Maximum dollar amount for gifts
- `organizer` - Who participants should contact with questions
- `participants` - List of all participants with exclusion rules

### Email Configuration (`.env`)

Set up your SMTP server credentials:

```bash
EMAIL_USERNAME='your-email@example.com'
EMAIL_PASSWORD='your-password'
EMAIL_DOMAIN='example.com'
EMAIL_SMTP_ADDRESS='smtp.example.com'
EMAIL_SMTP_PORT=587
EMAIL_ENABLE_SSL=true
DOITLIVE=false
```

**Important:** Keep `DOITLIVE=false` until you're ready to send actual emails!

## Usage

### Docker Usage (Recommended)

The easiest way to use Secret Santa is with the included Makefile:

#### Preview Pairings (Dry Run)
```bash
make run
```

#### Send Emails (Live Mode)
```bash
make send
# You'll be prompted to confirm before emails are sent
```

#### Run Tests
```bash
make test
```

#### Other Commands
```bash
make help    # Show all available commands
make check   # Verify config files exist
make clean   # Remove Docker image
```

**Notes:**
- Configuration files (`.env` and `config/event.yml`) are mounted as read-only
- Pairing history is saved to `~/.secret_santa_pairings/YYYY/`
- Runs as your user (not root) to avoid permission issues

### Native Ruby Usage

If you prefer running without Docker:

#### Dry Run (Preview Pairings)

See the pairings without sending emails:

```bash
ruby app.rb
```

This displays a festive terminal output showing all pairings:

```
🎄 ═══════════════════════════════════════════ 🎄
        Secret Santa Pairing Results!        
🎄 ═══════════════════════════════════════════ 🎄

Gift #1:
  🎁 Alice → Charlie

Gift #2:
  🎁 Bob → Alice
...
```

### Send Emails (Live Mode)

Once you're satisfied with the pairings, send emails:

```bash
# Edit .env and set DOITLIVE=true
ruby app.rb
```

This will:
1. Generate the pairings
2. Send personalized emails to each participant
3. Save pairing history to `pairings/YYYY/pairings_TIMESTAMP.txt`

## Email Template

Customize the email template in `templates/email_body.txt.erb`:

```erb
Hi <%= @giver[:name] %>!

You are the Secret Santa for <%= @receiver[:name] %>!
Please be ready with your wrapped gift valued at $<%= @gift_amount %> or less.

Questions? Contact <%= @organizer['name'] %>.
```

The template supports ERB interpolation with these variables:
- `@giver` - Gift giver's info (name, email)
- `@receiver` - Gift receiver's info (name, email)
- `@organizer` - Organizer's info (name, email)
- `@gift_amount` - Maximum gift amount
- `@year` - Event year

## Development

### Running Tests

Run all tests:
```bash
ruby test/secret_santa_test.rb
ruby test/santa_mailer_test.rb
```

Or use Guard for automatic testing:
```bash
bundle exec guard
```

### Performance Testing

Test the pairing algorithm performance:
```bash
ruby test/performance_test.rb
```

This generates statistics on how many attempts the algorithm needs to find valid pairings.

## Docker Details

### How It Works

The Docker setup provides several advantages:

1. **No Ruby Installation Needed** - Everything runs in a container
2. **Consistent Environment** - Same Ruby version and dependencies every time
3. **Security** - Runs as non-root user (your UID/GID)
4. **Portability** - Run from any directory with make commands
5. **Isolation** - Keeps pairings in `~/.secret_santa_pairings/` outside the project

### Volume Mounts

The Docker container mounts:
- `.env` → Read-only SMTP credentials
- `config/event.yml` → Read-only event configuration
- `~/.secret_santa_pairings/` → Writable pairing history

### Customizing Docker

To use a different Ruby version, edit the `Dockerfile`:
```dockerfile
FROM ruby:3.3-slim  # Change to ruby:3.2-slim, etc.
```

Then rebuild:
```bash
make build
```

## Project Structure

```
secret-santa/
├── app.rb                      # Main application entry point
├── lib/
│   ├── config.rb              # Configuration loader
│   ├── secret_santa.rb        # Pairing algorithm
│   └── santa_mailer.rb        # Email sending
├── config/
│   ├── event.yml              # Your event config (gitignored)
│   └── event.example.yml      # Example configuration
├── templates/
│   └── email_body.txt.erb     # Email template
├── test/
│   ├── secret_santa_test.rb   # Algorithm tests
│   ├── santa_mailer_test.rb   # Mailer tests
│   ├── performance_test.rb    # Performance benchmarks
│   └── test_helper.rb         # Test configuration
└── pairings/                   # Pairing history (gitignored)
    └── YYYY/
        └── pairings_TIMESTAMP.txt
```

## How It Works

1. **Configuration Loading** - Reads event details and participant list from `config/event.yml`
2. **Pairing Algorithm** - Randomly shuffles participants and validates:
   - No one is paired with themselves
   - Exclusion rules are respected (spouses, previous years, etc.)
   - Repeats shuffling if validation fails
3. **Email Delivery** - Sends personalized emails to each giver with their receiver's name
4. **History Tracking** - Saves pairings by year for future reference

## Tips

- **Exclusion Lists**: Use the `exclude` field to prevent specific pairings (spouses, previous year pairings, etc.)
- **Test First**: Always run in dry-run mode (`DOITLIVE=false`) before sending real emails
- **History**: Check `pairings/YYYY/` directories to avoid repeating pairings from previous years
- **Email Testing**: Test with your own email addresses first to verify templates look correct

## Security Notes

- Never commit `.env` or `config/event.yml` to version control
- These files contain sensitive information (emails, passwords)
- The `.gitignore` is pre-configured to protect these files
- Pairing history is also gitignored to protect participant privacy

## License

This project is open source and available for personal use.

## Contributing

Feel free to submit issues or pull requests to improve the Secret Santa bot!

---

Made with ❤️ for stress-free Secret Santa gift exchanges!

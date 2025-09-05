#!/bin/bash

# A reusable command-line script for sending emails with attachments
# using curl. Supports SMTPS (port 465) and STARTTLS (port 587).

# Exit immediately if a command exits with a non-zero status.
set -e

# --- SCRIPT SETUP ---
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# --- HELP FUNCTION ---
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --to <email>          Recipient's email address. Can be specified multiple times."
    echo "  --subject <subject>     The subject line of the email."
    echo "  --html-body <path>      Path to a file containing the HTML body."
    echo "  --text-body <string>    A string for the plain text body. Use instead of --html-body."
    echo "  --attach <path>         Path to a file to attach. Can be specified multiple times."
    echo "  --help                  Display this help message."
    echo ""
    echo "Example: Sending an HTML email with an attachment"
    echo "  $0 --to user@example.com --subject \"Report\" --html-body report.html --attach data.zip"
}

# --- PARSE COMMAND-LINE ARGUMENTS ---
TO_EMAILS=()
ATTACHMENTS=()
SUBJECT=""
HTML_BODY_FILE=""
TEXT_BODY=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --to) TO_EMAILS+=("$2"); shift 2 ;;
        --subject) SUBJECT="$2"; shift 2 ;;
        --html-body) HTML_BODY_FILE="$2"; shift 2 ;;
        --text-body) TEXT_BODY="$2"; shift 2 ;;
        --attach) ATTACHMENTS+=("$2"); shift 2 ;;
        --help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# --- VALIDATE INPUTS ---
if [ ${#TO_EMAILS[@]} -eq 0 ]; then
    echo "Error: At least one recipient must be specified with --to." >&2; exit 1
fi
if [ -z "$SUBJECT" ]; then
    echo "Error: A subject must be specified with --subject." >&2; exit 1
fi
if [ -z "$HTML_BODY_FILE" ] && [ -z "$TEXT_BODY" ]; then
    echo "Error: An email body must be provided with --html-body or --text-body." >&2; exit 1
fi
if [ -n "$HTML_BODY_FILE" ] && [ ! -r "$HTML_BODY_FILE" ]; then
    echo "Error: HTML body file not found or not readable: $HTML_BODY_FILE" >&2; exit 1
fi
for ATTACH_FILE in "${ATTACHMENTS[@]}"; do
    if [ ! -r "$ATTACH_FILE" ]; then
        echo "Error: Attachment file not found or not readable: $ATTACH_FILE" >&2; exit 1
    fi
done

# --- LOAD ENVIRONMENT VARIABLES ---
if [ -f "$DIR/.env" ]; then
    source "$DIR/.env"
else
    echo "Error: .env file not found in the script directory: $DIR" >&2; exit 1
fi

# --- CONFIGURE CURL BASED ON PORT ---
if [ "$SMTP_PORT" == "465" ]; then
    CURL_URL="smtps://$SMTP_SERVER:$SMTP_PORT"
elif [ "$SMTP_PORT" == "587" ]; then
    CURL_URL="smtp://$SMTP_SERVER:$SMTP_PORT"
    # Note: --ssl-reqd is the old name for --proto-default smtps, it forces STARTTLS
    CURL_EXTRA_FLAGS="--ssl-reqd"
else
    echo "Error: Unsupported SMTP_PORT in .env. Use 465 (SMTPS) or 587 (STARTTLS)." >&2; exit 1
fi

# --- PREPARE EMAIL ---
echo "Preparing multipart email..."
MIME_PAYLOAD_FILE=$(mktemp)
trap 'rm -f "$MIME_PAYLOAD_FILE"' EXIT

BOUNDARY="--_Boundary_$(date +%s)_$$"
TO_HEADER=$(IFS=, ; echo "${TO_EMAILS[*]}")

# 1. Main Headers
{
    echo "From: $SMTP_FROM_NAME <$SMTP_FROM_EMAIL>"
    echo "To: $TO_HEADER"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type: multipart/mixed; boundary=\"$BOUNDARY\""
    echo ""
    echo "This is a multi-part message in MIME format."
    echo ""
} > "$MIME_PAYLOAD_FILE"

# 2. Email Body Part
{
    echo "--$BOUNDARY"
    if [ -n "$HTML_BODY_FILE" ]; then
        echo "Content-Type: text/html; charset=UTF-8"
        echo ""
        cat "$HTML_BODY_FILE"
    else
        echo "Content-Type: text/plain; charset=UTF-8"
        echo ""
        echo "$TEXT_BODY"
    fi
    echo "" # Add a newline for safety
} >> "$MIME_PAYLOAD_FILE"

# 3. Attachment Parts
for ATTACH_FILE in "${ATTACHMENTS[@]}"; do
    FILENAME=$(basename "$ATTACH_FILE")
    # Guessing MIME type is complex, application/octet-stream is a safe default
    MIME_TYPE=$(file --brief --mime-type "$ATTACH_FILE")
    {
        echo "--$BOUNDARY"
        echo "Content-Type: $MIME_TYPE; name=\"$FILENAME\""
        echo "Content-Transfer-Encoding: base64"
        echo "Content-Disposition: attachment; filename=\"$FILENAME\""
        echo ""
        base64 "$ATTACH_FILE"
        echo ""
    } >> "$MIME_PAYLOAD_FILE"
done

# 4. Final Closing Boundary
echo "--$BOUNDARY--" >> "$MIME_PAYLOAD_FILE"

# --- SEND EMAIL ---
echo "Sending email to $TO_HEADER..."

CURL_RECIPIENTS=()
for recipient in "${TO_EMAILS[@]}"; do
    CURL_RECIPIENTS+=('--mail-rcpt' "$recipient")
done

curl --url "$CURL_URL" $CURL_EXTRA_FLAGS \
     --user "$SMTP_USERNAME:$SMTP_PASSWORD" \
     --mail-from "$SMTP_FROM_EMAIL" \
     "${CURL_RECIPIENTS[@]}" \
     -T "$MIME_PAYLOAD_FILE"

echo -e "\nEmail sent successfully."
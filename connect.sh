#!/bin/bash
# ============================================
# Oracle Cloud Connection Helper
# ============================================

# Load environment variables
if [ -f .env ]; then
    set -a
    # shellcheck source=/dev/null
    . .env
    set +a
fi

# Set paths
export PATH="/opt/homebrew/Caskroom/sqlcl/26.1.0.086.1709/sqlcl/bin:$PATH"
export TNS_ADMIN=~/.oracle/wallet

# Connection shortcuts
alias sqlbank='sql BANK_SCHEMA/SecurePass123!@bankdb_high'
alias sqladmin='sql ADMIN/SecurePass123!@bankdb_high'

# Usage information
function usage() {
    echo "Oracle Cloud Connection Helper"
    echo ""
    echo "Usage:"
    echo "  ./connect.sh                    # Show this help"
    echo "  ./connect.sh bank               # Connect as BANK_SCHEMA (interactive)"
    echo "  ./connect.sh admin              # Connect as ADMIN (interactive)"
    echo "  ./connect.sh run <script.sql>   # Run script as BANK_SCHEMA"
    echo ""
    echo "Direct SQL*Plus:"
    echo "  sql BANK_SCHEMA/SecurePass123!@bankdb_high"
    echo "  sql ADMIN/SecurePass123!@bankdb_high"
    echo ""
    echo "Run script:"
    echo "  sql BANK_SCHEMA/SecurePass123!@bankdb_high < sql/01-creare_inserare.sql"
}

# Main logic
case "$1" in
    bank)
        sql BANK_SCHEMA/SecurePass123!@bankdb_high
        ;;
    admin)
        sql ADMIN/SecurePass123!@bankdb_high
        ;;
    run)
        if [ -z "$2" ]; then
            echo "Error: Please specify a SQL script"
            echo "Usage: ./connect.sh run <script.sql>"
            exit 1
        fi
        sql BANK_SCHEMA/SecurePass123!@bankdb_high < "$2"
        ;;
    test)
        echo "Testing connection..."
        echo "SELECT 'Connection OK!' AS status FROM DUAL;" | sql -S BANK_SCHEMA/SecurePass123!@bankdb_high
        ;;
    *)
        usage
        ;;
esac

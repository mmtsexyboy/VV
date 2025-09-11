#!/bin/bash
# This script runs the necessary setup commands for the forum application.

echo "--- Running Database Migrations ---"
python manage.py migrate

echo ""
read -p "Do you want to create a superuser? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "--- Creating Superuser ---"
    python manage.py createsuperuser
fi

echo ""
echo "--- Setup Complete ---"
echo "You can now run the server with: python manage.py runserver"

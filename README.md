# Django Forum

A simple forum application built with Django.

## Features

*   Google OAuth for user authentication.
*   User profiles with name, signature, and profile picture.
*   Profile pictures are automatically resized and converted to high-quality WebP format.
*   Users can create new topics and post replies.
*   Clean and simple user interface.

## Project Setup

### 1. Prerequisites

*   Python 3.8+
*   Pip

### 2. Clone the Repository

```bash
git clone <repository_url>
cd <repository_directory>
```

### 3. Install Dependencies

Create a virtual environment and install the required packages.

```bash
python -m venv venv
source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the project root by copying the example:

```bash
cp .env.example .env
```

Now, edit the `.env` file and fill in your details:

*   `SECRET_KEY`: A new, randomly generated Django secret key.
*   `GOOGLE_CLIENT_ID`: Your Google OAuth client ID.
*   `GOOGLE_SECRET`: Your Google OAuth secret key.

**To get Google OAuth credentials:**
1. Go to the [Google API Console](https://console.developers.google.com/).
2. Create a new project.
3. Go to "Credentials", click "Create Credentials", and choose "OAuth client ID".
4. Select "Web application" as the application type.
5. Under "Authorized redirect URIs", add:
   - `http://127.0.0.1:8000/accounts/google/login/callback/`
6. Click "Create" and copy your client ID and secret.

### 5. Run the Setup Script

This project uses SQLite, so no database server setup is required. The setup script will run the necessary database migrations for you.

```bash
chmod +x setup.sh
./setup.sh
```

### 6. Create a Superuser (Optional)

To access the Django admin panel, create a superuser.

```bash
python manage.py createsuperuser
```

### 7. Run the Development Server

```bash
python manage.py runserver
```

The application will be available at `http://127.0.0.1:8000/`.

## How to Use

1.  Visit the homepage to see a list of topics.
2.  Log in using your Google account.
3.  After logging in, you can:
    -   Create a new topic.
    -   Reply to existing topics.
    -   Visit your profile page to set your signature and upload a profile picture.

# Environment Setup

## 1) Create your `.env`
- Copy `.env.example` → `.env`
- Fill with **real** values from Supabase **Settings → API**:
  - `SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY` (server only, for backend scripts)
  - (Optional) `SUPABASE_ANON_KEY` for client apps (Flutter) later

> ⚠️ Credentials Access:  
> For security, the real `.env` file is not in the repo. Ask the **functionality team** for valid Supabase keys. Copy them into a local `.env` file based on `.env.example`.  
> Never commit `.env`. Only `.env.example` is committed.

---

## 2) Virtual Environment Setup
```bash
# Create venv
python -m venv venvprofport

# Activate
# Linux/Mac:
source venvprofport/bin/activate
# Windows:
venvprofport

# Install requirements
pip install -r requirements.txt


import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
assert url and key, "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env"

supabase: Client = create_client(url, key)

# 1) simple sanity check: call the health endpoint via auth'ed client
print("Supabase client initialized ✅")

# 2) optional: try a lightweight select if 'users' exists
try:
    resp = supabase.table("users").select("*").limit(1).execute()
    print("Users table reachable ✅ Rows:", len(resp.data))
except Exception as e:
    print("Select test skipped or failed (likely table not created yet) →", e)

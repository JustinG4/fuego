# Supabase Setup Instructions

## Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Sign up/Sign in
3. Click "New Project"
4. Fill in:
   - Name: `unlockengine`
   - Database Password: (SAVE THIS!)
   - Region: US West (or closest to you)
5. Click "Create new project"
6. Wait ~2 minutes for provisioning

## Step 2: Get Your Credentials

Once project is ready:

1. Go to Project Settings (gear icon) → API
2. Copy these values:

```
Project URL: https://xxxxx.supabase.co
anon public key: eyJhbGci...
service_role key: eyJhbGci... (keep secret!)
```

3. Save these in `.env.local` files (next step)

## Step 3: Run Database Schema

1. In Supabase dashboard, click "SQL Editor"
2. Click "New Query"
3. Paste the schema from `supabase-schema.sql`
4. Click "Run"
5. Should see "Success. No rows returned"

## Step 4: Configure Apps

### Admin App
Create `/Users/justingreenfield/Desktop/47/fuego/unlockengine/admin/.env.local`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
```

### Customer App
Create `/Users/justingreenfield/Desktop/47/fuego/unlockengine/customer-app/.env.local`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
```

## Step 5: Verify Connection

Restart both apps:
```bash
# Terminal 1 - Admin
cd admin
npm run dev

# Terminal 2 - Customer
cd customer-app
npm run dev
```

Check browser console for any Supabase errors.

---

## Troubleshooting

### Can't connect to Supabase
- Check URL is correct (includes https://)
- Verify anon key is pasted completely
- Check project is active in Supabase dashboard

### SQL errors
- Make sure you're in SQL Editor, not Table Editor
- Run schema line by line if errors occur
- Check for typos in table names

---

**Once done, come back and we'll connect the apps!**

# UnlockEngine Setup Checklist

Quick guide to verify everything is working.

---

## ✅ Pre-Flight Checklist

### 1. Supabase Project Setup

- [ ] Created Supabase account at https://supabase.com
- [ ] Created new project named "unlockengine"
- [ ] Have Project URL (looks like: `https://xxxxx.supabase.co`)
- [ ] Have anon public key (starts with `eyJhbGci...`)

### 2. Environment Variables

- [ ] Admin app has `.env.local` with:
  ```
  NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
  NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
  ```

- [ ] Customer app has `.env.local` with:
  ```
  NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
  NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
  ```

### 3. Database Schema Loaded

In Supabase Dashboard → SQL Editor:

- [ ] Ran `supabase-schema.sql` (creates tables)
  - Click "New Query"
  - Paste entire schema file
  - Click "Run"
  - Should see: "Success. No rows returned"

- [ ] Ran `seed-fuego-data.sql` (adds FUEGO demo data)
  - Click "New Query"
  - Paste entire seed file
  - Click "Run"
  - Should see: "Success" message

### 4. Verify Database Data

In Supabase Dashboard → Table Editor:

- [ ] `tenants` table has 1 row (FUEGO)
- [ ] `milestone_tiers` table has 4 rows (SPARK, FLAME, INFERNO, LEGEND)
- [ ] `milestones` table has ~12 rows
- [ ] `products` table has ~15 rows
- [ ] `metrics` table has ~4 rows

---

## 🚀 Test Both Apps

### Admin App (localhost:3001)

#### Test 1: Dashboard Home
```
URL: http://localhost:3001
```
- [ ] Page loads without errors
- [ ] Shows "Welcome to UnlockEngine"
- [ ] Stats cards display
- [ ] No console errors (open DevTools → Console)

#### Test 2: Milestones Page
```
URL: http://localhost:3001/milestones
```
- [ ] Shows "Connected to Supabase ✅" in stats
- [ ] Displays 4 tiers (SPARK, FLAME, INFERNO, LEGEND)
- [ ] Each tier shows milestones
- [ ] Total milestone count matches database

#### Test 3: Create a Milestone
- [ ] Click "Create Milestone" button
- [ ] Modal opens
- [ ] Fill in form:
  - Name: "5K Walk"
  - Description: "Walk 5 kilometers"
  - Tier: SPARK
  - Display Order: 10
  - Add requirement: metricId=test, operator=gte, value=5000
  - Reward Message: "Great job!"
- [ ] Click "Create Milestone"
- [ ] Modal closes
- [ ] New milestone appears in SPARK tier
- [ ] **Open browser Console and check for errors**

#### Test 4: Products Page
```
URL: http://localhost:3001/products
```
- [ ] Products grid displays
- [ ] Stats show correct counts
- [ ] Products have images (or placeholders)

#### Test 5: Create a Product
- [ ] Click "Add Product" button
- [ ] Modal opens
- [ ] Fill in form:
  - Name: "Test Sneakers"
  - Description: "Limited edition test sneakers"
  - Price: 129.99
  - Category: "Footwear"
  - Add image URL (optional): `https://via.placeholder.com/400`
- [ ] Click "Create Product"
- [ ] Modal closes
- [ ] New product appears in grid

#### Test 6: Metrics Page
```
URL: http://localhost:3001/metrics
```
- [ ] Metrics list displays
- [ ] Shows sources (healthkit, manual, etc.)
- [ ] Shows categories

---

### Customer App (localhost:3002)

#### Test 1: Home Page
```
URL: http://localhost:3002
```
- [ ] Page loads without errors
- [ ] Shows FUEGO branding
- [ ] No console errors

#### Test 2: Milestones Page
```
URL: http://localhost:3002/milestones
```
- [ ] Shows "Connected to Supabase" message
- [ ] Displays all 4 tiers with colors
- [ ] Shows all milestones including test one you created
- [ ] Progress bars display
- [ ] Lock/unlock icons show

#### Test 3: Products Page
```
URL: http://localhost:3002/products
```
- [ ] Products display in grid
- [ ] Shows lock states
- [ ] Test product you created appears

---

## 🔄 Test Real-Time Sync

### Simple Manual Test

1. **Setup**:
   - [ ] Open admin app in one browser tab/window
   - [ ] Open customer app in another tab/window
   - [ ] Arrange windows side-by-side

2. **Create Milestone in Admin**:
   - [ ] In admin, create new milestone:
     - Name: "Real-Time Test"
     - Description: "Testing sync"
     - Tier: FLAME
   - [ ] Click Create

3. **Check Customer App**:
   - [ ] Refresh customer app page
   - [ ] New "Real-Time Test" milestone should appear
   - [ ] Should be in FLAME tier

4. **Create Product in Admin**:
   - [ ] In admin, create new product:
     - Name: "Sync Test Product"
     - Price: 49.99
   - [ ] Click Create

5. **Check Customer App**:
   - [ ] Refresh customer products page
   - [ ] New product should appear

**✅ If data appears after refresh, sync is working!**

---

## 🐛 Troubleshooting

### Apps Won't Start

```bash
cd admin
rm -rf .next node_modules
npm install
npm run dev
```

### "Missing Supabase environment variables"

- Check `.env.local` exists in both `admin/` and `customer-app/`
- Check file contains correct URL and KEY
- Restart dev servers after adding .env.local

### "FUEGO tenant not found" Error

- Database schema not loaded
- Go to Supabase → SQL Editor
- Run `supabase-schema.sql`
- Run `seed-fuego-data.sql`

### Modal Doesn't Open

- Check browser console for JavaScript errors
- Check component import paths
- Clear Next.js cache: `rm -rf .next`

### Data Doesn't Appear

1. Check Supabase Dashboard → Table Editor
2. Verify tables have data
3. Check browser Network tab for failed API calls
4. Look for CORS errors in console

### Can't Create Milestones/Products

- Check browser console for detailed error
- Check Supabase Row Level Security (RLS) is disabled (for now)
- Go to Supabase → Authentication → Policies
- Ensure tables don't have restrictive policies

---

## 📊 Expected Results

After completing this checklist:

- ✅ Admin app displays all FUEGO data
- ✅ Can create new milestones
- ✅ Can create new products
- ✅ Customer app shows all data
- ✅ Changes in admin appear in customer (after refresh)
- ✅ No console errors in either app
- ✅ Both apps running smoothly

---

## 🎯 Next Steps After Verification

Once everything is working:

1. **Day 2 Tasks**:
   - Add multi-tenant support
   - Create tenant signup flow
   - Generate API keys

2. **Improvements**:
   - Add edit/delete functionality
   - Implement real-time subscriptions (no refresh needed)
   - Add image upload instead of URL input
   - Add form validation

3. **Testing**:
   - Create more milestones and products
   - Test edge cases
   - Try filtering and search

---

## 💡 Pro Tips

1. **Keep DevTools Open**: Browser Console shows helpful errors
2. **Check Network Tab**: See all API calls to Supabase
3. **Use Supabase Logs**: Dashboard → Logs shows all database queries
4. **Test Incrementally**: Verify each step before moving on
5. **Save .env.local**: Back it up - losing keys means reconfiguring

---

**Questions or Issues?** Check:
- `DAY_1_PROGRESS.md` for current status
- Browser console for errors
- Supabase Dashboard → Logs for database errors
- Next.js error messages in terminal

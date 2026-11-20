class SupabaseConfig {
  // Production Supabase Project Credentials
  static const String defaultUrl = 'https://gicsovaxzytoiuigcsji.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_tF0GQ5GLvhEvzFw1mk3rQw_ahCKjgFf';

  // Table names
  static const String tableShops = 'shops';
  static const String tableProducts = 'products';
  static const String tableCompetitors = 'competitors';
  static const String tableSavedResearch = 'saved_research';
  static const String tableResearchActivity = 'research_activity';
  static const String tableProfiles = 'profiles';

  // Complete PostgreSQL Schema ready for the Supabase SQL Editor
  static const String supabaseSetupSql = '''
-- ============================================================
-- SHOP SCRAPER PRO - SUPABASE BACKEND SCHEMA
-- Execute this script in your Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- 1. SHOPS TABLE
CREATE TABLE IF NOT EXISTS public.shops (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    marketplace TEXT NOT NULL, -- 'Etsy', 'Amazon', 'eBay', 'Shopify'
    url TEXT NOT NULL,
    logo_url TEXT,
    rating NUMERIC(3, 2) DEFAULT 4.5,
    review_count INTEGER DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    monthly_revenue_est NUMERIC(12, 2) DEFAULT 0.00,
    country TEXT DEFAULT 'United States',
    open_year INTEGER DEFAULT 2021,
    total_listings INTEGER DEFAULT 0,
    avg_price NUMERIC(10, 2) DEFAULT 0.00,
    top_categories TEXT[] DEFAULT '{}',
    top_tags TEXT[] DEFAULT '{}',
    badges TEXT[] DEFAULT '{}',
    is_saved BOOLEAN DEFAULT FALSE,
    opportunity_score INTEGER DEFAULT 75,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    shop_id TEXT,
    shop_name TEXT NOT NULL,
    marketplace TEXT NOT NULL,
    title TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    original_price NUMERIC(10, 2),
    currency TEXT DEFAULT '\$',
    rating NUMERIC(3, 2) DEFAULT 4.5,
    review_count INTEGER DEFAULT 0,
    sales_estimate INTEGER DEFAULT 0,
    monthly_revenue NUMERIC(12, 2) DEFAULT 0.00,
    opportunity_score INTEGER DEFAULT 80,
    saturation_level TEXT DEFAULT 'Medium',
    competition_score NUMERIC(3, 1) DEFAULT 2.5,
    category TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    description TEXT,
    image_urls TEXT[] DEFAULT '{}',
    stock_status TEXT DEFAULT 'In Stock',
    is_saved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. COMPETITORS TABLE
CREATE TABLE IF NOT EXISTS public.competitors (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    marketplace TEXT NOT NULL,
    url TEXT NOT NULL,
    rating NUMERIC(3, 2) DEFAULT 4.5,
    sales_count INTEGER DEFAULT 0,
    price_advantage NUMERIC(5, 2) DEFAULT 0.00,
    monthly_revenue_est NUMERIC(12, 2) DEFAULT 0.00,
    overlap_percentage INTEGER DEFAULT 50,
    strength_summary TEXT,
    weak_points TEXT[] DEFAULT '{}',
    top_categories TEXT[] DEFAULT '{}',
    product_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. SAVED RESEARCH TABLE
CREATE TABLE IF NOT EXISTS public.saved_research (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL, -- 'shop' or 'product'
    item_id TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. RESEARCH ACTIVITY TABLE
CREATE TABLE IF NOT EXISTS public.research_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    platform TEXT NOT NULL,
    icon_name TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. USER PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    company_name TEXT,
    plan_tier TEXT DEFAULT 'Professional SaaS Plan',
    monthly_quota INTEGER DEFAULT 500,
    quota_used INTEGER DEFAULT 42,
    preferred_currency TEXT DEFAULT 'USD (\$) ',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ENABLE ROW LEVEL SECURITY
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_research ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- PUBLIC ACCESS POLICIES (Allows read & write for app users)
CREATE POLICY "Public shops read access" ON public.shops FOR SELECT USING (true);
CREATE POLICY "Public shops insert access" ON public.shops FOR INSERT WITH CHECK (true);
CREATE POLICY "Public shops update access" ON public.shops FOR UPDATE USING (true);

CREATE POLICY "Public products read access" ON public.products FOR SELECT USING (true);
CREATE POLICY "Public products insert access" ON public.products FOR INSERT WITH CHECK (true);
CREATE POLICY "Public products update access" ON public.products FOR UPDATE USING (true);

CREATE POLICY "Public competitors read access" ON public.competitors FOR SELECT USING (true);
CREATE POLICY "Public competitors insert access" ON public.competitors FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can manage own saved research" ON public.saved_research FOR ALL USING (auth.uid() = user_id OR auth.uid() IS NULL);
CREATE POLICY "Users can view activities" ON public.research_activity FOR ALL USING (auth.uid() = user_id OR auth.uid() IS NULL);
CREATE POLICY "Users can manage own profile" ON public.profiles FOR ALL USING (auth.uid() = id);
''';
}


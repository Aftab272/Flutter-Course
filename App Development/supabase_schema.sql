-- ============================================================
-- SHOP SCRAPER PRO - SUPABASE BACKEND SCHEMA & SEED DATA
-- Copy and run this script in your Supabase SQL Editor
-- (Supabase Dashboard -> Project -> SQL Editor -> New Query -> Run)
-- ============================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. SHOPS TABLE
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

-- 3. PRODUCTS TABLE
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

-- 4. COMPETITORS TABLE
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

-- 5. SAVED RESEARCH TABLE
CREATE TABLE IF NOT EXISTS public.saved_research (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL, -- 'shop' or 'product'
    item_id TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. RESEARCH ACTIVITY TABLE
CREATE TABLE IF NOT EXISTS public.research_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    platform TEXT NOT NULL,
    icon_name TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);


-- 7. USER PROFILES TABLE
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

-- 8. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_research ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 9. PERMISSIVE POLICIES FOR APPLICATION CLIENT
CREATE POLICY "Public read shops" ON public.shops FOR SELECT USING (true);
CREATE POLICY "Public insert shops" ON public.shops FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update shops" ON public.shops FOR UPDATE USING (true);

CREATE POLICY "Public read products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Public insert products" ON public.products FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update products" ON public.products FOR UPDATE USING (true);

CREATE POLICY "Public read competitors" ON public.competitors FOR SELECT USING (true);
CREATE POLICY "Public insert competitors" ON public.competitors FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow saved research" ON public.saved_research FOR ALL USING (true);
CREATE POLICY "Allow research activity" ON public.research_activity FOR ALL USING (true);
CREATE POLICY "Allow profiles" ON public.profiles FOR ALL USING (true);

-- 10. INITIAL SAMPLE DATA SEEDING
INSERT INTO public.shops (id, name, marketplace, url, rating, review_count, total_sales, monthly_revenue_est, country, open_year, total_listings, avg_price, top_categories, top_tags, badges, is_saved, opportunity_score, description)
VALUES 
('shop_etsy_01', 'Artisan Leather Co.', 'Etsy', 'https://etsy.com/shop/artisanleather', 4.9, 1420, 18500, 32400.00, 'United States', 2018, 145, 68.50, ARRAY['Accessories', 'Bags', 'Wallets'], ARRAY['handmade', 'leather', 'custom gift', 'minimalist'], ARRAY['Star Seller', 'Top 1% Seller', 'Fast Shipper'], true, 88, 'Handcrafted full-grain leather everyday carry essentials.'),
('shop_amz_01', 'ErgoCraft Studio', 'Amazon', 'https://amazon.com/shops/ergocraft', 4.6, 3890, 42000, 125000.00, 'United States', 2020, 84, 89.00, ARRAY['Office Products', 'Furniture', 'Desk Accessories'], ARRAY['ergonomic', 'standing desk', 'home office', 'cable management'], ARRAY['Prime Eligible', 'Amazon Choice', 'Carbon Neutral'], false, 82, 'Ergonomic workspace accessories engineered for deep focus.'),
('shop_ebay_01', 'Vintage Vault Curations', 'eBay', 'https://ebay.com/usr/vintagevault', 4.8, 890, 9400, 18600.00, 'United Kingdom', 2017, 310, 45.00, ARRAY['Collectibles', 'Watches', 'Antiques'], ARRAY['rare finds', 'retro watch', 'vintage mechanical'], ARRAY['Top Rated Plus', 'Authenticity Guarantee'], false, 74, 'Verified vintage timepieces and rare heritage goods.'),
('shop_shpfy_01', 'Nordic Glow Botanicals', 'Shopify', 'https://nordicglow.store', 4.9, 5600, 31000, 84500.00, 'Sweden', 2021, 42, 38.00, ARRAY['Skincare', 'Beauty', 'Wellness'], ARRAY['clean beauty', 'organic serum', 'cruelty-free'], ARRAY['Direct to Consumer', 'Eco Certified'], true, 91, 'Minimalist organic Scandinavian skincare and botanical remedies.')
ON CONFLICT (id) DO NOTHING;


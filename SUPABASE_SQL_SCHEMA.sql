-- ============================================================================
-- QUEUELESS - SUPABASE SQL SCHEMA
-- URL: https://otlsioixomyttxrfimie.supabase.co
-- Run this in your Supabase SQL Editor
-- ============================================================================

-- 1. CREATE PROFILES TABLE (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  profile_image_url TEXT,
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Away')),
  total_visits INT DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.0,
  favorite_count INT DEFAULT 0,
  join_date TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2. CREATE LOCATIONS TABLE
CREATE TABLE IF NOT EXISTS locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  category TEXT,
  phone TEXT,
  operating_hours TEXT,
  average_wait_time INT DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.0,
  total_reviews INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. CREATE FAVORITES TABLE
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  added_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, location_id)
);

-- 4. CREATE QUEUE RECORDS TABLE
CREATE TABLE IF NOT EXISTS queue_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  check_in_time TIMESTAMP NOT NULL DEFAULT NOW(),
  check_out_time TIMESTAMP,
  wait_time_minutes INT,
  notes TEXT,
  status TEXT DEFAULT 'checked_in' CHECK (status IN ('checked_in', 'checked_out', 'cancelled')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 5. CREATE REVIEWS TABLE
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);
CREATE INDEX idx_locations_category ON locations(category);
CREATE INDEX idx_locations_is_active ON locations(is_active);
CREATE INDEX idx_locations_created_by ON locations(created_by);
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_location_id ON favorites(location_id);
CREATE INDEX idx_queue_records_user_id ON queue_records(user_id);
CREATE INDEX idx_queue_records_location_id ON queue_records(location_id);
CREATE INDEX idx_queue_records_check_in_time ON queue_records(check_in_time);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_location_id ON reviews(location_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE queue_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PROFILES TABLE POLICIES
-- ============================================================================

-- Anyone can view public profile info
CREATE POLICY "Profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete their own profile" ON profiles
  FOR DELETE USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================================
-- LOCATIONS TABLE POLICIES
-- ============================================================================

-- Anyone can view active locations
CREATE POLICY "Active locations are viewable by everyone" ON locations
  FOR SELECT USING (is_active = true);

-- Authenticated users can create locations
CREATE POLICY "Authenticated users can create locations" ON locations
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Location creators can update their locations
CREATE POLICY "Location creators can update their locations" ON locations
  FOR UPDATE USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- ============================================================================
-- FAVORITES TABLE POLICIES
-- ============================================================================

-- Users can view their own favorites
CREATE POLICY "Users can view their own favorites" ON favorites
  FOR SELECT USING (auth.uid() = user_id);

-- Users can add to their favorites
CREATE POLICY "Users can add to their favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can remove from their favorites
CREATE POLICY "Users can remove from their favorites" ON favorites
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- QUEUE RECORDS TABLE POLICIES
-- ============================================================================

-- Users can view their own queue records
CREATE POLICY "Users can view their own queue records" ON queue_records
  FOR SELECT USING (auth.uid() = user_id);

-- Users can create queue records for themselves
CREATE POLICY "Users can create queue records for themselves" ON queue_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own queue records
CREATE POLICY "Users can update their own queue records" ON queue_records
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- REVIEWS TABLE POLICIES
-- ============================================================================

-- Anyone can view reviews
CREATE POLICY "Reviews are viewable by everyone" ON reviews
  FOR SELECT USING (true);

-- Users can create reviews
CREATE POLICY "Users can create reviews" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own reviews
CREATE POLICY "Users can update their own reviews" ON reviews
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete their own reviews" ON reviews
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- CREATE TRIGGER FOR UPDATED_AT TIMESTAMP
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to locations table
DROP TRIGGER IF EXISTS update_locations_updated_at ON locations;
CREATE TRIGGER update_locations_updated_at
    BEFORE UPDATE ON locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to queue_records table
DROP TRIGGER IF EXISTS update_queue_records_updated_at ON queue_records;
CREATE TRIGGER update_queue_records_updated_at
    BEFORE UPDATE ON queue_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to reviews table
DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- OPTIONAL: INSERT SAMPLE DATA FOR TESTING
-- ============================================================================

-- Insert sample locations
INSERT INTO locations (name, description, address, latitude, longitude, category, phone, average_wait_time, average_rating)
VALUES 
  ('Downtown Hospital', 'Main hospital in the city center', '123 Main St, City', 40.7128, -74.0060, 'Healthcare', '+1-555-0100', 15, 4.5),
  ('City Bank Branch', 'Primary banking location', '456 Finance Ave, City', 40.7129, -74.0061, 'Banking', '+1-555-0101', 8, 4.2),
  ('Shopping Mall', 'Central shopping destination', '789 Mall Rd, City', 40.7130, -74.0062, 'Shopping', '+1-555-0102', 20, 4.0)
ON CONFLICT DO NOTHING;

COMMIT;

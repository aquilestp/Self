-- Widget popularity tracking tables
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS widget_popularity (
    widget_type TEXT PRIMARY KEY,
    use_count BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_widget_recents (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    widget_type TEXT NOT NULL,
    last_used_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, widget_type)
);

CREATE INDEX IF NOT EXISTS idx_user_widget_recents_user
    ON user_widget_recents(user_id, last_used_at DESC);

ALTER TABLE widget_popularity ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_widget_recents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read widget popularity"
    ON widget_popularity FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can insert widget popularity"
    ON widget_popularity FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update widget popularity"
    ON widget_popularity FOR UPDATE
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can read own recents"
    ON user_widget_recents FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert own recents"
    ON user_widget_recents FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recents"
    ON user_widget_recents FOR UPDATE
    USING (auth.uid() = user_id);

-- Atomic increment function
CREATE OR REPLACE FUNCTION increment_widget_popularity(p_widget_types TEXT[])
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO widget_popularity (widget_type, use_count)
    SELECT unnest(p_widget_types), 1
    ON CONFLICT (widget_type)
    DO UPDATE SET use_count = widget_popularity.use_count + 1;
END;
$$;

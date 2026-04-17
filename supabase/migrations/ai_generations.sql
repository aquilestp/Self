-- AI generation usage tracking (free quota: 10 images / 2 videos per rolling 30 days)
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS ai_generations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    kind TEXT NOT NULL CHECK (kind IN ('image', 'video')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_generations_user_kind_created
    ON ai_generations(user_id, kind, created_at DESC);

ALTER TABLE ai_generations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own ai generations"
    ON ai_generations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ai generations"
    ON ai_generations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS edit_style_prompts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    style_key TEXT NOT NULL UNIQUE,
    prompt_template TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE edit_style_prompts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated read" ON edit_style_prompts
    FOR SELECT TO authenticated USING (true);

INSERT INTO edit_style_prompts (style_key, prompt_template) VALUES
    ('fast', 'Quickly enhance this image with improved lighting, contrast, and color balance'),
    ('distortion', 'Apply a surreal distortion effect with warped perspectives and liquid-like deformations'),
    ('blur', 'Create a dreamy soft-focus effect with artistic bokeh and gentle gaussian blur'),
    ('sketch', 'Transform this into a detailed pencil sketch with cross-hatching, shading, and fine line work'),
    ('cartoon', 'Convert this into a vibrant cartoon style with bold outlines, flat colors, and exaggerated features'),
    ('glitch', 'Apply a digital glitch art effect with RGB channel splitting, scan lines, and data corruption artifacts'),
    ('dramatic', 'Enhance with dramatic high-contrast lighting, deep shadows, and intense cinematic mood'),
    ('cinematica', 'Transform into a cinematic still frame with film grain, anamorphic lens flare, and teal-orange color grading')
ON CONFLICT (style_key) DO NOTHING;

-- ============================================================================
-- SPOTIFY-LIKE DATABASE SCHEMA
-- Database: PostgreSQL
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================
-- Enable pg_trgm extension for fuzzy text search (trigram matching)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================================
-- TABLE: users
-- Purpose: Stores user account information including authentication and profile data
-- ============================================================================
CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,
    username        VARCHAR(50) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    display_name    VARCHAR(100),
    avatar_url      VARCHAR(500),
    country         CHAR(2),                          -- ISO 3166-1 alpha-2 country code
    date_of_birth   DATE,
    subscription_type VARCHAR(20) DEFAULT 'free',     -- 'free', 'premium', 'family', 'student'
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE: artists
-- Purpose: Stores artist/band information including their profile and metadata
-- ============================================================================
CREATE TABLE artists (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    bio             TEXT,
    avatar_url      VARCHAR(500),
    verified        BOOLEAN DEFAULT FALSE,
    monthly_listeners BIGINT DEFAULT 0,
    country         CHAR(2),                          -- Origin country
    genres          VARCHAR[],                        -- Array of genre tags
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE: albums
-- Purpose: Stores album information, each album belongs to a primary artist
-- ============================================================================
CREATE TABLE albums (
    id              BIGSERIAL PRIMARY KEY,
    artist_id       BIGINT NOT NULL,
    title           VARCHAR(255) NOT NULL,
    cover_url       VARCHAR(500),
    album_type      VARCHAR(20) DEFAULT 'album',      -- 'album', 'single', 'ep', 'compilation'
    release_date    DATE,
    total_tracks    INT DEFAULT 0,
    duration_ms     BIGINT DEFAULT 0,                 -- Total album duration in milliseconds
    label           VARCHAR(255),                     -- Record label
    copyright       VARCHAR(500),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: tracks
-- Purpose: Stores individual track/song information
-- ============================================================================
CREATE TABLE tracks (
    id              BIGSERIAL PRIMARY KEY,
    album_id        BIGINT NOT NULL,
    title           VARCHAR(255) NOT NULL,
    duration_ms     INT NOT NULL,                     -- Track duration in milliseconds
    track_number    INT NOT NULL,                     -- Position in album
    disc_number     INT DEFAULT 1,                    -- For multi-disc albums
    explicit        BOOLEAN DEFAULT FALSE,
    isrc            VARCHAR(12),                      -- International Standard Recording Code
    preview_url     VARCHAR(500),                     -- 30-second preview URL
    audio_url       VARCHAR(500),                     -- Full track audio URL
    popularity      INT DEFAULT 0 CHECK (popularity >= 0 AND popularity <= 100),
    play_count      BIGINT DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: track_artists
-- Purpose: Junction table for many-to-many relationship between tracks and artists
--          Handles featured artists and collaborations
-- ============================================================================
CREATE TABLE track_artists (
    track_id        BIGINT NOT NULL,
    artist_id       BIGINT NOT NULL,
    artist_role     VARCHAR(20) DEFAULT 'primary',    -- 'primary', 'featured', 'remixer'
    display_order   INT DEFAULT 0,                    -- Order in which artists are displayed
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (track_id, artist_id),
    FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: playlists
-- Purpose: Stores user-created playlists and system-generated playlists
-- ============================================================================
CREATE TABLE playlists (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    cover_url       VARCHAR(500),
    is_public       BOOLEAN DEFAULT TRUE,
    is_collaborative BOOLEAN DEFAULT FALSE,          -- Can others add tracks?
    total_tracks    INT DEFAULT 0,
    duration_ms     BIGINT DEFAULT 0,
    followers_count BIGINT DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: playlist_tracks
-- Purpose: Junction table for many-to-many relationship between playlists and tracks
--          Maintains track order within playlists
-- ============================================================================
CREATE TABLE playlist_tracks (
    id              BIGSERIAL PRIMARY KEY,            -- Separate PK for easier reordering
    playlist_id     BIGINT NOT NULL,
    track_id        BIGINT NOT NULL,
    added_by_user_id BIGINT,
    position        INT NOT NULL,                     -- Track position in playlist
    added_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (playlist_id, track_id),                   -- Prevent duplicate tracks in same playlist
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE,
    FOREIGN KEY (added_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLE: user_follows
-- Purpose: Tracks which artists each user follows
-- ============================================================================
CREATE TABLE user_follows (
    user_id         BIGINT NOT NULL,
    artist_id       BIGINT NOT NULL,
    followed_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notifications_enabled BOOLEAN DEFAULT TRUE,       -- Notify on new releases
    PRIMARY KEY (user_id, artist_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: user_follows_users
-- Purpose: Tracks which users follow other users (for seeing friends' activity)
-- ============================================================================
CREATE TABLE user_follows_users (
    follower_id     BIGINT NOT NULL,
    following_id    BIGINT NOT NULL,
    followed_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id != following_id),              -- Prevent self-following
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: listening_history
-- Purpose: Records every track play for analytics, recommendations, and "recently played"
-- ============================================================================
CREATE TABLE listening_history (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    track_id        BIGINT NOT NULL,
    played_at       TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    duration_played_ms INT,                           -- How much of the track was played
    context_type    VARCHAR(20),                      -- 'album', 'playlist', 'artist', 'search'
    context_id      BIGINT,                           -- ID of the context (album_id, playlist_id, etc.)
    device_type     VARCHAR(50),                      -- 'mobile', 'desktop', 'web', 'smart_speaker'
    shuffle_mode    BOOLEAN DEFAULT FALSE,
    repeat_mode     VARCHAR(10) DEFAULT 'off',        -- 'off', 'track', 'context'
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: saved_tracks (User's Library - Liked Songs)
-- Purpose: Tracks that users have saved/liked to their library
-- ============================================================================
CREATE TABLE saved_tracks (
    user_id         BIGINT NOT NULL,
    track_id        BIGINT NOT NULL,
    saved_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, track_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: saved_albums
-- Purpose: Albums that users have saved to their library
-- ============================================================================
CREATE TABLE saved_albums (
    user_id         BIGINT NOT NULL,
    album_id        BIGINT NOT NULL,
    saved_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, album_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLE: playlist_followers
-- Purpose: Tracks which users follow which playlists
-- ============================================================================
CREATE TABLE playlist_followers (
    user_id         BIGINT NOT NULL,
    playlist_id     BIGINT NOT NULL,
    followed_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, playlist_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE
);


-- ============================================================================
-- INDEXES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Users table indexes
-- -----------------------------------------------------------------------------
-- For login queries (searching by email)
CREATE INDEX idx_users_email ON users(email);

-- For username lookups and profile searches
CREATE INDEX idx_users_username ON users(username);

-- For filtering users by subscription type (analytics, feature flags)
CREATE INDEX idx_users_subscription_type ON users(subscription_type, is_active);

-- -----------------------------------------------------------------------------
-- Artists table indexes
-- -----------------------------------------------------------------------------
-- For searching artists by name (case-insensitive search support)
CREATE INDEX idx_artists_name ON artists(name);
CREATE INDEX idx_artists_name_trgm ON artists USING GIN (name gin_trgm_ops);  -- Fuzzy text search with pg_trgm

-- For sorting by popularity
CREATE INDEX idx_artists_monthly_listeners ON artists(monthly_listeners DESC);

-- For filtering by verification status (partial index for verified artists only)
CREATE INDEX idx_artists_verified ON artists(verified) WHERE verified = TRUE;

-- -----------------------------------------------------------------------------
-- Albums table indexes
-- -----------------------------------------------------------------------------
-- For fetching all albums by an artist
CREATE INDEX idx_albums_artist_id ON albums(artist_id);

-- For sorting albums by release date (new releases feature)
CREATE INDEX idx_albums_release_date ON albums(release_date DESC);

-- For filtering by album type
CREATE INDEX idx_albums_type ON albums(album_type);

-- Composite index for artist's albums sorted by date
CREATE INDEX idx_albums_artist_release ON albums(artist_id, release_date DESC);

-- -----------------------------------------------------------------------------
-- Tracks table indexes
-- -----------------------------------------------------------------------------
-- For fetching all tracks in an album
CREATE INDEX idx_tracks_album_id ON tracks(album_id);

-- For sorting tracks by popularity (charts, recommendations)
CREATE INDEX idx_tracks_popularity ON tracks(popularity DESC);

-- For sorting by play count
CREATE INDEX idx_tracks_play_count ON tracks(play_count DESC);

-- For searching tracks by title
CREATE INDEX idx_tracks_title ON tracks(title);
CREATE INDEX idx_tracks_title_trgm ON tracks USING GIN (title gin_trgm_ops);  -- Fuzzy text search with pg_trgm

-- Composite index for album track listing (ordered)
CREATE INDEX idx_tracks_album_order ON tracks(album_id, disc_number, track_number);

-- -----------------------------------------------------------------------------
-- Track Artists junction table indexes
-- -----------------------------------------------------------------------------
-- For finding all tracks by an artist
CREATE INDEX idx_track_artists_artist_id ON track_artists(artist_id);

-- For ordering artists on a track
CREATE INDEX idx_track_artists_display ON track_artists(track_id, display_order);

-- -----------------------------------------------------------------------------
-- Playlists table indexes
-- -----------------------------------------------------------------------------
-- For fetching all playlists by a user
CREATE INDEX idx_playlists_user_id ON playlists(user_id);

-- For discovering public playlists (partial index for public playlists only)
CREATE INDEX idx_playlists_public ON playlists(followers_count DESC) WHERE is_public = TRUE;

-- For searching playlists by name
CREATE INDEX idx_playlists_name ON playlists(name);

-- -----------------------------------------------------------------------------
-- Playlist Tracks junction table indexes
-- -----------------------------------------------------------------------------
-- For fetching tracks in a playlist (ordered)
CREATE INDEX idx_playlist_tracks_playlist_pos ON playlist_tracks(playlist_id, position);

-- For finding all playlists containing a track
CREATE INDEX idx_playlist_tracks_track_id ON playlist_tracks(track_id);

-- -----------------------------------------------------------------------------
-- User Follows (Artists) indexes
-- -----------------------------------------------------------------------------
-- For fetching all artists a user follows
CREATE INDEX idx_user_follows_user_id ON user_follows(user_id);

-- For counting/listing followers of an artist
CREATE INDEX idx_user_follows_artist_id ON user_follows(artist_id);

-- For sorting by recent follows
CREATE INDEX idx_user_follows_recent ON user_follows(user_id, followed_at DESC);

-- -----------------------------------------------------------------------------
-- Listening History indexes
-- -----------------------------------------------------------------------------
-- For fetching user's listening history (most important - heavily queried)
CREATE INDEX idx_listening_history_user_id ON listening_history(user_id);

-- For "recently played" feature (user's recent tracks)
CREATE INDEX idx_listening_history_user_recent ON listening_history(user_id, played_at DESC);

-- For track analytics (how many times a track was played)
CREATE INDEX idx_listening_history_track_id ON listening_history(track_id);

-- For time-based analytics (daily/weekly charts)
CREATE INDEX idx_listening_history_played_at ON listening_history(played_at);

-- Composite index for user's history within a time range
CREATE INDEX idx_listening_history_user_time ON listening_history(user_id, played_at DESC);

-- For context-based queries (what was played from which playlist/album)
CREATE INDEX idx_listening_history_context ON listening_history(context_type, context_id);

-- -----------------------------------------------------------------------------
-- Saved Tracks indexes
-- -----------------------------------------------------------------------------
-- For fetching user's liked songs (sorted by save date)
CREATE INDEX idx_saved_tracks_user_recent ON saved_tracks(user_id, saved_at DESC);

-- For checking if a track is saved
CREATE INDEX idx_saved_tracks_track_id ON saved_tracks(track_id);

-- -----------------------------------------------------------------------------
-- Saved Albums indexes
-- -----------------------------------------------------------------------------
-- For fetching user's saved albums
CREATE INDEX idx_saved_albums_user_recent ON saved_albums(user_id, saved_at DESC);

-- -----------------------------------------------------------------------------
-- Playlist Followers indexes
-- -----------------------------------------------------------------------------
-- For counting playlist followers
CREATE INDEX idx_playlist_followers_playlist ON playlist_followers(playlist_id);

-- For user's followed playlists
CREATE INDEX idx_playlist_followers_user ON playlist_followers(user_id, followed_at DESC);


-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Trigger function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply the trigger to all tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_artists_updated_at BEFORE UPDATE ON artists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_albums_updated_at BEFORE UPDATE ON albums
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tracks_updated_at BEFORE UPDATE ON tracks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_playlists_updated_at BEFORE UPDATE ON playlists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- NOTES FOR POSTGRESQL
-- ============================================================================
-- 1. Full-text search is available via GIN indexes with pg_trgm extension
-- 2. VARCHAR[] data type is used for arrays (e.g., genres in artists table)
-- 3. updated_at columns auto-update via triggers (defined above)
-- 4. BIGSERIAL is used for auto-incrementing primary keys
-- 5. TIMESTAMP WITH TIME ZONE is used for all timestamp columns for global consistency
-- 6. Partial indexes with WHERE clauses optimize queries for specific conditions

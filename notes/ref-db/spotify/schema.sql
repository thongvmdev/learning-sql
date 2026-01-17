-- ============================================================================
-- Spotify-like Database Schema
-- ============================================================================
-- This schema models a music streaming platform similar to Spotify
-- Includes: users, artists, albums, tracks, playlists, and listening history
-- ============================================================================

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS listening_history;
DROP TABLE IF EXISTS playlist_tracks;
DROP TABLE IF EXISTS user_follows_users;
DROP TABLE IF EXISTS user_follows_artists;
DROP TABLE IF EXISTS track_artists;
DROP TABLE IF EXISTS tracks;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS genres;

-- ============================================================================
-- CORE ENTITIES
-- ============================================================================

-- Users: Registered users of the platform
CREATE TABLE users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    date_of_birth DATE,
    country_code CHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_premium BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Artists: Music artists/bands
CREATE TABLE artists (
    artist_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL,
    bio TEXT,
    profile_image_url VARCHAR(500),
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_artist_name (artist_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Genres: Music genres
CREATE TABLE genres (
    genre_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_genre_name (genre_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Albums: Music albums
CREATE TABLE albums (
    album_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    release_date DATE,
    album_type ENUM('album', 'single', 'ep', 'compilation') DEFAULT 'album',
    cover_image_url VARCHAR(500),
    total_tracks INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_album_name (album_name),
    INDEX idx_release_date (release_date),
    INDEX idx_album_type (album_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tracks: Individual songs/tracks
CREATE TABLE tracks (
    track_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    track_name VARCHAR(255) NOT NULL,
    album_id INT UNSIGNED,
    genre_id INT UNSIGNED,
    duration_ms INT UNSIGNED NOT NULL,
    track_number INT UNSIGNED,
    explicit BOOLEAN DEFAULT FALSE,
    preview_url VARCHAR(500),
    spotify_track_id VARCHAR(100) UNIQUE,
    popularity_score INT UNSIGNED DEFAULT 0,
    play_count BIGINT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE SET NULL,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE SET NULL,
    INDEX idx_track_name (track_name),
    INDEX idx_album_id (album_id),
    INDEX idx_genre_id (genre_id),
    INDEX idx_popularity_score (popularity_score DESC),
    INDEX idx_play_count (play_count DESC),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Playlists: User-created playlists
CREATE TABLE playlists (
    playlist_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    playlist_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT TRUE,
    is_collaborative BOOLEAN DEFAULT FALSE,
    cover_image_url VARCHAR(500),
    track_count INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_playlist_name (playlist_name),
    INDEX idx_is_public (is_public),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- JUNCTION TABLES (Many-to-Many Relationships)
-- ============================================================================

-- Track-Artists: Many-to-many relationship (tracks can have multiple artists)
CREATE TABLE track_artists (
    track_id INT UNSIGNED NOT NULL,
    artist_id INT UNSIGNED NOT NULL,
    is_primary_artist BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (track_id, artist_id),
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    INDEX idx_artist_id (artist_id),
    INDEX idx_is_primary_artist (is_primary_artist)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Album-Artists: Many-to-many relationship (albums can have multiple artists)
CREATE TABLE album_artists (
    album_id INT UNSIGNED NOT NULL,
    artist_id INT UNSIGNED NOT NULL,
    is_primary_artist BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (album_id, artist_id),
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    INDEX idx_artist_id (artist_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Playlist-Tracks: Many-to-many relationship (playlists contain multiple tracks)
CREATE TABLE playlist_tracks (
    playlist_id INT UNSIGNED NOT NULL,
    track_id INT UNSIGNED NOT NULL,
    position INT UNSIGNED NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    added_by_user_id INT UNSIGNED,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE,
    FOREIGN KEY (added_by_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_track_id (track_id),
    INDEX idx_position (position),
    INDEX idx_added_at (added_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Follows Artists: Users can follow artists
CREATE TABLE user_follows_artists (
    user_id INT UNSIGNED NOT NULL,
    artist_id INT UNSIGNED NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, artist_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    INDEX idx_artist_id (artist_id),
    INDEX idx_followed_at (followed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Follows Users: Users can follow other users
CREATE TABLE user_follows_users (
    follower_id INT UNSIGNED NOT NULL,
    following_id INT UNSIGNED NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (follower_id != following_id),
    INDEX idx_following_id (following_id),
    INDEX idx_followed_at (followed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listening History: Track user listening activity
CREATE TABLE listening_history (
    history_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    track_id INT UNSIGNED NOT NULL,
    played_at TIMESTAMP NOT NULL,
    context_type ENUM('playlist', 'album', 'artist', 'search', 'radio', 'other') DEFAULT 'other',
    context_id INT UNSIGNED,
    duration_listened_ms INT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_track_id (track_id),
    INDEX idx_played_at (played_at DESC),
    INDEX idx_user_played_at (user_id, played_at DESC),
    INDEX idx_track_played_at (track_id, played_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

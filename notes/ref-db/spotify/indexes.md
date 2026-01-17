# Index Strategy for Spotify Database Schema

This document explains the indexing strategy for the Spotify-like database schema, focusing on performance optimization for common query patterns.

## Index Overview

Indexes are crucial for optimizing query performance, especially in a music streaming platform with millions of users, tracks, and listening events. Each index is designed to support specific query patterns.

---

## Primary Indexes (Automatic)

All tables have primary keys that automatically create indexes:

- `users.user_id`
- `artists.artist_id`
- `albums.album_id`
- `tracks.track_id`
- `playlists.playlist_id`
- `genres.genre_id`
- `listening_history.history_id`

---

## Secondary Indexes by Table

### `users` Table

#### `idx_username`

- **Columns**: `username`
- **Purpose**: Fast user lookup by username (login, profile views)
- **Query Pattern**: `SELECT * FROM users WHERE username = ?`
- **Why Needed**: Username is used for authentication and profile access

#### `idx_email`

- **Columns**: `email`
- **Purpose**: Fast user lookup by email (login, account recovery)
- **Query Pattern**: `SELECT * FROM users WHERE email = ?`
- **Why Needed**: Email is used for authentication and account management

#### `idx_created_at`

- **Columns**: `created_at`
- **Purpose**: Sort users by registration date (analytics, admin queries)
- **Query Pattern**: `SELECT * FROM users ORDER BY created_at DESC`
- **Why Needed**: Support user growth analytics and admin dashboards

---

### `artists` Table

#### `idx_artist_name`

- **Columns**: `artist_name`
- **Purpose**: Fast artist search by name
- **Query Pattern**: `SELECT * FROM artists WHERE artist_name LIKE ?`
- **Why Needed**: Users frequently search for artists by name

---

### `albums` Table

#### `idx_album_name`

- **Columns**: `album_name`
- **Purpose**: Fast album search by name
- **Query Pattern**: `SELECT * FROM albums WHERE album_name LIKE ?`
- **Why Needed**: Users search for albums by name

#### `idx_release_date`

- **Columns**: `release_date`
- **Purpose**: Sort albums by release date (new releases, chronological browsing)
- **Query Pattern**: `SELECT * FROM albums ORDER BY release_date DESC`
- **Why Needed**: Display new releases and browse albums chronologically

#### `idx_album_type`

- **Columns**: `album_type`
- **Purpose**: Filter albums by type (album, single, EP, compilation)
- **Query Pattern**: `SELECT * FROM albums WHERE album_type = ?`
- **Why Needed**: Users often filter by album type

---

### `tracks` Table

#### `idx_track_name`

- **Columns**: `track_name`
- **Purpose**: Fast track search by name
- **Query Pattern**: `SELECT * FROM tracks WHERE track_name LIKE ?`
- **Why Needed**: Most common search operation - users search for tracks

#### `idx_album_id`

- **Columns**: `album_id`
- **Purpose**: Fast lookup of tracks in an album
- **Query Pattern**: `SELECT * FROM tracks WHERE album_id = ? ORDER BY track_number`
- **Why Needed**: Display all tracks when viewing an album

#### `idx_genre_id`

- **Columns**: `genre_id`
- **Purpose**: Filter tracks by genre
- **Query Pattern**: `SELECT * FROM tracks WHERE genre_id = ?`
- **Why Needed**: Genre-based browsing and recommendations

#### `idx_popularity_score` (DESC)

- **Columns**: `popularity_score`
- **Purpose**: Sort tracks by popularity (trending, top charts)
- **Query Pattern**: `SELECT * FROM tracks ORDER BY popularity_score DESC LIMIT ?`
- **Why Needed**: Display trending tracks and charts

#### `idx_play_count` (DESC)

- **Columns**: `play_count`
- **Purpose**: Sort tracks by total play count (most played)
- **Query Pattern**: `SELECT * FROM tracks ORDER BY play_count DESC LIMIT ?`
- **Why Needed**: Display most popular tracks globally

#### `idx_created_at`

- **Columns**: `created_at`
- **Purpose**: Sort tracks by addition date (newest tracks)
- **Query Pattern**: `SELECT * FROM tracks ORDER BY created_at DESC`
- **Why Needed**: Display newly added tracks

---

### `playlists` Table

#### `idx_user_id`

- **Columns**: `user_id`
- **Purpose**: Fast lookup of user's playlists
- **Query Pattern**: `SELECT * FROM playlists WHERE user_id = ?`
- **Why Needed**: Display all playlists for a user

#### `idx_playlist_name`

- **Columns**: `playlist_name`
- **Purpose**: Search playlists by name
- **Query Pattern**: `SELECT * FROM playlists WHERE playlist_name LIKE ?`
- **Why Needed**: Users search for playlists

#### `idx_is_public`

- **Columns**: `is_public`
- **Purpose**: Filter public playlists
- **Query Pattern**: `SELECT * FROM playlists WHERE is_public = TRUE`
- **Why Needed**: Display only public playlists in search/browse

#### `idx_created_at`

- **Columns**: `created_at`
- **Purpose**: Sort playlists by creation date
- **Query Pattern**: `SELECT * FROM playlists ORDER BY created_at DESC`
- **Why Needed**: Display newest playlists

---

### `track_artists` Junction Table

#### `idx_artist_id`

- **Columns**: `artist_id`
- **Purpose**: Fast lookup of all tracks by an artist
- **Query Pattern**: `SELECT t.* FROM tracks t JOIN track_artists ta ON t.track_id = ta.track_id WHERE ta.artist_id = ?`
- **Why Needed**: Display artist's discography

#### `idx_is_primary_artist`

- **Columns**: `is_primary_artist`
- **Purpose**: Filter primary vs featured artists
- **Query Pattern**: `SELECT * FROM track_artists WHERE artist_id = ? AND is_primary_artist = TRUE`
- **Why Needed**: Distinguish between primary and featured artists

---

### `album_artists` Junction Table

#### `idx_artist_id`

- **Columns**: `artist_id`
- **Purpose**: Fast lookup of all albums by an artist
- **Query Pattern**: `SELECT a.* FROM albums a JOIN album_artists aa ON a.album_id = aa.album_id WHERE aa.artist_id = ?`
- **Why Needed**: Display artist's albums

---

### `playlist_tracks` Junction Table

#### `idx_track_id`

- **Columns**: `track_id`
- **Purpose**: Find all playlists containing a specific track
- **Query Pattern**: `SELECT p.* FROM playlists p JOIN playlist_tracks pt ON p.playlist_id = pt.playlist_id WHERE pt.track_id = ?`
- **Why Needed**: Show which playlists include a track

#### `idx_position`

- **Columns**: `position`
- **Purpose**: Maintain track order in playlists
- **Query Pattern**: `SELECT * FROM playlist_tracks WHERE playlist_id = ? ORDER BY position`
- **Why Needed**: Display tracks in correct playlist order

#### `idx_added_at`

- **Columns**: `added_at`
- **Purpose**: Sort tracks by when they were added to playlist
- **Query Pattern**: `SELECT * FROM playlist_tracks WHERE playlist_id = ? ORDER BY added_at DESC`
- **Why Needed**: Show recently added tracks

---

### `user_follows_artists` Junction Table

#### `idx_artist_id`

- **Columns**: `artist_id`
- **Purpose**: Find all users following an artist
- **Query Pattern**: `SELECT u.* FROM users u JOIN user_follows_artists ufa ON u.user_id = ufa.user_id WHERE ufa.artist_id = ?`
- **Why Needed**: Display artist's follower count and list

#### `idx_followed_at`

- **Columns**: `followed_at`
- **Purpose**: Sort follows by date (recent followers)
- **Query Pattern**: `SELECT * FROM user_follows_artists WHERE artist_id = ? ORDER BY followed_at DESC`
- **Why Needed**: Analytics and recent follower lists

---

### `user_follows_users` Junction Table

#### `idx_following_id`

- **Columns**: `following_id`
- **Purpose**: Find all followers of a user
- **Query Pattern**: `SELECT u.* FROM users u JOIN user_follows_users ufu ON u.user_id = ufu.follower_id WHERE ufu.following_id = ?`
- **Why Needed**: Display user's follower list

#### `idx_followed_at`

- **Columns**: `followed_at`
- **Purpose**: Sort follows by date
- **Query Pattern**: `SELECT * FROM user_follows_users WHERE following_id = ? ORDER BY followed_at DESC`
- **Why Needed**: Show recent followers

---

### `listening_history` Table

This table is expected to be very large (millions/billions of rows), so indexes are critical.

#### `idx_user_id`

- **Columns**: `user_id`
- **Purpose**: Fast lookup of user's listening history
- **Query Pattern**: `SELECT * FROM listening_history WHERE user_id = ? ORDER BY played_at DESC`
- **Why Needed**: Display user's recently played tracks

#### `idx_track_id`

- **Columns**: `track_id`
- **Purpose**: Find all users who listened to a track
- **Query Pattern**: `SELECT * FROM listening_history WHERE track_id = ?`
- **Why Needed**: Track popularity analytics

#### `idx_played_at` (DESC)

- **Columns**: `played_at`
- **Purpose**: Sort listening history by time (most recent first)
- **Query Pattern**: `SELECT * FROM listening_history ORDER BY played_at DESC LIMIT ?`
- **Why Needed**: Global recent activity feed

#### `idx_user_played_at` (Composite, DESC)

- **Columns**: `user_id`, `played_at`
- **Purpose**: Optimize queries for user's listening history sorted by time
- **Query Pattern**: `SELECT * FROM listening_history WHERE user_id = ? ORDER BY played_at DESC`
- **Why Needed**: Most common query - user's recently played tracks. Composite index is more efficient than separate indexes.

#### `idx_track_played_at` (Composite, DESC)

- **Columns**: `track_id`, `played_at`
- **Purpose**: Optimize queries for track's listening history sorted by time
- **Query Pattern**: `SELECT * FROM listening_history WHERE track_id = ? ORDER BY played_at DESC`
- **Why Needed**: Track analytics and popularity trends

---

## Index Maintenance Considerations

1. **Partitioning**: Consider partitioning `listening_history` by date for better performance
2. **Archiving**: Implement data archiving strategy for old listening history
3. **Monitoring**: Regularly monitor index usage and remove unused indexes
4. **Full-Text Search**: Consider adding FULLTEXT indexes on `track_name`, `artist_name`, `album_name` for better search performance
5. **Covering Indexes**: For frequently accessed queries, consider covering indexes that include all needed columns

---

## Query Performance Tips

- Use `EXPLAIN` to analyze query execution plans
- Monitor slow query logs
- Consider read replicas for analytics queries
- Use connection pooling for high-traffic scenarios
- Implement caching for frequently accessed data (e.g., popular tracks, user playlists)

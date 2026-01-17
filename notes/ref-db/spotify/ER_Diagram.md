# Spotify Database - Entity Relationship Diagram

This document contains the Mermaid ER diagram for the Spotify-like database schema.

## Full ER Diagram

```mermaid
erDiagram
    users ||--o{ playlists : "creates"
    users ||--o{ listening_history : "listens to"
    users ||--o{ user_follows_users : "follows/followed by"
    users ||--o{ user_follows_artists : "follows"
    users ||--o{ playlist_tracks : "adds tracks"

    artists ||--o{ track_artists : "performs in"
    artists ||--o{ album_artists : "creates"
    artists ||--o{ user_follows_artists : "followed by"

    albums ||--o{ tracks : "contains"
    albums ||--o{ album_artists : "created by"

    genres ||--o{ tracks : "categorizes"

    tracks ||--o{ track_artists : "performed by"
    tracks ||--o{ playlist_tracks : "included in"
    tracks ||--o{ listening_history : "listened to"

    playlists ||--o{ playlist_tracks : "contains"

    users {
        int_unsigned user_id PK "Auto increment"
        varchar_50 username UK "Unique"
        varchar_255 email UK "Unique"
        varchar_255 password_hash "Encrypted"
        varchar_100 display_name "Optional"
        date date_of_birth "Optional"
        char_2 country_code "ISO code"
        timestamp created_at "Auto"
        timestamp updated_at "Auto update"
        boolean is_premium "Default false"
        boolean is_active "Default true"
    }

    artists {
        int_unsigned artist_id PK "Auto increment"
        varchar_255 artist_name "Required"
        text bio "Optional"
        varchar_500 profile_image_url "Optional"
        boolean verified "Default false"
        timestamp created_at "Auto"
        timestamp updated_at "Auto update"
    }

    genres {
        int_unsigned genre_id PK "Auto increment"
        varchar_100 genre_name UK "Unique"
        text description "Optional"
        timestamp created_at "Auto"
    }

    albums {
        int_unsigned album_id PK "Auto increment"
        varchar_255 album_name "Required"
        date release_date "Optional"
        enum album_type "album|single|ep|compilation"
        varchar_500 cover_image_url "Optional"
        int_unsigned total_tracks "Default 0"
        timestamp created_at "Auto"
        timestamp updated_at "Auto update"
    }

    tracks {
        int_unsigned track_id PK "Auto increment"
        varchar_255 track_name "Required"
        int_unsigned album_id FK "Nullable"
        int_unsigned genre_id FK "Nullable"
        int_unsigned duration_ms "Required, milliseconds"
        int_unsigned track_number "Optional"
        boolean explicit "Default false"
        varchar_500 preview_url "Optional"
        varchar_100 spotify_track_id UK "Optional, unique"
        int_unsigned popularity_score "Default 0"
        bigint_unsigned play_count "Default 0"
        timestamp created_at "Auto"
        timestamp updated_at "Auto update"
    }

    playlists {
        int_unsigned playlist_id PK "Auto increment"
        int_unsigned user_id FK "Required"
        varchar_255 playlist_name "Required"
        text description "Optional"
        boolean is_public "Default true"
        boolean is_collaborative "Default false"
        varchar_500 cover_image_url "Optional"
        int_unsigned track_count "Default 0"
        timestamp created_at "Auto"
        timestamp updated_at "Auto update"
    }

    track_artists {
        int_unsigned track_id FK "PK part 1"
        int_unsigned artist_id FK "PK part 2"
        boolean is_primary_artist "Default true"
        timestamp created_at "Auto"
    }

    album_artists {
        int_unsigned album_id FK "PK part 1"
        int_unsigned artist_id FK "PK part 2"
        boolean is_primary_artist "Default true"
        timestamp created_at "Auto"
    }

    playlist_tracks {
        int_unsigned playlist_id FK "PK part 1"
        int_unsigned track_id FK "PK part 2"
        int_unsigned position "Required, track order"
        timestamp added_at "Auto"
        int_unsigned added_by_user_id FK "Nullable"
    }

    user_follows_artists {
        int_unsigned user_id FK "PK part 1"
        int_unsigned artist_id FK "PK part 2"
        timestamp followed_at "Auto"
    }

    user_follows_users {
        int_unsigned follower_id FK "PK part 1"
        int_unsigned following_id FK "PK part 2"
        timestamp followed_at "Auto"
    }

    listening_history {
        bigint_unsigned history_id PK "Auto increment"
        int_unsigned user_id FK "Required"
        int_unsigned track_id FK "Required"
        timestamp played_at "Required"
        enum context_type "playlist|album|artist|search|radio|other"
        int_unsigned context_id "Optional"
        int_unsigned duration_listened_ms "Optional"
        timestamp created_at "Auto"
    }
```

## Relationship Summary

### One-to-Many Relationships

1. **users → playlists**: One user creates many playlists
2. **users → listening_history**: One user has many listening records
3. **albums → tracks**: One album contains many tracks
4. **genres → tracks**: One genre categorizes many tracks
5. **users → playlist_tracks** (via `added_by_user_id`): One user adds many tracks to playlists

### Many-to-Many Relationships

1. **tracks ↔ artists** (via `track_artists`): Tracks can have multiple artists, artists can have multiple tracks
2. **albums ↔ artists** (via `album_artists`): Albums can have multiple artists, artists can have multiple albums
3. **playlists ↔ tracks** (via `playlist_tracks`): Playlists contain multiple tracks, tracks can be in multiple playlists
4. **users ↔ artists** (via `user_follows_artists`): Users can follow multiple artists, artists can be followed by multiple users
5. **users ↔ users** (via `user_follows_users`): Users can follow multiple users, users can be followed by multiple users

## Cardinality Notation

- `||--o{` : One-to-Many (one on left, many on right)
- `}o--||` : Many-to-One (many on left, one on right)
- `}o--o{` : Many-to-Many (via junction table)

## Key Symbols

- **PK**: Primary Key
- **FK**: Foreign Key
- **UK**: Unique Key
- **Auto**: Automatically set (DEFAULT CURRENT_TIMESTAMP)
- **Auto update**: Automatically updated (ON UPDATE CURRENT_TIMESTAMP)

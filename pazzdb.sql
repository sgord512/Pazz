pragma foreign_keys = ON;

create table if not exists albums
(
	album_id integer primary key,
	album_name text,
	album_notes text default (''),
	date_added text default current_timestamp
);

create table if not exists artists
(
	artist_id integer primary key,
	artist_name text,
	artist_notes text default (''),
	date_added text default current_timestamp
);

create table if not exists songs
(
	song_id integer primary key,
	song_name text,
	song_notes text default (''),
	album_id integer references albums(album_id),
	date_added text default current_timestamp
);

create table if not exists artist_song_bridge 
(
	artist_id integer not null references artists,
	song_id integer not null references songs,
	primary key (artist_id, song_id)
);
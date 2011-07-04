insert into albums (album_name, album_notes) values ('They Might Be Giants', 'A great album. One of their best. Lots of standout tracks.');

insert into artists (artist_name, artist_notes) values ('They Might Be Giants', NULL);

insert into songs (song_name, song_notes, album_id) values ('Absolutely Bill''s Mood', 'Absolutely Bill''s Mood moody, dramatic, another classic on TMBG''s eponymous album. Interesting rythmically. The back end of this album needs more love.', NULL);

update songs set album_id = (select album_id from albums where album_name = 'They Might Be Giants');
#!/bin/bash
#step 1. cd to the banshee db folder
cd ~/.config/banshee-1
#step 2. run sql query against that database
echo 'delete from coretracks where TrackID in (select trackid from (select TrackID as trackid, count(TrackID) as c from coretracks group by TitleLowered,ArtistID,AlbumID,Title) where c > 1);' | sqlite3 banshee.db
exit
